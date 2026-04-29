<?php

namespace App\Http\Controllers;

use App\Models\PromotionCard;
use App\Models\Wallet;
use App\Models\Expense;
use Illuminate\Support\Str;
use App\Models\SellerInventory;
use Illuminate\Http\Request;
use App\Services\ResponseService;

class PromotionCardController extends Controller
{
    public function create(Request $request)
    {
        try {
            $validated = $request->validate([
                'card_id' => 'nullable|integer',
                'seller_inventory_id' => 'nullable|integer',
                'promotion_price' => 'required|numeric|min:0',
                'promotion_type' => 'required|in:time,impression',
                'promotion_duration' => 'nullable|integer|min:1', // hours
                'max_views' => 'nullable|integer|min:1',
            ]);

            $cardId = $validated['card_id']
                ?? $validated['seller_inventory_id']
                ?? null;
            if (!$cardId) {
                return ResponseService::error('Missing card identifier (card_id or seller_inventory_id)');
            }

            // Prevent duplicate active promotion for this card
            $exists = PromotionCard::active()->where('card_id', $cardId)->exists();
            if ($exists) {
                return ResponseService::error('This card already has an active promotion');
            }

            // Deduct from wallet
            $user = $request->user();
            $wallet = Wallet::where('user_id', $user->id)->first();
            if (!$wallet) {
                return ResponseService::error('Your balance is not enough. Please recharge it.');
            }
            if ((float)$wallet->balance < (float)$validated['promotion_price']) {
                return ResponseService::error('Insufficient wallet balance');
            }
            $wallet->balance = (float)$wallet->balance - (float)$validated['promotion_price'];
            $wallet->expense = (float)$wallet->expense + (float)$validated['promotion_price'];
            $wallet->save();

            Expense::create([
                'user_id' => $user->id,
                'transaction_id' => (string) Str::uuid(),
                'initiated' => 'wallet',
                'used_for' => 'promotion',
                'amount' => $validated['promotion_price'],
                'status' => 'success',
            ]);

            $promotion = new PromotionCard();
            $promotion->user_id = $user->id;
            $promotion->card_id = $cardId;
            $promotion->promotion_price = $validated['promotion_price'];
            $promotion->promotion_type = $validated['promotion_type'];
            $promotion->promotion_views = 0;
            $promotion->promotion_duration = $validated['promotion_duration'] ?? null;
            $promotion->max_views = $validated['max_views'] ?? null;

            // Calculate expiry when time-based
            if ($promotion->promotion_type === 'time' && $promotion->promotion_duration) {
                // Treat duration as hours; adjust if days are preferred
                $promotion->expires_at = now()->addHours((int) $promotion->promotion_duration);
            }

            $promotion->is_active = true;
            $promotion->save();

            return ResponseService::success('Promotion created', $promotion);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to create promotion', $e->getMessage());
        }
    }

    public function status(Request $request)
    {
        try {
            $cardId = $request->get('card_id');
            if (!$cardId) {
                return ResponseService::error('card_id is required');
            }
            $promotion = PromotionCard::active()->where('card_id', $cardId)->first();
            return ResponseService::success('Status fetched', [
                'active' => (bool) $promotion,
                'id' => $promotion?->id,
            ]);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to fetch status', $e->getMessage());
        }
    }

    public function spotlight(Request $request)
    {
        try {
            $promotions = PromotionCard::active()
                ->orderBy('created_at', 'desc')
                ->paginate($request->get('limit', 12));

            return ResponseService::successWithPagination('Spotlight promotions', $promotions);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to fetch promotions', $e->getMessage());
        }
    }

    public function mine(Request $request)
    {
        try {
            $user = $request->user();
            $promotions = PromotionCard::where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->paginate($request->get('limit', 12));

            $transformed = $promotions->getCollection()->map(function ($p) {
                $status = 'active';
                $remaining = null;
                if ($p->promotion_type === 'time') {
                    $remainingSeconds = $p->expires_at ? max(0, strtotime($p->expires_at) - time()) : null;
                    if ($remainingSeconds === 0) $status = 'expired';
                    $remaining = $remainingSeconds;
                } else if ($p->promotion_type === 'impression') {
                    if ($p->max_views && $p->promotion_views >= $p->max_views) $status = 'completed';
                    $remaining = $p->max_views ? max(0, $p->max_views - $p->promotion_views) : null;
                }

                // Attach card details from seller inventory
                $inventory = SellerInventory::find($p->card_id);
                $imageUrl = null;
                $imagePath = null;
                if ($inventory && is_array($inventory->images) && count($inventory->images) > 0) {
                    $imagePath = $inventory->images[0];
                    $imageUrl = env('APP_URL') . '/storage/' . $imagePath;
                }
                return [
                    'id' => $p->id,
                    'card_id' => $p->card_id,
                    'promotion_price' => (float) $p->promotion_price,
                    'promotion_type' => $p->promotion_type,
                    'promotion_views' => (int) $p->promotion_views,
                    'promotion_duration' => $p->promotion_duration,
                    'max_views' => $p->max_views,
                    'expires_at' => $p->expires_at,
                    'is_active' => (bool) $p->is_active,
                    'status' => $status,
                    'remaining' => $remaining,
                    'created_at' => $p->created_at,
                    'item' => $inventory ? [
                        'title' => $inventory->card_title,
                        'price' => $inventory->price,
                        'image' => $imageUrl,
                        'image_path' => $imagePath,
                    ] : null,
                ];
            });

            $paginated = new \Illuminate\Pagination\LengthAwarePaginator(
                $transformed,
                $promotions->total(),
                $promotions->perPage(),
                $promotions->currentPage(),
                ['path' => $promotions->path()]
            );

            return ResponseService::successWithPagination('My promotions', $paginated);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to fetch my promotions', $e->getMessage());
        }
    }

    public function view($id)
    {
        try {
            $promotion = PromotionCard::findOrFail($id);
            // Do not count owner views if authenticated
            $viewer = request()->user();
            if ($viewer && (int)$viewer->id === (int)$promotion->user_id) {
                return ResponseService::success('Owner view ignored');
            }

            $promotion->increment('promotion_views');

            // Auto-deactivate if impression cap reached
            if ($promotion->promotion_type === 'impression' && $promotion->max_views && $promotion->promotion_views >= $promotion->max_views) {
                $promotion->is_active = false;
                $promotion->save();
            }

            return ResponseService::success('View tracked');
        } catch (\Exception $e) {
            return ResponseService::error('Failed to track view', $e->getMessage());
        }
    }
}



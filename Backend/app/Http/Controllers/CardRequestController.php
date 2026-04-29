<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CardRequest;
use App\Models\SellerInventory;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use App\Services\ResponseService;

class CardRequestController extends Controller
{
    /**
     * Get all card requests with pagination.
     */
    public function index(Request $request)
    {
        try {
            $query = CardRequest::with('sellerInventory.user');
            
            // Filter by status if provided
            if ($request->has('status')) {
                $query->where('request_status', $request->status);
            }
            
            // Filter by card title if provided
            if ($request->has('search')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('card_title', 'like', '%' . $request->search . '%');
                });
            }
            
            $requests = $query->orderBy('created_at', 'desc')->paginate(15);
            
            // Transform the data to flatten the structure for frontend
            $transformedData = $requests->getCollection()->map(function ($request) {
                $inventory = $request->sellerInventory;
                return [
                    'id' => $request->id,
                    'card_id' => $request->card_id,
                    'request_status' => $request->request_status,
                    'created_at' => $request->created_at,
                    'updated_at' => $request->updated_at,
                    // Flatten seller inventory data
                    'card_title' => $inventory->card_title,
                    'description' => $inventory->description,
                    'price' => $inventory->price,
                    'condition' => $inventory->condition,
                    'grade' => $inventory->grade,
                    'sport_type' => $inventory->sport_type,
                    'weight' => $inventory->weight,
                    'images' => $inventory->images,
                    'user' => $inventory->user,
                    'seller_inventory' => $inventory, // Keep the full object for compatibility
                ];
            });
            
            // Create a new paginator with transformed data
            $transformedRequests = new \Illuminate\Pagination\LengthAwarePaginator(
                $transformedData,
                $requests->total(),
                $requests->perPage(),
                $requests->currentPage(),
                ['path' => $requests->path()]
            );
            
            return ResponseService::successWithPagination('Card requests retrieved successfully', $transformedRequests);
            
        } catch (\Exception $e) {
            return ResponseService::error('Failed to fetch card requests', $e->getMessage(), 500);
        }
    }

    /**
     * Get a specific card request.
     */
    public function show($id)
    {
        try {
            $request = CardRequest::with('sellerInventory.user')->findOrFail($id);
            $inventory = $request->sellerInventory;
            
            // Transform the data to flatten the structure for frontend
            $transformedRequest = [
                'id' => $request->id,
                'card_id' => $request->card_id,
                'request_status' => $request->request_status,
                'created_at' => $request->created_at,
                'updated_at' => $request->updated_at,
                // Flatten seller inventory data
                'card_title' => $inventory->card_title,
                'description' => $inventory->description,
                'price' => $inventory->price,
                'condition' => $inventory->condition,
                'sport_type' => $inventory->sport_type,
                'weight' => $inventory->weight,
                'images' => $inventory->images,
                'user' => $inventory->user,
                'seller_inventory' => $inventory, // Keep the full object for compatibility
            ];
            
            return ResponseService::success('Card request retrieved successfully', $transformedRequest);
            
        } catch (\Exception $e) {
            return ResponseService::error('Card request not found', $e->getMessage(), 404);
        }
    }

    /**
     * Approve a card request.
     */
    public function approve($id)
    {
        try {
            $request = CardRequest::findOrFail($id);
            
            if ($request->request_status !== 'pending') {
                return ResponseService::error('Only pending requests can be approved', null, 400);
            }
            
            $request->update(['request_status' => 'approved']);
            
            return ResponseService::success('Card request approved successfully', $request);
            
        } catch (\Exception $e) {
            return ResponseService::error('Failed to approve card request', $e->getMessage(), 500);
        }
    }

    /**
     * Reject a card request.
     */
    public function reject($id)
    {
        try {
            $request = CardRequest::findOrFail($id);
            
            if ($request->request_status !== 'pending') {
                return ResponseService::error('Only pending requests can be rejected', null, 400);
            }
            
            $request->update(['request_status' => 'rejected']);
            
            return ResponseService::success('Card request rejected successfully', $request);
            
        } catch (\Exception $e) {
            return ResponseService::error('Failed to reject card request', $e->getMessage(), 500);
        }
    }

    /**
     * Get card request statistics.
     */
    public function statistics()
    {
        try {
            $stats = [
                'total_requests' => CardRequest::count(),
                'pending_requests' => CardRequest::pending()->count(),
                'approved_requests' => CardRequest::approved()->count(),
                'rejected_requests' => CardRequest::rejected()->count(),
                'recent_requests' => CardRequest::with('sellerInventory')
                    ->orderBy('created_at', 'desc')
                    ->limit(5)
                    ->get()
            ];
            
            return ResponseService::success('Statistics retrieved successfully', $stats);
            
        } catch (\Exception $e) {
            return ResponseService::error('Failed to fetch statistics', $e->getMessage(), 500);
        }
    }

    /**
     * Browse active cards for buyers (public endpoint)
     */
    public function browseActiveCards(Request $request)
    {
        try {
            $query = CardRequest::with('sellerInventory.user.profile')
                ->where('request_status', 'approved'); // Only show approved cards
            
            // Search by card title or description
            if ($request->has('search')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('card_title', 'like', '%' . $request->search . '%')
                      ->orWhere('description', 'like', '%' . $request->search . '%');
                });
            }
            
            // Filter by sport type
            if ($request->has('sport_type')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('sport_type', $request->sport_type);
                });
            }
            
            // Filter by condition
            if ($request->has('condition')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('condition', $request->condition);
                });
            }
            
            // Filter by grade
            if ($request->has('grade')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('grade', $request->grade);
                });
            }
            
            // Price range filter
            if ($request->has('min_price')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('price', '>=', $request->min_price);
                });
            }
            
            if ($request->has('max_price')) {
                $query->whereHas('sellerInventory', function ($q) use ($request) {
                    $q->where('price', '<=', $request->max_price);
                });
            }
            
            // Sorting
            $sortBy = $request->get('sort_by', 'created_at');
            
            if ($sortBy === 'price_asc' || $sortBy === 'price_desc') {
                $direction = $sortBy === 'price_asc' ? 'asc' : 'desc';
                // Use a different approach - get all cards first, then sort in PHP
                $allCards = $query->get();
                $sortedCards = $allCards->sortBy(function ($card) {
                    return $card->sellerInventory->price;
                });
                
                if ($direction === 'desc') {
                    $sortedCards = $sortedCards->reverse();
                }

                // Promote-first ordering: put active promotions at the top, keep price ordering within groups
                $promoted = $sortedCards->filter(function ($card) {
                    return \App\Models\PromotionCard::active()->where('card_id', $card->sellerInventory->id)->exists();
                });
                $regular = $sortedCards->reject(function ($card) {
                    return \App\Models\PromotionCard::active()->where('card_id', $card->sellerInventory->id)->exists();
                });
                $sortedCards = $promoted->concat($regular);
                
                // Convert back to query builder for pagination
                $cardIds = $sortedCards->pluck('id')->toArray();
                $query = CardRequest::with('sellerInventory.user')
                    ->whereIn('id', $cardIds)
                    ->where('request_status', 'approved');
                
                // We'll handle pagination manually
                $perPage = $request->get('limit', 12);
                $page = $request->get('page', 1);
                $offset = ($page - 1) * $perPage;
                $paginatedCards = $sortedCards->slice($offset, $perPage);
                
                // Create a custom paginator
                $cards = new \Illuminate\Pagination\LengthAwarePaginator(
                    $paginatedCards->values(), // Convert to array with proper indices
                    $sortedCards->count(),
                    $perPage,
                    $page,
                    ['path' => $request->url()]
                );
                
                // Skip the normal pagination below
                goto transform_data;
            } else {
                // Fetch all, then order by created_at desc, then apply promoted-first, then manually paginate
                $query->orderBy($sortBy, 'desc');
                $allCards = $query->get();

                // Promote-first ordering
                $promoted = $allCards->filter(function ($card) {
                    return \App\Models\PromotionCard::active()->where('card_id', $card->sellerInventory->id)->exists();
                });
                $regular = $allCards->reject(function ($card) {
                    return \App\Models\PromotionCard::active()->where('card_id', $card->sellerInventory->id)->exists();
                });
                $sortedCards = $promoted->concat($regular);

                // Manual pagination
                $perPage = $request->get('limit', 12);
                $page = $request->get('page', 1);
                $offset = ($page - 1) * $perPage;
                $cards = new \Illuminate\Pagination\LengthAwarePaginator(
                    $sortedCards->slice($offset, $perPage)->values(),
                    $sortedCards->count(),
                    $perPage,
                    $page,
                    ['path' => $request->url()]
                );
                
                goto transform_data;
            }
            
            $perPage = $request->get('limit', 12);
            $cards = $query->paginate($perPage);
            
            transform_data:
            // Transform the data for frontend
            $transformedData = $cards->getCollection()->map(function ($request) {
                $inventory = $request->sellerInventory;
                $isPromoted = \App\Models\PromotionCard::active()->where('card_id', $inventory->id)->exists();
                return [
                    // Use SellerInventory primary key as the top-level id
                    'id' => $inventory->id,
                    // Keep CardRequest id for reference
                    'card_request_id' => $request->id,
                    // Explicitly include SellerInventory primary key too for clarity
                    'seller_inventory_id' => $inventory->id,
                    // Keep legacy fields for compatibility
                    'card_id' => $request->card_id,
                    'request_status' => $request->request_status,
                    'created_at' => $request->created_at,
                    'updated_at' => $request->updated_at,
                    // Card details
                    'card_title' => $inventory->card_title,
                    'description' => $inventory->description,
                    'price' => $inventory->price,
                    'price_type' => $inventory->price_type,
                    'condition' => $inventory->condition,
                    'grade' => $inventory->grade,
                    'sport_type' => $inventory->sport_type,
                    'weight' => $inventory->weight,
                    'images' => $inventory->images,
                    // Seller info
                    'seller' => [
                        'id' => $inventory->user->id,
                        'name' => $inventory->user->profile && $inventory->user->profile->username 
                            ? $inventory->user->profile->username 
                            : $inventory->user->name,
                        'email' => $inventory->user->email,
                    ],
                    // Include the full inventory for any consumers still relying on it
                    'seller_inventory' => $inventory,
                    'is_promoted' => $isPromoted,
                ];
            });
            
            $transformedCards = new \Illuminate\Pagination\LengthAwarePaginator(
                $transformedData,
                $cards->total(),
                $cards->perPage(),
                $cards->currentPage(),
                ['path' => $cards->path()]
            );
            
            return ResponseService::successWithPagination('Active cards retrieved successfully', $transformedCards);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to retrieve active cards', $e->getMessage());
        }
    }

    /**
     * Show single active card for buyers (public endpoint)
     */
    public function showActiveCard($id)
    {
        try {
            // Accept either CardRequest ID or SellerInventory ID
            $cardRequest = CardRequest::with('sellerInventory.user.profile')
                ->where(function ($q) use ($id) {
                    $q->where('id', $id)
                      ->orWhere('card_id', $id);
                })
                ->where('request_status', 'approved')
                ->first();
            
            if (!$cardRequest) {
                return ResponseService::error('Card not found or not approved', null, 404);
            }
            
            $inventory = $cardRequest->sellerInventory;
            $user = $inventory->user;
            
            // Get username from profile, fallback to name if no profile
            $displayName = $user->profile && $user->profile->username 
                ? $user->profile->username 
                : $user->name;
            
            $transformedData = [
                // Use SellerInventory id as top-level id
                'id' => $inventory->id,
                // Preserve CardRequest id separately
                'card_request_id' => $cardRequest->id,
                'card_id' => $cardRequest->card_id,
                'request_status' => $cardRequest->request_status,
                'created_at' => $cardRequest->created_at,
                'updated_at' => $cardRequest->updated_at,
                // Card details
                'card_title' => $inventory->card_title,
                'description' => $inventory->description,
                'price' => $inventory->price,
                'price_type' => $inventory->price_type,
                'condition' => $inventory->condition,
                'sport_type' => $inventory->sport_type,
                'weight' => $inventory->weight,
                'images' => $inventory->images,
                // Seller info
                'seller' => [
                    'id' => $user->id,
                    'name' => $displayName,
                    'email' => $user->email,
                ],
                'seller_inventory' => $inventory,
            ];
            
            // Auto-track promotion view on page open (exclude owner if authenticated) with short-term de-duplication
            try {
                $promotion = \App\Models\PromotionCard::active()->where('card_id', $inventory->id)->first();
                if ($promotion) {
                    $viewer = request()->user();
                    if (!$viewer || (int)$viewer->id !== (int)$promotion->user_id) {
                        // Deduplicate rapid double-calls (SSR/CSR) using cache key per viewer
                        $viewerKey = $viewer ? ('u_'.$viewer->id) : ('ip_'.request()->ip());
                        $cacheKey = 'promo_view_once:'.$promotion->id.':'.$viewerKey;
                        if (!\Illuminate\Support\Facades\Cache::has($cacheKey)) {
                            \Illuminate\Support\Facades\Cache::put($cacheKey, 1, now()->addSeconds(20));
                            $promotion->increment('promotion_views');
                            if ($promotion->promotion_type === 'impression' && $promotion->max_views && $promotion->promotion_views >= $promotion->max_views) {
                                $promotion->is_active = false;
                                $promotion->save();
                            }
                        }
                    }
                }
            } catch (\Throwable $t) {}
            
            return ResponseService::success('Card retrieved successfully', $transformedData);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to retrieve card', $e->getMessage());
        }
    }
}
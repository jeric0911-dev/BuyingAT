<?php

namespace App\Http\Controllers;

use App\Http\Controllers\BaseController;
use App\Models\AffiliateCommission;
use App\Models\Order;
use App\Models\Referral;
use App\Models\User;
use Illuminate\Http\Request;

class AffiliateController extends BaseController
{
    /**
     * Get affiliate stats for the currently authenticated user.
     *
     * Returns:
     * - total_referred_users
     * - total_referred_orders
     * - total_referred_sales_volume
     * - total_commissions
     * - pending_commissions
     * - paid_commissions
     */
    public function getMyAffiliateStats(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return $this->sendErrorResponse('Unauthorized', 401);
        }

        $referrerId = $user->id;

        // Total referred users
        $totalReferredUsers = Referral::where('referrer_id', $referrerId)->count();

        // All commissions for this referrer
        $commissionsQuery = AffiliateCommission::where('referrer_id', $referrerId);

        $totalCommissions = (float) $commissionsQuery->sum('amount');
        $pendingCommissions = (float) $commissionsQuery->where('status', 'pending')->sum('amount');
        $paidCommissions = (float) $commissionsQuery->where('status', 'paid')->sum('amount');

        // Unique orders that generated commissions for this referrer
        $orderIds = AffiliateCommission::where('referrer_id', $referrerId)
            ->whereNotNull('order_id')
            ->pluck('order_id')
            ->unique()
            ->values();

        $totalReferredOrders = $orderIds->count();
        $totalReferredSalesVolume = 0;

        if ($orderIds->isNotEmpty()) {
            $totalReferredSalesVolume = (float) Order::whereIn('id', $orderIds)->sum('amount');
        }

        return $this->sendSuccessResponse('Affiliate stats retrieved successfully', [
            'total_referred_users' => $totalReferredUsers,
            'total_referred_orders' => $totalReferredOrders,
            'total_referred_sales_volume' => $totalReferredSalesVolume,
            'total_commissions' => $totalCommissions,
            'pending_commissions' => $pendingCommissions,
            'paid_commissions' => $paidCommissions,
        ]);
    }

    /**
     * (Admin) Get affiliate stats for a specific user by ID.
     * You can protect this route with admin middleware in routes.
     */
    public function getAffiliateStatsForUser($userId)
    {
        $user = User::find($userId);
        if (!$user) {
            return $this->sendErrorResponse('User not found', 404);
        }

        $referrerId = $user->id;

        $totalReferredUsers = Referral::where('referrer_id', $referrerId)->count();

        $commissionsQuery = AffiliateCommission::where('referrer_id', $referrerId);

        $totalCommissions = (float) $commissionsQuery->sum('amount');
        $pendingCommissions = (float) $commissionsQuery->where('status', 'pending')->sum('amount');
        $paidCommissions = (float) $commissionsQuery->where('status', 'paid')->sum('amount');

        $orderIds = AffiliateCommission::where('referrer_id', $referrerId)
            ->whereNotNull('order_id')
            ->pluck('order_id')
            ->unique()
            ->values();

        $totalReferredOrders = $orderIds->count();
        $totalReferredSalesVolume = 0;

        if ($orderIds->isNotEmpty()) {
            $totalReferredSalesVolume = (float) Order::whereIn('id', $orderIds)->sum('amount');
        }

        return $this->sendSuccessResponse('Affiliate stats retrieved successfully', [
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'total_referred_users' => $totalReferredUsers,
            'total_referred_orders' => $totalReferredOrders,
            'total_referred_sales_volume' => $totalReferredSalesVolume,
            'total_commissions' => $totalCommissions,
            'pending_commissions' => $pendingCommissions,
            'paid_commissions' => $paidCommissions,
        ]);
    }
}



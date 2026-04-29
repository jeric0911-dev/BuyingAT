<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\BaseController;
use App\Models\BuyerProfileRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class BuyerApprovalController extends BaseController
{
    /**
     * Get all pending buyer profile requests
     */
    public function index()
    {
        try {
            Log::info('🔍 BuyerApprovalController: Fetching pending buyer requests');

            $requests = BuyerProfileRequest::with(['user.profile'])
                ->where('request_status', 'pending')
                ->orderBy('requested_at', 'asc')
                ->get();

            Log::info('✅ BuyerApprovalController: Retrieved buyer requests', [
                'count' => $requests->count()
            ]);

            return $this->sendSuccessResponse('Buyer requests retrieved successfully', $requests);
        } catch (\Exception $e) {
            Log::error('💥 BuyerApprovalController: Error fetching requests', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->sendErrorResponse('Failed to fetch buyer requests', 500);
        }
    }

    /**
     * Get all buyer requests (pending, approved, rejected)
     */
    public function getAll()
    {
        try {
            Log::info('🔍 BuyerApprovalController: Fetching all buyer requests');

            $requests = BuyerProfileRequest::with(['user.profile'])
                ->orderBy('requested_at', 'asc')
                ->get();

            Log::info('✅ BuyerApprovalController: Retrieved all buyer requests', [
                'count' => $requests->count()
            ]);

            return $this->sendSuccessResponse('All buyer requests retrieved successfully', $requests);
        } catch (\Exception $e) {
            Log::error('💥 BuyerApprovalController: Error fetching all requests', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->sendErrorResponse('Failed to fetch buyer requests', 500);
        }
    }

    /**
     * Approve a buyer profile request
     */
    public function approve(Request $request, $id)
    {
        try {
            Log::info('✅ BuyerApprovalController: Approving buyer request', [
                'request_id' => $id
            ]);

            $buyerRequest = BuyerProfileRequest::findOrFail($id);
            
            if ($buyerRequest->request_status !== 'pending') {
                return $this->sendErrorResponse('Request is not pending', 400);
            }

            // Update request status
            $buyerRequest->update([
                'request_status' => 'approved',
                'approved_at' => now()
            ]);

            // Update existing role from seller to buyer (no duplicate user_id)
            $user = $buyerRequest->user;
            
            // Find and update the existing role (should be 'seller' by default)
            $existingRole = $user->userRoles()->first();
            
            if ($existingRole) {
                // Update existing role to buyer
                $existingRole->update([
                    'role' => 'buyer',
                    'updated_at' => now()
                ]);
                
                Log::info('👤 BuyerApprovalController: Updated existing role to buyer', [
                    'user_id' => $user->id,
                    'role_id' => $existingRole->id,
                    'old_role' => 'seller',
                    'new_role' => 'buyer'
                ]);
            } else {
                // Fallback: create buyer role if no existing role found
                $user->userRoles()->create([
                    'role' => 'buyer'
                ]);
                
                Log::info('👤 BuyerApprovalController: Created buyer role (fallback)', [
                    'user_id' => $user->id,
                    'role' => 'buyer'
                ]);
            }

            Log::info('🎉 BuyerApprovalController: Buyer request approved successfully', [
                'request_id' => $id,
                'user_id' => $user->id,
                'username' => $user->profile->username ?? 'N/A'
            ]);

            return $this->sendSuccessResponse('Buyer request approved successfully', $buyerRequest->load('user.profile'));
        } catch (\Exception $e) {
            Log::error('💥 BuyerApprovalController: Error approving request', [
                'request_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->sendErrorResponse('Failed to approve buyer request', 500);
        }
    }

    /**
     * Reject a buyer profile request
     */
    public function reject(Request $request, $id)
    {
        try {
            Log::info('❌ BuyerApprovalController: Rejecting buyer request', [
                'request_id' => $id
            ]);

            $buyerRequest = BuyerProfileRequest::findOrFail($id);
            
            if ($buyerRequest->request_status !== 'pending') {
                return $this->sendErrorResponse('Request is not pending', 400);
            }

            // Update request status
            $buyerRequest->update([
                'request_status' => 'rejected',
                'approved_at' => now()
            ]);

            Log::info('🚫 BuyerApprovalController: Buyer request rejected successfully', [
                'request_id' => $id,
                'user_id' => $buyerRequest->user_id
            ]);

            return $this->sendSuccessResponse('Buyer request rejected successfully', $buyerRequest->load('user.profile'));
        } catch (\Exception $e) {
            Log::error('💥 BuyerApprovalController: Error rejecting request', [
                'request_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->sendErrorResponse('Failed to reject buyer request', 500);
        }
    }

    /**
     * Get buyer approval statistics
     */
    public function statistics()
    {
        try {
            Log::info('📊 BuyerApprovalController: Fetching approval statistics');

            $stats = [
                'total_requests' => BuyerProfileRequest::count(),
                'pending_requests' => BuyerProfileRequest::where('request_status', 'pending')->count(),
                'approved_requests' => BuyerProfileRequest::where('request_status', 'approved')->count(),
                'rejected_requests' => BuyerProfileRequest::where('request_status', 'rejected')->count(),
            ];

            Log::info('✅ BuyerApprovalController: Statistics retrieved', $stats);

            return $this->sendSuccessResponse('Statistics retrieved successfully', $stats);
        } catch (\Exception $e) {
            Log::error('💥 BuyerApprovalController: Error fetching statistics', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->sendErrorResponse('Failed to fetch statistics', 500);
        }
    }
}
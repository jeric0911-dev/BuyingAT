<?php

namespace App\Http\Controllers;

use App\Models\UserStatus;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class UserStatusController extends Controller
{
    /**
     * Mark user as online.
     */
    public function markOnline(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->id;
            UserStatus::markOnline($userId);
            
            return response()->json([
                'status' => 'success',
                'message' => 'User marked as online',
                'data' => [
                    'user_id' => $userId,
                    'is_online' => true,
                    'last_seen' => now()->toISOString(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to mark user as online',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark user as offline.
     */
    public function markOffline(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->id;
            UserStatus::markOffline($userId);
            
            return response()->json([
                'status' => 'success',
                'message' => 'User marked as offline',
                'data' => [
                    'user_id' => $userId,
                    'is_online' => false,
                    'last_seen' => now()->toISOString(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to mark user as offline',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update user's last seen timestamp.
     */
    public function updateLastSeen(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->id;
            UserStatus::updateLastSeen($userId);
            
            return response()->json([
                'status' => 'success',
                'message' => 'Last seen updated',
                'data' => [
                    'user_id' => $userId,
                    'last_seen' => now()->toISOString(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update last seen',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get user's current status.
     */
    public function getStatus(Request $request): JsonResponse
    {
        try {
            $userId = $request->user()->id;
            $status = UserStatus::where('user_id', $userId)->first();
            
            if (!$status) {
                return response()->json([
                    'status' => 'success',
                    'data' => [
                        'user_id' => $userId,
                        'is_online' => false,
                        'last_seen' => null,
                    ]
                ]);
            }
            
            return response()->json([
                'status' => 'success',
                'data' => [
                    'user_id' => $status->user_id,
                    'is_online' => $status->is_online,
                    'last_seen' => $status->last_seen?->toISOString(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to get user status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get status of a specific user by ID.
     */
    public function getUserStatusById(Request $request, $userId): JsonResponse
    {
        try {
            // Debug logging
            \Log::info("getUserStatusById called for user: {$userId}");
            \Log::info("Auth check: " . (Auth::check() ? 'true' : 'false'));
            \Log::info("Request headers: " . json_encode($request->headers->all()));
            
            // Validate userId
            if (!is_numeric($userId) || $userId <= 0) {
                \Log::warning("Invalid userId: {$userId}");
                return response()->json([
                    'status' => 'error',
                    'message' => 'Invalid user ID',
                ], 400);
            }
            
            // Check if user is authenticated
            if (!Auth::check()) {
                \Log::warning("User not authenticated for getUserStatusById");
                return response()->json([
                    'status' => 'error',
                    'message' => 'Unauthenticated',
                ], 401);
            }
            
            \Log::info("Looking for status for user ID: {$userId}");
            $status = UserStatus::where('user_id', $userId)->first();
            \Log::info("Status found: " . ($status ? 'yes' : 'no'));
            
            if (!$status) {
                \Log::info("No status record found, returning default offline status");
                return response()->json([
                    'status' => 'success',
                    'data' => [
                        'user_id' => $userId,
                        'is_online' => false,
                        'last_seen' => null,
                    ]
                ]);
            }
            
            \Log::info("Returning status: is_online={$status->is_online}, last_seen={$status->last_seen}");
            return response()->json([
                'status' => 'success',
                'data' => [
                    'user_id' => $status->user_id,
                    'is_online' => $status->is_online,
                    'last_seen' => $status->last_seen?->toISOString(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to get user status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all online users.
     */
    public function getOnlineUsers(): JsonResponse
    {
        try {
            $onlineUsers = UserStatus::with('user')
                ->where('is_online', true)
                ->orderBy('last_seen', 'desc')
                ->get()
                ->map(function ($status) {
                    return [
                        'user_id' => $status->user_id,
                        'user_name' => $status->user->name ?? 'Unknown',
                        'is_online' => $status->is_online,
                        'last_seen' => $status->last_seen?->toISOString(),
                    ];
                });
            
            return response()->json([
                'status' => 'success',
                'data' => $onlineUsers
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to get online users',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

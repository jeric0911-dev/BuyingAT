<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\ContactViolationService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class ContactViolationController extends Controller
{
    /**
     * Track contact violation
     */
    public function trackViolation(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'User not authenticated'
                ], 401);
            }

            $request->validate([
                'violations' => 'required|array',
                'violations.*' => 'string|in:email,url,phone,social,contact_terms,chat_handles,social_platforms',
                'content' => 'required|string|max:1000',
                'context' => 'string|in:chat,post,comment,profile'
            ]);

            $violations = $request->input('violations');
            $content = $request->input('content');
            $context = $request->input('context', 'chat');

            // Track the violation
            $success = ContactViolationService::trackViolation($user, $violations, $content, $context);

            if ($success) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'Violation tracked successfully'
                ]);
            } else {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Failed to track violation'
                ], 500);
            }

        } catch (\Exception $e) {
            Log::error('Contact violation tracking error', [
                'error' => $e->getMessage(),
                'user_id' => Auth::id(),
                'request_data' => $request->all()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while tracking violation'
            ], 500);
        }
    }

    /**
     * Get user's violation statistics
     */
    public function getUserViolations(): JsonResponse
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'User not authenticated'
                ], 401);
            }

            $stats = ContactViolationService::getUserViolationStats($user);

            return response()->json([
                'status' => 'success',
                'data' => $stats
            ]);

        } catch (\Exception $e) {
            Log::error('Get user violations error', [
                'error' => $e->getMessage(),
                'user_id' => Auth::id()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Failed to retrieve violation data'
            ], 500);
        }
    }

    /**
     * Get violation summary (admin only)
     */
    public function getViolationSummary(Request $request): JsonResponse
    {
        try {
            // Check if user is admin (you may need to adjust this based on your admin system)
            $user = Auth::user();
            if (!$user || $user->role !== 'admin') {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Unauthorized'
                ], 403);
            }

            $days = $request->input('days', 30);
            $summary = ContactViolationService::getViolationSummary($days);

            return response()->json([
                'status' => 'success',
                'data' => $summary
            ]);

        } catch (\Exception $e) {
            Log::error('Get violation summary error', [
                'error' => $e->getMessage(),
                'admin_id' => Auth::id()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Failed to retrieve violation summary'
            ], 500);
        }
    }

    /**
     * Clear user violations (admin only)
     */
    public function clearUserViolations(Request $request): JsonResponse
    {
        try {
            // Check if user is admin
            $user = Auth::user();
            if (!$user || $user->role !== 'admin') {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Unauthorized'
                ], 403);
            }

            $request->validate([
                'user_id' => 'required|integer|exists:users,id'
            ]);

            $targetUser = User::findOrFail($request->input('user_id'));
            $success = ContactViolationService::clearUserViolations($targetUser);

            if ($success) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'User violations cleared successfully'
                ]);
            } else {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Failed to clear violations'
                ], 500);
            }

        } catch (\Exception $e) {
            Log::error('Clear user violations error', [
                'error' => $e->getMessage(),
                'admin_id' => Auth::id(),
                'target_user_id' => $request->input('user_id')
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while clearing violations'
            ], 500);
        }
    }
}

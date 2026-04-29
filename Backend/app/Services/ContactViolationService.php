<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Log;

class ContactViolationService
{
    /**
     * Track contact violation for a user
     */
    public static function trackViolation(User $user, array $violations, string $content, string $context = 'chat')
    {
        try {
            // Log the violation for monitoring
            Log::warning('Contact violation detected', [
                'user_id' => $user->id,
                'user_email' => $user->email,
                'violations' => $violations,
                'content' => $content,
                'context' => $context,
                'ip' => request()->ip(),
                'user_agent' => request()->userAgent()
            ]);

            // Add each violation type to the user's blacklist
            foreach ($violations as $violationType) {
                $user->addViolation($violationType, $content, $context);
            }

            // Check if user has excessive violations
            if ($user->hasExcessiveViolations()) {
                Log::alert('User has excessive contact violations', [
                    'user_id' => $user->id,
                    'violation_count' => $user->violation_count,
                    'last_violation' => $user->last_violation_at
                ]);
            }

            return true;
        } catch (\Exception $e) {
            Log::error('Failed to track contact violation', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
                'violations' => $violations
            ]);
            return false;
        }
    }

    /**
     * Get user violation statistics
     */
    public static function getUserViolationStats(User $user)
    {
        return $user->getViolationStats();
    }

    /**
     * Check if user should be restricted
     */
    public static function shouldRestrictUser(User $user, int $threshold = 10)
    {
        return $user->hasExcessiveViolations($threshold);
    }

    /**
     * Get violation summary for admin dashboard
     */
    public static function getViolationSummary($days = 30)
    {
        $users = User::where('violation_count', '>', 0)
            ->where('last_violation_at', '>=', now()->subDays($days))
            ->get();

        $summary = [
            'total_users_with_violations' => $users->count(),
            'total_violations' => $users->sum('violation_count'),
            'users_with_excessive_violations' => $users->filter(function ($user) {
                return $user->hasExcessiveViolations();
            })->count(),
            'violations_by_type' => [],
            'violations_by_context' => [],
            'recent_violations' => []
        ];

        foreach ($users as $user) {
            $stats = $user->getViolationStats();
            
            // Aggregate violation types
            foreach ($stats['violations_by_type'] as $type => $count) {
                $summary['violations_by_type'][$type] = ($summary['violations_by_type'][$type] ?? 0) + $count;
            }
            
            // Aggregate violation contexts
            foreach ($stats['violations_by_context'] as $context => $count) {
                $summary['violations_by_context'][$context] = ($summary['violations_by_context'][$context] ?? 0) + $count;
            }
            
            // Add recent violations
            $summary['recent_violations'] = array_merge($summary['recent_violations'], $stats['recent_violations']);
        }

        return $summary;
    }

    /**
     * Clear violations for a user (admin function)
     */
    public static function clearUserViolations(User $user)
    {
        try {
            $user->clearBlacklist();
            
            Log::info('User violations cleared', [
                'user_id' => $user->id,
                'admin_id' => auth()->id() ?? 'system'
            ]);
            
            return true;
        } catch (\Exception $e) {
            Log::error('Failed to clear user violations', [
                'user_id' => $user->id,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
}

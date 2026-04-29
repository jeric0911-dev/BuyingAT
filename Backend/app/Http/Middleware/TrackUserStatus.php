<?php

namespace App\Http\Middleware;

use App\Models\UserStatus;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class TrackUserStatus
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Only track status for authenticated users
        if (Auth::check()) {
            $userId = Auth::id();
            
            // Update last seen timestamp for any authenticated request
            try {
                \Log::info("Middleware: Updating last seen for user {$userId}");
                UserStatus::updateLastSeen($userId);
            } catch (\Exception $e) {
                \Log::error('Failed to update user status in middleware: ' . $e->getMessage());
            }
        }

        return $response;
    }
}

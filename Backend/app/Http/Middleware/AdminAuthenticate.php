<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminAuthenticate
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next): Response
    {
        $admin = Auth::guard('admin-api')->user();

        if (!$admin || !$admin->currentAccessToken() || !$admin->hasPermissionTo($permission, 'admin')) {
            return response()->json([
                'message' => 'Unauthenticated (admin).'
            ], Response::HTTP_UNAUTHORIZED);
        }

        return $next($request);
    }
}

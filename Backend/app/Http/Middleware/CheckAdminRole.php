<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckAdminRole
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $admin = auth('admin-api')->user();

        if (!$admin || !in_array($admin->role, $roles)) {
            return response()->json([
                'message' => 'Forbidden (insufficient role).'
            ], 403);
        }

        return $next($request);
    }
}

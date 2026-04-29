<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminHasPermission
{
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $admin = Auth::guard('admin-api')->user();

        if (!$admin || !$admin->hasPermissionTo($permission, 'admin')) {
            return response()->json([
                'message' => 'Forbidden — missing permission: ' . $permission,
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}

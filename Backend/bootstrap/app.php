<?php

use App\Http\Middleware\AdminAuthenticate;
use App\Http\Middleware\AdminHasPermission;
use App\Http\Middleware\UserAuthenticate;
use App\Http\Middleware\CheckAdminRole;
use App\Http\Middleware\TrackUserStatus;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

use App\Services\ResponseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Database\QueryException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Session\TokenMismatchException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Symfony\Component\HttpKernel\Exception\ThrottleRequestsException;
use Illuminate\Http\Exceptions\PostTooLargeException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'admin' => AdminAuthenticate::class,
            'user' => UserAuthenticate::class,
            'admin.role' => CheckAdminRole::class,
            'admin.permission' => AdminHasPermission::class,
            'track.user.status' => TrackUserStatus::class,
        ]);
    })


    ->withExceptions(function (Exceptions $exceptions) {
        // Validation failed
        $exceptions->render(function (ValidationException $e, Request $request) {
            return ResponseService::error('Validation failed', $e->errors(), 422);
        });

        // Model not found
        $exceptions->render(function (ModelNotFoundException $e, Request $request) {
            $modelClass = $e->getModel();
            $modelName = class_basename($modelClass);
            return ResponseService::error("$modelName not found", null, 404);
        });

        // Method not allowed
        $exceptions->render(function (MethodNotAllowedHttpException $e, Request $request) {
            return ResponseService::error('HTTP method not allowed', null, 405);
        });

        // Unauthenticated
        $exceptions->render(function (AuthenticationException $e, Request $request) {
            return ResponseService::error('Unauthenticated', null, 401);
        });

        // Unauthorized access
        $exceptions->render(function (AuthorizationException|AccessDeniedHttpException $e, Request $request) {
            return ResponseService::error('Unauthorized', null, 403);
        });

        // CSRF token mismatch
        $exceptions->render(function (TokenMismatchException $e, Request $request) {
            return ResponseService::error('Session expired. Please refresh the page and try again.', null, 419);
        });

        // Too many requests
        $exceptions->render(function (ThrottleRequestsException $e, Request $request) {
            return ResponseService::error('Too many requests. Please try again later.', null, 429);
        });

        // File too large
        $exceptions->render(function (PostTooLargeException $e, Request $request) {
            return ResponseService::error('Uploaded file is too large.', null, 413);
        });

        // DB query error
        $exceptions->render(function (QueryException $e, Request $request) {
            return ResponseService::error('Database error occurred.', $e->getMessage(), 500);
        });

        // HTTP exception with custom message
        $exceptions->render(function (HttpException $e, Request $request) {
            return ResponseService::error($e->getMessage(), null, $e->getStatusCode());
        });

        // Fallback - catch all
        $exceptions->render(function (Throwable $e, Request $request) {
            Log::error('Exception - ' . $e);
            return ResponseService::error('Something went wrong. Please try again.', $e->getMessage(), 500);
        });
    })
    ->create();

<?php

namespace App\Exceptions;

use Throwable;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Database\QueryException;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Http\Exceptions\PostTooLargeException;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Routing\Router;
use Illuminate\Session\TokenMismatchException;
use Illuminate\Support\Facades\Log;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use App\Services\ResponseService;

class Handler extends ExceptionHandler
{
    protected $dontReport = [];

    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    public function report(Throwable $exception)
    {
        parent::report($exception);
    }

    public function register(): void
    {
        $this->renderable(function (ModelNotFoundException $e, $request) {
            $modelClass = $e->getModel();
            $modelName = class_basename($modelClass);
            return ResponseService::error("$modelName not found", null, 404);
        });
    }

    public function render($request, Throwable $exception)
    {
        Log::error('Exception-'.$exception);

        // Validation failed
        if ($exception instanceof ValidationException) {
            return ResponseService::error('Validation failed', $exception->errors(), 422);
        }

        // Model not found
        if ($exception instanceof ModelNotFoundException) {
            $modelClass = $exception->getModel();
            $modelName = class_basename($modelClass);
            return ResponseService::error("$modelName not found", null, 404);
        }


        // Route not found
        if ($exception instanceof NotFoundHttpException) {
            return ResponseService::error('Route not found', null, 404);
        }

        // Method not allowed (wrong HTTP verb)
        if ($exception instanceof MethodNotAllowedHttpException) {
            return ResponseService::error('HTTP method not allowed', null, 405);
        }

        // Unauthenticated
        if ($exception instanceof AuthenticationException) {
            return ResponseService::error('Unauthenticated', null, 401);
        }

        // Unauthorized access (access denied)
        if ($exception instanceof AuthorizationException || $exception instanceof AccessDeniedHttpException) {
            return ResponseService::error('Unauthorized', null, 403);
        }

        // CSRF Token Mismatch (mostly in web apps)
        if ($exception instanceof TokenMismatchException) {
            return ResponseService::error('Session expired. Please refresh the page and try again.', null, 419);
        }

        // Too many requests
        if ($exception instanceof ThrottleRequestsException) {
            return ResponseService::error('Too many requests. Please try again later.', null, 429);
        }

        // Request too large (file upload)
        if ($exception instanceof PostTooLargeException) {
            return ResponseService::error('Uploaded file is too large.', null, 413);
        }

        // Database query error
        if ($exception instanceof QueryException) {
            return ResponseService::error('Database error occurred.', $exception->getMessage(), 500);
        }

        // Generic HTTP exception (with custom status)
        if ($exception instanceof HttpException) {
            return ResponseService::error($exception->getMessage(), null, $exception->getStatusCode());
        }

        // Default fallback (any other unhandled exception)
        return ResponseService::error('Something went wrong. Please try again.', $exception->getMessage(), 500);
    }
}

<?php

namespace App\Http\Controllers;

use App\Services\ResponseService;
use Illuminate\Http\JsonResponse;
use Throwable;

class BaseController extends Controller
{
    //handle success
    protected function sendSuccessResponse(string $message, $data = null, int $statusCode = 200): JsonResponse
    {
        return ResponseService::success($message, $data, $statusCode);
    }

    //handle error
    protected function sendErrorResponse(string $fallbackMessage, $error = null, int $statusCode = 400): JsonResponse
    {
        return ResponseService::error($fallbackMessage, $error, $statusCode);
    }

    //paginated success
    protected function sendPaginatedResponse(string $message, $paginator, int $statusCode = 200): JsonResponse
    {
        return ResponseService::successWithPagination($message, $paginator, $statusCode);
    }

    protected function sendPaginatedResponse2(
        string $message,
        $paginator,
        int $statusCode = 200,
        array $parentData = [],
        string $nestedKey = 'items'
    ): JsonResponse {
        return ResponseService::successWithPagination2($message, $paginator, $statusCode, $parentData, $nestedKey);
    }


    //nested paginated success
    protected function sendNestedPaginatedResponse(string $message, array $parent, $paginator, int $statusCode = 200): JsonResponse
    {
        return ResponseService::successWithNestedPagination($message, $parent, $paginator, $statusCode);
    }

    //validation error response
    protected function sendValidationErrorResponse($validator, string $message = 'Validation failed'): JsonResponse
    {
        return response()->json([
            'status' => 'error',
            'message' => $message,
            'errors' => $validator->errors(),
        ], 422);
    }
}

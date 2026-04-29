<?php

namespace App\Services;

use Illuminate\Http\JsonResponse;
use Illuminate\Pagination\LengthAwarePaginator;

class ResponseService
{
    // Standard success response
    public static function success(string $message, $data = null, int $statusCode = 200): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => $data,
        ], $statusCode);
    }

    // Standard error response
    public static function error(string $message, $error = null, int $statusCode = 400): JsonResponse
    {
        return response()->json([
            'status' => 'error',
            'message' => $message,
            'error' => $error,
        ], $statusCode);
    }

    // Paginated success response
    public static function successWithPagination(string $message, LengthAwarePaginator $paginator, int $statusCode = 200): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => $paginator->items(),
            'pagination' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'last_page' => $paginator->lastPage(),
            ]
        ], $statusCode);
    }

    //success with parent data
    public static function successWithPagination2(
        string $message,
        LengthAwarePaginator $paginator,
        int $statusCode = 200,
        array $parentData = [],
        string $nestedKey = 'items'
    ): JsonResponse {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => array_merge($parentData, [
                $nestedKey => $paginator->items(),
                'pagination' => [
                    'current_page' => $paginator->currentPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                    'last_page' => $paginator->lastPage(),
                ]
            ]),
        ], $statusCode);
    }

    //success with nested pagination
    public static function successWithNestedPagination(
        string $message,
        array $parentData,
        LengthAwarePaginator $paginator,
        int $statusCode = 200
    ): JsonResponse {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => array_merge($parentData, [
                'blogs' => $paginator->items(),
                'pagination' => [
                    'current_page' => $paginator->currentPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                    'last_page' => $paginator->lastPage(),
                ]
            ]),
        ], $statusCode);
    }
}

<?php

namespace App\Http\Controllers\admin\adminDashboard;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use Illuminate\Http\Request;

class UserDashboardDataController extends BaseController
{
    // Get product by user
    public function getProductByUser(Request $request)
    {
        $products = Product::with([
                'getCategory',
                'getCountry',
                'getCity',
                'getGalleryImage',
                'colors',
                'sizes',
                'getAdvertInfo',
                'getProductUser'
            ])
            ->where('user_id', $request->input('user_id'))
            ->orderBy('created_at', 'desc')
            ->get();

        if ($products->isEmpty()) {
            return $this->sendErrorResponse('No products found for this user', 404);
        }

        return $this->sendSuccessResponse('Product retrieved successfully', $products);
    }

    // Admin dashboard product filter
    public function dataFilter(Request $request)
    {
        $status = $request->input('status');
        $query = Product::query();

        if ($status) {
            $query->where('status', $status);
        }

        $results = $query->with([
                'getCategory',
                'getCountry',
                'getCity',
                'getGalleryImage',
                'colors',
                'sizes',
                'getAdvertInfo',
                'getProductUser'
            ])
            ->orderBy('created_at', 'desc')
            ->get();

        return $this->sendSuccessResponse('Product filtered successfully', $results);
    }
}

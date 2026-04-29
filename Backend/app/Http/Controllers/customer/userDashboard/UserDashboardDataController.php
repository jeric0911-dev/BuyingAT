<?php

namespace App\Http\Controllers\customer\userDashboard;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use Illuminate\Http\Request;

class UserDashboardDataController extends BaseController
{
    // Get product by user
    public function getProductByUser(Request $request)
    {
        $status = $request->status;

        $getProductByUser = Product::with(
            'getCategory',
            'getCountry',
            'getCity',
            'getGalleryImage',
            'colors',
            'sizes',
            'getAdvertInfo',
            'getProductUser'
        )->where('user_id', auth()->user()->id);

        if ($status) {
            $getProductByUser->where('status', $status);
        }

        $getProductByUser = $getProductByUser->orderBy('created_at', 'desc')->get();

        if ($getProductByUser->isEmpty()) {
            return $this->sendErrorResponse('No products found for the user');
        }

        return $this->sendSuccessResponse('Products retrieved successfully', $getProductByUser);
    }
}

<?php

namespace App\Http\Controllers\customer\coupon;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Coupon;
use App\Services\ResponseService;

class CouponController extends BaseController
{
    // Get all coupons
    public function index(Request $request)
    {
        $coupons = Coupon::all();
        if ($coupons->isEmpty()) {
            return $this->sendErrorResponse('No coupons found', [], 404);
        }
        return $this->sendSuccessResponse('Coupons retrieved successfully', $coupons);
    }

    // Get single coupon
    public function show($id)
    {
        $coupon = Coupon::findOrFail($id);
        return $this->sendSuccessResponse('Coupon retrieved successfully', $coupon);
    }
}

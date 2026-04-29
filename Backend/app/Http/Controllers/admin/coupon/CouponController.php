<?php

namespace App\Http\Controllers\admin\coupon;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Coupon;
use Illuminate\Http\Response;

class CouponController extends BaseController
{
    // Get paginated coupons
    public function index(Request $request)
    {
        $request->validate([
            'page' => 'required|integer|min:1',
            'limit' => 'required|integer|min:1',
        ]);

        $offset = ($request->page - 1) * $request->limit;

        $coupons = Coupon::orderBy('id', 'desc')
                         ->offset($offset)
                         ->limit($request->limit)
                         ->get();

        $total = Coupon::count();

        return $this->sendSuccessResponse('Coupons retrieved successfully', [
            'data' => $coupons,
            'total' => $total,
        ]);
    }

    // Store coupon
    public function store(Request $request)
    {
        $data = $request->validate([
            'code' => 'required|unique:coupons',
            'title' => 'required|string',
            'description' => 'required|string',
            'type' => 'required|string',
            'max_discount' => 'required|integer',
            'coupon_limit_per_user' => 'required|integer',
            'value' => 'required|numeric',
            'max_uses' => 'required|integer',
            'min_order_amount' => 'nullable|numeric',
            'is_active' => 'nullable|boolean',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $data['created_by'] = auth()->id();

        $coupon = Coupon::create($data);

        return $this->sendSuccessResponse('Coupon created successfully', $coupon, Response::HTTP_CREATED);
    }

    // Get single coupon
    public function show($id)
    {
        $coupon = Coupon::findOrFail($id);
        return $this->sendSuccessResponse('Coupon retrieved successfully', $coupon);
    }

    // Update coupon
    public function update(Request $request, $id)
    {
        $coupon = Coupon::findOrFail($id);

        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'type' => 'required|string',
            'max_discount' => 'required|integer',
            'coupon_limit_per_user' => 'required|integer',
            'value' => 'required|numeric',
            'max_uses' => 'required|integer',
            'min_order_amount' => 'nullable|numeric',
            'is_active' => 'nullable|boolean',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $coupon->update($data);

        return $this->sendSuccessResponse('Coupon updated successfully', $coupon);
    }

    // Delete coupon
    public function destroy($id)
    {
        $coupon = Coupon::findOrFail($id);

        $coupon->delete();

        return $this->sendSuccessResponse('Coupon deleted successfully', null, 204);
    }
}

<?php

namespace App\Http\Controllers\customer\billingAndShipping;

use App\Http\Controllers\BaseController;
use App\Models\ShippingAddress;
use Illuminate\Http\Request;

class ShippingAddressController extends BaseController
{
    // Get shipping address of authenticated user
    public function index()
    {
        $shippingAddress = ShippingAddress::where('user_id', auth()->id())->first();

        if (!$shippingAddress) {
            return $this->sendErrorResponse('Shipping address not found', [], 404);
        }

        return $this->sendSuccessResponse('Shipping address retrieved successfully', $shippingAddress);
    }

    // Create or update shipping address for authenticated user
    public function createOrUpdate(Request $request)
    {
        $data = $request->validate([
            'first_name' => 'required|string',
            'last_name' => 'required|string',
            'company_name' => 'nullable|string',
            'address' => 'required|string',
            'country_id' => 'required|exists:countries,id',
            'city_id' => 'required|exists:cities,id',
            'zip_code' => 'nullable|string',
            'email' => 'nullable|email',
            'phone' => 'nullable|string',
        ]);

        $shippingAddress = ShippingAddress::updateOrCreate(
            ['user_id' => $request->user()->id],
            $data
        );

        return $this->sendSuccessResponse('Shipping address created or updated successfully', $shippingAddress);
    }
}

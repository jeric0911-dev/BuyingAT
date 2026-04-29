<?php

namespace App\Http\Controllers\customer\billingAndShipping;

use App\Http\Controllers\BaseController;
use App\Models\BillingAddress;
use Illuminate\Http\Request;

class BillingAddressController extends BaseController
{
    // Get billing address of authenticated user
    public function index()
    {
        $billingAddress = BillingAddress::where('user_id', auth()->id())->first();

        if (!$billingAddress) {
            return $this->sendErrorResponse('Billing address not found', [], 404);
        }

        return $this->sendSuccessResponse('Billing address retrieved successfully', $billingAddress);
    }

    // Create or update billing address for authenticated user
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

        $billingAddress = BillingAddress::updateOrCreate(
            ['user_id' => $request->user()->id],
            $data
        );

        return $this->sendSuccessResponse('Billing address created or updated successfully', $billingAddress);
    }
}

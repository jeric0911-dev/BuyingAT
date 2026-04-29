<?php

namespace App\Http\Controllers\admin\paymentProvider;

use App\Http\Controllers\BaseController;
use App\Models\PaymentProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Traits\ImageTrait;

class PaymentProviderController extends BaseController
{
    use ImageTrait;

    // Get all payment providers
    public function index()
    {
        $paymentProviders = PaymentProvider::all();
        return $this->sendSuccessResponse('Payment providers retrieved successfully', $paymentProviders);
    }

    // Get one payment provider
    public function show($id)
    {
        $paymentProvider = PaymentProvider::findOrFail($id);
        return $this->sendSuccessResponse('Payment provider retrieved successfully', $paymentProvider);
    }

    // Store a new payment provider
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'status' => 'required|string',
            'api_key' => 'required|string',
            'base_url' => 'required|string',
        ]);

        if ($request->hasFile('logo')) {
            $data['logo'] = $this->compressAndUploadImage($request->file('logo'), 'payment_provider_logos');
        }

        $paymentProvider = PaymentProvider::create($data);

        return $this->sendSuccessResponse('Payment provider created successfully', $paymentProvider, 201);
    }

    // Update an existing payment provider
    public function update(Request $request, $id)
    {
        $paymentProvider = PaymentProvider::findOrFail($id);

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'status' => 'required|string',
            'api_key' => 'required|string',
            'base_url' => 'required|string',
        ]);

        if ($request->hasFile('logo')) {
            if ($paymentProvider->logo) {
                Storage::disk('public')->delete($paymentProvider->logo);
            }

            $data['logo'] = $this->compressAndUploadImage($request->file('logo'), 'payment_provider_logos');
        }

        $paymentProvider->update($data);

        return $this->sendSuccessResponse('Payment provider updated successfully', $paymentProvider);
    }

    // Update payment provider status
    public function destroy($id)
    {
        $paymentProvider = PaymentProvider::findOrFail($id);

        if ($paymentProvider->logo) {
            Storage::disk('public')->delete($paymentProvider->logo);
        }

        $paymentProvider->delete();

        return $this->sendSuccessResponse('Payment provider deleted successfully');
    }
}

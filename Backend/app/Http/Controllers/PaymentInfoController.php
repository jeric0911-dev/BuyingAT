<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PaymentsInfo;
use App\Services\ResponseService;
use Illuminate\Http\Response;

use App\Http\Controllers\BaseController;

class PaymentInfoController extends BaseController
{
    // Get all payments
    public function index()
    {
        $paymentsInfo = PaymentsInfo::with('paymentsInfoUser', 'getPaymentProvider')->get();
        return $this->sendSuccessResponse('Payments info retrieved successfully', $paymentsInfo);
    }

    // Get single payment
    public function show($id)
    {
        $paymentsInfo = PaymentsInfo::with('paymentsInfoUser', 'getPetListing', 'getPaymentProvider')->findOrFail($id);
        return $this->sendSuccessResponse('Payments info retrieved successfully', $paymentsInfo);
    }

    // Store payment
    public function store(Request $request)
    {
        $data = $request->validate([
            'payment_provider_id' => 'required|exists:payment_providers,id',
            'user_id' => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
            'amount' => 'required|string',
            'status' => 'string',
        ]);

        $paymentInfo = PaymentsInfo::create($data);
        return $this->sendSuccessResponse('Payment info created successfully', $paymentInfo, Response::HTTP_CREATED);
    }

    // Update payment
    public function update(Request $request, $id)
    {
        $paymentInfo = PaymentsInfo::findOrFail($id);

        $data = $request->validate([
            'payment_provider_id' => 'required|exists:payment_providers,id',
            'user_id' => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
            'amount' => 'required|string',
            'status' => 'required|string',
        ]);

        $paymentInfo->update($data);

        return $this->sendSuccessResponse('Payment info updated successfully', $paymentInfo);
    }

    // Delete payment
    public function destroy($id)
    {
        $paymentInfo = PaymentsInfo::findOrFail($id);
        $paymentInfo->delete();

        return $this->sendSuccessResponse('Payment info deleted successfully');
    }
}

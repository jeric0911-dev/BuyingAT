<?php

namespace App\Http\Controllers\admin\currency;

use App\Http\Controllers\BaseController;
use App\Models\Currency;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class CurrencyController extends BaseController
{
    // Get all currencies
    public function index()
    {
        $currencies = Currency::all();
        return $this->sendSuccessResponse('Currencies retrieved successfully', $currencies);
    }

    // Get single currency
    public function show($id)
    {
        $currency = Currency::findOrFail($id);
        return $this->sendSuccessResponse('Currency retrieved successfully', $currency);
    }

    // Create currency
    public function store(Request $request)
    {
        $data = $request->validate([
            'currency_code' => 'required|string',
            'currency_symbol' => 'nullable|string',
            'value' => 'required|numeric',
            'status' => 'required|integer',
        ]);

        $currency = Currency::create($data);

        return $this->sendSuccessResponse('Currency created successfully', $currency, Response::HTTP_CREATED);
    }

    // Update currency
    public function update(Request $request, $id)
    {
        $currency = Currency::findOrFail($id);

        $data = $request->validate([
            'currency_code' => 'required|string',
            'currency_symbol' => 'nullable|string',
            'value' => 'required|numeric',
            'status' => 'required|integer',
        ]);

        $currency->update($data);

        return $this->sendSuccessResponse('Currency updated successfully', $currency->fresh());
    }

    // Delete currency
    public function destroy($id)
    {
        $currency = Currency::findOrFail($id);

        $currency->delete();

        return $this->sendSuccessResponse('Currency deleted successfully');
    }
}

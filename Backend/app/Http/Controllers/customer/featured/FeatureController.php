<?php

namespace App\Http\Controllers\customer\featured;

use App\Http\Controllers\BaseController;
use App\Models\FeatureConfig;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\AdvertInfo;
use App\Models\Expense;
use Carbon\Carbon;
use Illuminate\Support\Str;

class FeatureController extends BaseController
{
    public function feature(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required',
            'advert_date' => 'nullable',
            'duration' => 'required|integer',
        ]);

        $getProduct = Product::findOrFail($data['product_id']);
        $getUser = User::find(auth()->user()->id);
        $getFeatureConfig = FeatureConfig::first();
        $getWallet = Wallet::where('user_id', auth()->user()->id)->first();

        $userPackage = $getUser->userPackage;
        $pricing = $userPackage->package_name === 'standard' || 'premium'
            ? $getFeatureConfig->premium_user_price
            : $getFeatureConfig->normal_user_price;

        if ($userPackage->package_name === 'premium' && now()->greaterThan($userPackage->package_end_date)) {
            $pricing = $getFeatureConfig->premium_user_price;
        }

        $totalCost = $data['duration'] * $pricing;

        if ($getWallet->balance < $totalCost) {
            return ResponseService::error('You do not have sufficient credit balance. Please recharge.', 400);
        }

        $getWallet->balance -= $totalCost;
        $getWallet->expense += $totalCost;
        $getWallet->save();

        $getProduct->is_featured = 1;
        $getProduct->save();

        $advertInfoId = $getProduct->getAdvertInfo->id;
        $featureStartDate = Carbon::now();
        $featureEndDate = $featureStartDate->copy()->addDays($data['duration']);

        $advertInfo = AdvertInfo::findOrFail($advertInfoId);
        $advertInfo->advert_date = $featureStartDate;
        $advertInfo->advert_start_date = $featureStartDate;
        $advertInfo->advert_end_date = $featureEndDate;
        $advertInfo->total_amount = $totalCost;
        $advertInfo->duration = $data['duration'];
        $advertInfo->save();

        $expense = Expense::create([
            'user_id' => auth()->user()->id,
            'transaction_id' => 'TID#' . Str::random(8),
            'initiated' => Carbon::now(),
            'used_for' => 'Featured Property',
            'amount' => $totalCost,
            'status' => 1,
        ]);

        return $this->sendSuccessResponse('Product featured successfully', [
            'advert_info' => $advertInfo,
            'expense' => $expense,
        ]);
    }
}

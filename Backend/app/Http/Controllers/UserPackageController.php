<?php

namespace App\Http\Controllers;

use App\Models\UserPackage;
use Illuminate\Http\Request;
use App\Models\Wallet;
use App\Models\User;
use Carbon\Carbon;
use App\Models\Expense;
use Illuminate\Support\Str;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;
use App\Models\Package;

class UserPackageController extends BaseController
{
    // Subscribe to a package
    public function subscribe(Request $request)
    {
        $data = $request->validate([
            'package_id' => 'required|integer'
        ]);

        $getPackage = Package::find($data['package_id']);
        if (!$getPackage) {
            return ResponseService::error('Package not found');
        }

        $wallet = Wallet::where('user_id', auth()->id())->first();
        if (!$wallet) {
            return ResponseService::error('Your balance is not enough. Please recharge it.');
        }

        if ($wallet->balance < $getPackage->price) {
            return ResponseService::error('Insufficient credit balance');
        }

        $wallet->balance -= $getPackage->price;
        $wallet->expense += $getPackage->price;
        $wallet->save();

        $start = now();
        $end = now()->copy()->addDays($getPackage->packageCategory->duration);

        $userPackage = UserPackage::updateOrCreate(
            ['user_id' => auth()->id()],
            [
                'package_id' => $getPackage->id,
                'package_start_date' => $start,
                'package_end_date' => $end,
                'price' => $getPackage->price,
                'package_name' => $getPackage->title,
                'duration' => $getPackage->packageCategory->duration,
                'product_count' => $getPackage->product_count,
            ]
        );

        Expense::create([
            'user_id' => auth()->id(),
            'transaction_id' => 'TID#' . Str::random(8),
            'initiated' => now(),
            'used_for' => 'Purchase Package',
            'amount' => $getPackage->price,
            'status' => 1,
        ]);

        return $this->sendSuccessResponse('Package subscribed successfully', $userPackage, 200);
    }

    // Get current active package for authenticated user
    public function current(Request $request)
    {
        try {
            $userId = auth()->id();
            $pkg = UserPackage::where('user_id', $userId)->first();
            $active = false;
            if ($pkg && $pkg->package_end_date && now()->lte($pkg->package_end_date)) {
                $active = true;
            }
            return ResponseService::success('Current package', [
                'active' => $active,
                'package' => $pkg,
            ]);
        } catch (\Throwable $th) {
            return ResponseService::error('Failed to fetch package', $th->getMessage());
        }
    }

    // Public: get package status by user id
    public function statusByUser($userId)
    {
        try {
            $pkg = UserPackage::where('user_id', $userId)->first();
            $active = false;
            if ($pkg && $pkg->package_end_date && now()->lte($pkg->package_end_date)) {
                $active = true;
            }
            return ResponseService::success('Package status', [
                'active' => $active,
                'package' => $pkg,
            ]);
        } catch (\Throwable $th) {
            return ResponseService::error('Failed to fetch package status', $th->getMessage());
        }
    }

}

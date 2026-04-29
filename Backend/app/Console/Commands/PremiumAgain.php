<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Product;
use App\Models\UserPackage;
use Carbon\Carbon;

class PremiumAgain extends Command
{
    protected $signature = 'premium:again';

    protected $description = 'Deactivate expired premium packages and reset to free packages.';

    public function handle()
    {
        $expiredUserIds = UserPackage::where('package_end_date', '<', now())
            ->pluck('user_id');

        foreach ($expiredUserIds as $userId) {

            $this->deactivateCarForUser($userId);

            $this->resetUserPackageToFree($userId);
        }

        $this->info('Expired premium packages reset and associated products deactivated successfully.');
    }

    //Deactivate cars for expired users
    protected function deactivateProductForUser($userId)
    {
        $productsToDeactivate = Product::where('user_id', $userId)
            ->where('status', 'Active')
            ->orderBy('created_at', 'desc')
            ->skip(5)
            ->take(PHP_INT_MAX)
            ->get();

        foreach ($productsToDeactivate as $product) {
            $product->status = 'Disabled';
            $product->save();
        }
    }


    //Reset the user package to free
    protected function resetUserPackageToFree($userId)
    {
        $userPackage = UserPackage::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->first();

        if ($userPackage) {
            $userPackage->update([
                'package_end_date' => null,
                'package_name' => 'Free',
                'package_id' => 1,
            ]);
        }
    }
}

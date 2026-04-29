<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Product;
use App\Models\UserPackage;

class ReactivatePremiumProduct extends Command
{

    protected $signature = 'reactivate:premium_products';

    protected $description = 'Reactivate deactivated product for users who have repurchased a premium package';


    public function handle()
    {

        $premiumUsers = UserPackage::where('package_end_date', '>=', now())
            ->pluck('user_id');

        foreach ($premiumUsers as $userId) {
            $this->reactivateProductForUser($userId);
        }

        $this->info('Deactivated products reactivated for premium users successfully.');
    }


    protected function reactivateProductForUser($userId)
    {
        $deactivatedProducts = Product::where('user_id', $userId)
            ->where('status', 'Disabled')
            ->get();

        foreach ($deactivatedProducts as $product) {
            $product->status = 'Active';
            $product->save();
        }
    }
}

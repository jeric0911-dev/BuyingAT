<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use App\Models\AdvertInfo;
use Carbon\Carbon;

class CheckIsFeatured extends Command
{

    protected $signature = 'update:to_normal';


    protected $description = 'Boosted Product update to normal Product.........';


    public function handle()
    {
        $boostedProducts = Product::where('is_featured', 1)
            ->where('status', 'Active')
            ->get();

        foreach ($boostedProducts as $product) {
            $advertInfo = $product->getAdvertInfo;

            if ($advertInfo && !empty($advertInfo->advert_end_date)) {
                try {
                    $featureEndDate = Carbon::createFromFormat('Y-m-d', $advertInfo->advert_end_date)->endOfDay();
                } catch (\Exception $e) {
                    $this->error("Invalid date format for advert_end_date: " . $advertInfo->advert_end_date);
                    continue;
                }

                if ($featureEndDate->isPast()) {
                    $product->is_featured = null;
                    $product->save();
                }
            }

        }

        $this->info('Featured status checked and updated successfully.');
    }
}

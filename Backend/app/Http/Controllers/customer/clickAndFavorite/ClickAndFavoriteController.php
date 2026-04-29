<?php

namespace App\Http\Controllers\customer\clickAndFavorite;

use App\Http\Controllers\BaseController;
use App\Http\Controllers\Controller;
use App\Models\AdvertInfo;
use App\Models\Product;
use App\Services\ResponseService;
use Illuminate\Http\Request;

class ClickAndFavoriteCountController extends BaseController
{
    // Likes count method
    public function clickCount(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->increment('clicks');

        if ($product->is_featured) {
            $advertInfo->increment('after_ads_clicks');
        }

        $advertInfo->save();

        return $this->sendSuccessResponse('Click count incremented successfully', $advertInfo);
    }

    // Favorite count method
    public function favoriteCount(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->increment('favorites');
        $advertInfo->save();

        return $this->sendSuccessResponse('Favorite count incremented successfully', $advertInfo);
    }

    // Decrement favorite count method
    public function decrementFavoriteCount(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->decrement('favorites');
        $advertInfo->save();

        return $this->sendSuccessResponse('Favorite count decremented successfully', $advertInfo);
    }
}

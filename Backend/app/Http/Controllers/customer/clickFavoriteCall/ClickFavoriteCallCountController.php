<?php

namespace App\Http\Controllers\customer\clickFavoriteCall;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use App\Models\AdvertInfo;
use App\Services\ResponseService;
use Illuminate\Http\Request;

class ClickFavoriteCallCountController extends BaseController
{
    // Call count
    public function storeCallCount(Request $request)
    {
        $status = $request->input('status');

        if ($status === 'success') {
            $product = Product::findOrFail($request->input('product_id'));
            $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

            $advertInfo->increment('calls');

            if ($product->is_featured) {
                $advertInfo->increment('after_ads_calls');
            }

            $advertInfo->save();

            return $this->sendSuccessResponse('Call count updated successfully', $advertInfo, 201);
        }

        return $this->sendErrorResponse('Failed to store call count data', 400);
    }

    // Click count
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

    // Favorite count
    public function favoriteCount(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->increment('favorites');
        $advertInfo->save();

        return $this->sendSuccessResponse('Favorite count incremented successfully', $advertInfo);
    }

    // Decrement favorite count
    public function decrementFavoriteCount(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->decrement('favorites');
        $advertInfo->save();

        return $this->sendSuccessResponse('Favorite count decremented successfully', $advertInfo);
    }
}

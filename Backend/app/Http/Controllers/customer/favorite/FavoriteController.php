<?php

namespace App\Http\Controllers\customer\favorite;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Favorite;
use App\Models\Product;
use App\Models\AdvertInfo;
use App\Models\User;
use App\Services\ResponseService;

class FavoriteController extends BaseController
{
    // Get all favorites
    public function index()
    {
        $favorites = Favorite::all();

        return $this->sendSuccessResponse('Favorites retrieved successfully', $favorites);
    }

    // Store a favorite
    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id'    => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
        ]);

        $favorite = Favorite::create($data);

        $product = Product::findOrFail($data['product_id']);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->increment('favorite');

        if ($product->is_boosting) {
            $advertInfo->increment('after_ads_favorites');
        }

        $advertInfo->save();

        return $this->sendSuccessResponse('Favorite created successfully', [
            'favorite'    => $favorite,
            'advert_info' => $advertInfo,
        ]);
    }

    // Get a single favorite
    public function show($id)
    {
        $favorite = Favorite::findOrFail($id);

        return $this->sendSuccessResponse('Favorite retrieved successfully', $favorite);
    }

    // Update favorite
    public function update(Request $request, $id)
    {
        $favorite = Favorite::findOrFail($id);

        $data = $request->validate([
            'user_id'    => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
        ]);

        $favorite->update($data);

        return $this->sendSuccessResponse('Favorite updated successfully', $favorite);
    }

    // Delete a favorite
    public function destroy(Request $request)
    {
        $data = $request->validate([
            'user_id'    => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
        ]);

        $favorite = Favorite::where('user_id', $data['user_id'])
                            ->where('product_id', $data['product_id'])
                            ->first();

        if (!$favorite) {
            return $this->sendErrorResponse('Favorite not found', null, 404);
        }

        $product = Product::findOrFail($data['product_id']);
        $advertInfo = AdvertInfo::findOrFail($product->getAdvertInfo->id);

        $advertInfo->decrement('favorite');
        $advertInfo->save();

        $favorite->delete();

        return $this->sendSuccessResponse('Favorite deleted successfully', null, 204);
    }

    // Get all favorites of a user
    public function getUserFavorites(Request $request)
    {
        $request->validate(['user_id' => 'required|exists:users,id']);

        $favorites = Favorite::where('user_id', $request->user_id)->get();

        return $this->sendSuccessResponse('User favorites retrieved successfully', $favorites);
    }

    // Get user favorited listings with related data
    public function getUserFavorite(Request $request)
    {
        $request->validate(['user_id' => 'required|exists:users,id']);

        $user = User::find($request->user_id);
        if (!$user) {
            return $this->sendErrorResponse('User not found', null, 404);
        }

        $favorites = $user->favorites;

        $favorites->transform(function ($favorite) {
            $favorite->setAttribute('user_favorite_id', $favorite->pivot->id ?? $favorite->id);
            return $favorite;
        });

        return $this->sendSuccessResponse('User favorites with details retrieved successfully', $favorites);
    }

    // Get count of favorites for a product
    public function getProductFavoriteCount($productId)
    {
        $count = Favorite::where('product_id', $productId)->count();

        return $this->sendSuccessResponse('Favorite count retrieved successfully', [
            'favorite_count' => $count,
        ]);
    }
}

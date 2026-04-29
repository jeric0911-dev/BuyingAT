<?php

namespace App\Http\Controllers\customer\wishlist;

use App\Http\Controllers\BaseController;
use App\Models\Wishlist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\ResponseService;

class WishlistController extends BaseController
{
    // Get all wishlist items for the authenticated user
    public function index()
    {
        $wishlist = Wishlist::with(['product' => function ($query) {
            $query->active()
                ->select([
                    'id',
                    'product_title',
                    'price',
                    'discounted_price',
                    'slug_url',
                    'stock',
                    'status'
                ])
                ->with(['getGalleryImages' => function ($query) {
                    $query->select('id', 'product_id', 'img');
                }]);
        }])
        ->where('user_id', Auth::id())
        ->get();

        return $this->sendSuccessResponse('Wishlist retrieved successfully', $wishlist);
    }

    // Store a new wishlist item
    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
        ]);

        $exists = Wishlist::where('user_id', $request->user()->id )
            ->where('product_id', $data['product_id'])
            ->first();

        if ($exists) {
            return $this->sendErrorResponse('Product already in wishlist');
        }

        $wishlist = Wishlist::create([
            'user_id' => $request->user()->id,
            'product_id' => $data['product_id'],
        ]);

        return $this->sendSuccessResponse('Product added to wishlist', $wishlist);
    }

    // Show a single wishlist item
    public function show($id)
    {
        $wishlist = Wishlist::with('product')
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        return $this->sendSuccessResponse('Wishlist item retrieved', $wishlist);
    }

    // Update wishlist item (optional)
    public function update(Request $request, $id)
    {
        $wishlist = Wishlist::where('user_id', $request->user()->id)->findOrFail($id);

        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
        ]);

        $wishlist->update($data);

        return $this->sendSuccessResponse('Wishlist item updated', $wishlist);

    }

    // Delete a wishlist item
    public function destroy(Request $request, $id)
    {
        $wishlist = Wishlist::where('user_id', $request->user()->id)->where('product_id', $id)->first();
        $wishlist->delete();

        return $this->sendSuccessResponse('Wishlist item removed');
    }
}

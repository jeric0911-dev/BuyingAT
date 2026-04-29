<?php

namespace App\Http\Controllers\customer\product;

use App\Http\Controllers\BaseController;
use App\Models\ProductReview;
use Illuminate\Http\Request;

class ProductReviewController extends BaseController
{
    //store review
    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id|integer',
            'user_id' => 'required|exists:users,id|integer',
            'rating' => 'required|integer',
            'message' => 'nullable|string'
        ]);

        $review = ProductReview::create($data);

        return $this->sendSuccessResponse('Review created successfully', $review);
    }

    //update review
    public function update (Request $request, $id)
    {
        $review = ProductReview::findOrFail($id);

        $data = $request->validate([
            'product_id' => 'required|exists:products,id|integer',
            'user_id' => 'required|exists:users,id|integer',
            'rating' => 'required|integer',
            'message' => 'nullable|string'
        ]);

        $review = $review->update($data);

        return $this->sendSuccessResponse('Review updated successfully', $review);
    }

    //delete
    public function destroy($id)
    {
        $review = ProductReview::findOrFail($id);
        $review->delete();
        return $this->sendSuccessResponse('Review deleted successfully');
    }
}

<?php

namespace App\Http\Controllers\customer\rating;

use App\Http\Controllers\BaseController;
use App\Http\Controllers\Controller;
use App\Models\Rating;
use Illuminate\Http\Request;
use App\Services\ResponseService;

class RatingController extends BaseController
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
            'rating' => 'required|integer',
            'message' => 'nullable|string',
        ]);

        $data['user_id'] = $request->user()->id;

        $rating = Rating::updateOrCreate(
            [
                'user_id' => $data['user_id'],
                'product_id' => $data['product_id'],
            ],
            [
                'rating' => $data['rating'],
                'message' => $data['message'],
            ]
        );

        return $this->sendSuccessResponse($rating->wasRecentlyCreated ? 'Rating created successfully' : 'Rating updated successfully', $rating);
    }
}

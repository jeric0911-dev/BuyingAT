<?php

namespace App\Http\Controllers\admin\sliderAndAds;

use App\Http\Controllers\BaseController;
use App\Models\Ads;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Traits\ImageTrait;

class AdsController extends BaseController
{
    use ImageTrait;

    // Get all ads
    public function index()
    {
        $ads = Ads::all();
        return $this->sendSuccessResponse('Ads retrieved successfully', $ads);
    }

    // Get one ad
    public function show($id)
    {
        $ad = Ads::findOrFail($id);
        return $this->sendSuccessResponse('Ad retrieved successfully', $ad);
    }

    // Store a new ad
    public function store(Request $request)
    {
        $data = $request->validate([
            'img' => 'required|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'link' => 'required|url|max:255',
        ]);

        $data['img'] = $this->compressAndUploadImage($request->file('img'), 'ads');

        $ad = Ads::create($data);

        return $this->sendSuccessResponse('Ad stored successfully', $ad, 201);
    }

    // Update an existing ad
    public function update(Request $request, $id)
    {
        $ad = Ads::findOrFail($id);

        $data = $request->validate([
            'img' => 'sometimes|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'link' => 'required|url|max:255',
        ]);

        if ($request->hasFile('img')) {
            if ($ad->img && Storage::disk('public')->exists($ad->img)) {
                Storage::disk('public')->delete($ad->img);
            }

            $data['img'] = $this->compressAndUploadImage($request->file('img'), 'ads');
        }

        $ad->update($data);

        return $this->sendSuccessResponse('Ad updated successfully', $ad);
    }

    // Delete an ad
    public function destroy($id)
    {
        $ad = Ads::findOrFail($id);

        if ($ad->img && Storage::disk('public')->exists($ad->img)) {
            Storage::disk('public')->delete($ad->img);
        }

        $ad->delete();

        return $this->sendSuccessResponse('Ad deleted successfully');
    }
}

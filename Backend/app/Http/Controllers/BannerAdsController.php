<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BannerAds;
use Illuminate\Support\Facades\Storage;
use App\Services\ResponseService;
use App\Http\Controllers\BaseController;

class BannerAdsController extends BaseController
{
    // Get banner ads
    public function index()
    {
        $bannerAds = BannerAds::first();

        return $this->sendSuccessResponse('Data retrieved successfully', $bannerAds);
    }

    // Store banner ads
    public function store(Request $request)
    {
        $data = $request->validate([
            'link_1' => 'required|string',
            'banner_1' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_2' => 'required|string',
            'banner_2' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_3' => 'required|string',
            'banner_3' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_4' => 'required|string',
            'banner_4' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_5' => 'required|string',
            'banner_5' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_6' => 'required|string',
            'banner_6' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_7' => 'required|string',
            'banner_7' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'link_8' => 'required|string',
            'banner_8' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
        ]);

        // Store banners and get file paths
        $bannerPaths = [];
        for ($i = 1; $i <= 8; $i++) {
            if ($request->hasFile("banner_$i")) {
                $bannerPaths["banner_$i"] = $request->file("banner_$i")->store('banners', 'public');
            }
        }

        // Create the banner ads record
        $bannerAds = BannerAds::create(array_merge($data, $bannerPaths));

        return $this->sendSuccessResponse('Banner ads created successfully', $bannerAds, 201);
    }
}

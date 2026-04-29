<?php

namespace App\Http\Controllers\customer\sliderAndAds;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Ads;
use App\Services\ResponseService;

class AdsController extends BaseController
{
    // Get all ads
    public function index()
    {
        $ads = Ads::first();
        return $this->sendSuccessResponse('Ads fetched successfully', $ads);
    }

    // Get single ad by ID
    public function show($id)
    {
        $ad = Ads::findOrFail($id);
        return $this->sendSuccessResponse('Ad fetched successfully', $ad);
    }
}

<?php

namespace App\Http\Controllers\customer\sliderAndAds;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Advertise;
use App\Services\ResponseService;

class AdvertiseController extends BaseController
{
    // Get all advertises
    public function index()
    {
        $advertises = Advertise::first();
        return $this->sendSuccessResponse('Advertises fetched successfully', $advertises);
    }

    // Get a single advertise by ID
    public function show($id)
    {
        $advertise = Advertise::findOrFail($id);
        return $this->sendSuccessResponse('Advertise fetched successfully', $advertise);
    }
}

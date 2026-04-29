<?php

namespace App\Http\Controllers\customer\sliderAndAds;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Slider;

class SliderController extends BaseController
{
    // Get all sliders
    public function index()
    {
        $sliders = Slider::all();

        if ($sliders->isEmpty()) {
            return $this->sendErrorResponse('No slider data found');
        }
        return $this->sendSuccessResponse('Sliders fetched successfully', $sliders);
    }

    // Get one slider by ID
    public function show($id)
    {
        $slider = Slider::findOrFail($id);

        return $this->sendSuccessResponse('Slider fetched successfully', $slider);
    }
}

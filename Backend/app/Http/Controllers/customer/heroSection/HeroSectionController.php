<?php

namespace App\Http\Controllers\customer\heroSection;

use App\Http\Controllers\BaseController;
use App\Models\HeroSection;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class HeroSectionController extends BaseController
{
    // Get hero section data
    public function show()
    {
        $heroData = HeroSection::first();
        return $this->sendSuccessResponse('Hero Section retrieved successfully', $heroData);
    }
}

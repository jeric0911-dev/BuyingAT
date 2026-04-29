<?php

namespace App\Http\Controllers\customer\aboutUsSection;

use App\Http\Controllers\BaseController;
use App\Models\AboutUsSection;

class AboutUsSectionController extends BaseController
{
    // Get one about us section
    public function show()
    {
        $aboutUsData = AboutUsSection::first();
        return $this->sendSuccessResponse('Data retrieved successfully', $aboutUsData);
    }
}

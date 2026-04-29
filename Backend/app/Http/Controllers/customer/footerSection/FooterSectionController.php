<?php

namespace App\Http\Controllers\customer\footerSection;

use App\Http\Controllers\BaseController;
use App\Http\Controllers\Controller;
use App\Models\FooterSection;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use App\Services\ResponseService;

class FooterSectionController extends BaseController
{
    // Get footer section
    public function show()
    {
        $footerData = FooterSection::first();
        return $this->sendSuccessResponse('Footer Section retrieved successfully', $footerData);
    }
}

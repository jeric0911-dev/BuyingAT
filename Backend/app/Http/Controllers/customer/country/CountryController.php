<?php

namespace App\Http\Controllers\customer\country;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Country;
use App\Services\ResponseService;

class CountryController extends BaseController
{
    // Get all countries
    public function index()
    {
        $countries = Country::all();
        return $this->sendSuccessResponse('Countries retrieved successfully', $countries);
    }
}

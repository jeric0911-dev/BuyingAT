<?php

namespace App\Http\Controllers\customer\city;

use App\Http\Controllers\BaseController;
use App\Models\City;
use App\Services\ResponseService;

class CityController extends BaseController
{
    // Get all cities
    public function index()
    {
        $cities = City::all();

        if ($cities->isEmpty()) {
            return $this->sendErrorResponse('No cities found', [], 404);
        }
        
        return $this->sendSuccessResponse('Cities retrieved successfully', $cities);
    }
}

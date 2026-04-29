<?php

namespace App\Http\Controllers\customer\brand;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Brand;

use App\Services\ResponseService;

class BrandController extends BaseController
{
    //get all brands
    public function index()
    {
        $brands = Brand::all();

        if ($brands->isEmpty()) {
            return $this->sendErrorResponse('No brands found', [], 404);
        }

        return $this->sendSuccessResponse('Brand list retrieved successfully', $brands);
    }

    //get all brands
    public function show($id)
    {
        $brands = Brand::findOrFail($id);
        return $this->sendSuccessResponse('Brand retrieved successfully', $brands);
    }
}

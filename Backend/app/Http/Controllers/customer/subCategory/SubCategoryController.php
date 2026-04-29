<?php

namespace App\Http\Controllers\customer\subCategory;

use App\Http\Controllers\BaseController;
use App\Models\SubCategory;
use App\Services\ResponseService;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class SubCategoryController extends BaseController
{
    // Get all sub categories with their child categories
    public function index()
    {
        $subCategories = SubCategory::all();

        if ($subCategories->isEmpty()) {
            return $this->sendErrorResponse('No sub category data found');
        }

        return $this->sendSuccessResponse('Sub categories retrieved successfully', $subCategories);
    }

    // Get a single sub category with its child categories
    public function show($id)
    {
        $subCategory = SubCategory::with('childCategories')->findOrFail($id);

        return $this->sendSuccessResponse('Sub category retrieved successfully', $subCategory);
    }
}

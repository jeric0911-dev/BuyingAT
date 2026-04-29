<?php

namespace App\Http\Controllers\customer\childCategory;

use App\Http\Controllers\BaseController;
use App\Http\Controllers\Controller;
use App\Models\ChildCategory;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class ChildCategoryController extends BaseController
{
    // Get all child categories
    public function index()
    {
        $childCategories = ChildCategory::all();
        return $this->sendSuccessResponse('Child categories retrieved successfully', $childCategories);
    }

    // Get single child category
    public function show($id)
    {
        $childCategory = ChildCategory::findOrFail($id);
        return $this->sendSuccessResponse('Child category retrieved successfully', $childCategory);
    }
}

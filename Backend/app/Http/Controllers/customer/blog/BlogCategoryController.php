<?php

namespace App\Http\Controllers\customer\blog;

use App\Http\Controllers\BaseController;
use App\Models\BlogCategory;
use App\Services\ResponseService;
use Illuminate\Http\Request;

class BlogCategoryController extends BaseController
{
    //get all categories
    public function index()
    {
        $categories = BlogCategory::all();

        if ($categories->isEmpty()) {
            return $this->sendErrorResponse('No categories found', [], 404);
        }

        return $this->sendSuccessResponse('Blog Categories retrieved successfully', $categories);
    }

    //get blogs by category name
    public function show(Request $request, $name)
    {
        $perPage = $request->query('per_page', 10);

        $category = BlogCategory::where('name', $name)->first();

        if (!$category) {
            return ResponseService::error('Category not found', null, 404);
        }

        $blogs = $category->blogs()->paginate($perPage);

        $categoryData = [
            'id' => $category->id,
            'name' => $category->name
        ];

        return ResponseService::successWithNestedPagination('Retrieved successfully', $categoryData, $blogs);
    }

}

<?php

namespace App\Http\Controllers\admin\blog;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\BlogCategory;
use Illuminate\Support\Facades\Validator;

class BlogCategoryController extends BaseController
{
    // Get all categories
    public function index()
    {
        $categories = BlogCategory::all();
        return $this->sendSuccessResponse('Retrieved successfully', $categories);
    }

    // Store new category
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return $this->sendErrorResponse('Validation failed', $validator->errors(), 422);
        }

        $validatedData = $validator->validated();

        $existingCategory = BlogCategory::where('name', $validatedData['name'])->first();

        if ($existingCategory) {
            return $this->sendErrorResponse('Category already exists', null, 409);
        }

        $category = BlogCategory::create($validatedData);

        return $this->sendSuccessResponse('Created', $category, 201);
    }


    // Get one category by id
    public function show($id)
    {
        $category = BlogCategory::findOrFail($id);
        return $this->sendSuccessResponse('Retrieved successfully', $category);
    }

    // Update category
    public function update(Request $request, $id)
    {
        $category = BlogCategory::findOrFail($id);

        $data = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($data->fails()) {
            return $this->sendErrorResponse('Validation failed', $data->errors(), 422);
        }

        $category->update($data->validated());

        return $this->sendSuccessResponse('Updated', $category, 200);
    }

    // Delete category
    public function destroy($id)
    {
        $category = BlogCategory::findOrFail($id);
        $category->delete();

        return $this->sendSuccessResponse('Deleted', null);
    }
}

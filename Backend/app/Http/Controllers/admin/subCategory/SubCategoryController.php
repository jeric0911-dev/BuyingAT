<?php

namespace App\Http\Controllers\admin\subCategory;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\SubCategory;
use Illuminate\Support\Facades\Storage;
use App\Traits\ImageTrait;

class SubCategoryController extends BaseController
{
    use ImageTrait;

    // Get all subcategories with their categories
    public function index()
    {
        $subCategories = SubCategory::with('category')->get();
        return $this->sendSuccessResponse('Sub categories retrieved successfully', $subCategories);
    }

    // Show a single subcategory
    public function show($id)
    {
        $subCategory = SubCategory::findOrFail($id);
        return $this->sendSuccessResponse('Sub category retrieved successfully', $subCategory);
    }

    // Store a new subcategory
    public function store(Request $request)
    {
        $data = $request->validate([
            'sub_category_name' => 'required|string|max:255',
            'category_id' => 'required|integer|exists:categories,id',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,svg,webp|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,avif,svg,webp|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer',
        ]);

        if ($request->hasFile('icon')) {
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'sub_category_icon_banner');
        }

        if ($request->hasFile('banner')) {
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'sub_category_icon_banner');
        }

        $subCategory = SubCategory::create($data);
        return $this->sendSuccessResponse('Sub category created successfully', $subCategory, 201);
    }

    // Update an existing subcategory
    public function update(Request $request, $id)
    {
        $subCategory = SubCategory::findOrFail($id);

        $data = $request->validate([
            'sub_category_name' => 'required|string|max:255',
            'category_id' => 'required|integer|exists:categories,id',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,svg,webp|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,svg,webp|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer',
        ]);

        if ($request->hasFile('icon')) {
            if ($subCategory->icon) {
                Storage::disk('public')->delete($subCategory->icon);
            }
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'sub_category_icon_banner');
        }

        if ($request->hasFile('banner')) {
            if ($subCategory->banner) {
                Storage::disk('public')->delete($subCategory->banner);
            }
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'sub_category_icon_banner');
        }

        $subCategory->update($data);
        return $this->sendSuccessResponse('Sub category updated successfully', $subCategory);
    }

    // Delete a subcategory
    public function destroy($id)
    {
        $subCategory = SubCategory::findOrFail($id);

        if ($subCategory->icon) {
            Storage::disk('public')->delete($subCategory->icon);
        }

        if ($subCategory->banner) {
            Storage::disk('public')->delete($subCategory->banner);
        }

        $subCategory->delete();

        return $this->sendSuccessResponse('Sub category deleted successfully', null, 204);
    }
}

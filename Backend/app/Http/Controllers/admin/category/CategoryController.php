<?php

namespace App\Http\Controllers\admin\category;

use App\Http\Controllers\BaseController;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use App\Traits\ImageTrait;

class CategoryController extends BaseController
{
    use ImageTrait;

    // Get all categories
    public function index()
    {
        $categories = Category::with('subCategories', 'childCategories')->get();
        return $this->sendSuccessResponse('All categories retrieved successfully.', $categories);
    }

    // Get single category
    public function show($id)
    {
        $category = Category::with('subCategories', 'childCategories')->findOrFail($id);
        return $this->sendSuccessResponse('Category retrieved successfully.', $category);
    }

    // Store category
    public function store(Request $request)
    {
        $data = $request->validate([
            'category_name' => 'required|string|max:255',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,webp|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,webp|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer',
        ]);

        $data['slug'] = $data['slug'] ?? Str::slug($data['category_name']);

        if ($request->hasFile('icon')) {
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'category_icon_banner');
        }

        if ($request->hasFile('banner')) {
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'category_icon_banner');
        }

        $category = Category::create($data);
        return $this->sendSuccessResponse('Category created successfully.', $category, 201);
    }

    // Update category
    public function update(Request $request, $id)
    {
        $category = Category::findOrFail($id);

        $data = $request->validate([
            'category_name' => 'required|string|max:255',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,webp|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,gif,avif,webp|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer',
        ]);

        $data['slug'] = $data['slug'] ?? Str::slug($data['category_name']);

        if ($request->hasFile('icon')) {
            if ($category->icon) {
                Storage::disk('public')->delete($category->icon);
            }
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'category_icon_banner');
        }

        if ($request->hasFile('banner')) {
            if ($category->banner) {
                Storage::disk('public')->delete($category->banner);
            }
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'category_icon_banner');
        }

        $category->update($data);
        return $this->sendSuccessResponse('Category updated successfully.', $category);
    }

    // Delete category
    public function destroy($id)
    {
        $category = Category::findOrFail($id);

        if ($category->icon) {
            Storage::disk('public')->delete($category->icon);
        }

        if ($category->banner) {
            Storage::disk('public')->delete($category->banner);
        }

        $category->delete();
        return $this->sendSuccessResponse('Category deleted successfully.', null, 204);
    }
}

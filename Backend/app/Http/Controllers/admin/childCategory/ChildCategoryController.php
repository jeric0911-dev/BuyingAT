<?php

namespace App\Http\Controllers\admin\childCategory;

use App\Http\Controllers\BaseController;
use App\Models\ChildCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Traits\ImageTrait;

class ChildCategoryController extends BaseController
{
    use ImageTrait;

    // Get all child categories
    public function index()
    {
        $childCategories = ChildCategory::all();
        return $this->sendSuccessResponse('Retrieved', $childCategories);
    }

    // Get single child category
    public function show($id)
    {
        $childCategory = ChildCategory::findOrFail($id);
        return $this->sendSuccessResponse('Retrieved', $childCategory);
    }

    // Store new child category
    public function store(Request $request)
    {
        $data = $request->validate([
            'child_category_name' => 'required|string|max:255',
            'sub_category_id' => 'required|integer|exists:sub_categories,id',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer'
        ]);

        if ($request->hasFile('icon')) {
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'child_category_icon_banner');
        }

        if ($request->hasFile('banner')) {
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'child_category_icon_banner');
        }

        $childCategory = ChildCategory::create($data);

        return $this->sendSuccessResponse('created', $childCategory, 201);
    }

    // Update child category
    public function update(Request $request, $id)
    {
        $childCategory = ChildCategory::findOrFail($id);

        $data = $request->validate([
            'child_category_name' => 'required|string|max:255',
            'sub_category_id' => 'required|integer|exists:sub_categories,id',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer'
        ]);

        if ($request->hasFile('icon')) {
            if ($childCategory->icon) {
                Storage::disk('public')->delete($childCategory->icon);
            }
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'child_category_icon_banner');
        }

        if ($request->hasFile('banner')) {
            if ($childCategory->banner) {
                Storage::disk('public')->delete($childCategory->banner);
            }
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'child_category_icon_banner');
        }

        $childCategory->update($data);

        return $this->sendSuccessResponse('updated', $childCategory);
    }

    // Delete child category
    public function destroy($id)
    {
        $childCategory = ChildCategory::findOrFail($id);

        if ($childCategory->icon) {
            Storage::disk('public')->delete($childCategory->icon);
        }

        if ($childCategory->banner) {
            Storage::disk('public')->delete($childCategory->banner);
        }

        $childCategory->delete();

        return $this->sendSuccessResponse('Deleted', null);
    }
}

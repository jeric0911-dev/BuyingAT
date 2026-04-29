<?php

namespace App\Http\Controllers\admin\brand;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Brand;
use Illuminate\Support\Facades\Storage;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Log;
use App\Traits\ImageTrait;

class BrandController extends BaseController
{
    use ImageTrait;

    // Get all brands
    public function index()
    {
        $brands = Brand::all();
        return $this->sendSuccessResponse('Brands retrieved successfully', $brands);
    }

    // Get single brand
    public function show($id)
    {
        $brand = Brand::findOrFail($id);
        return $this->sendSuccessResponse('Brand retrieved successfully', $brand);
    }

    // Store brand
    public function store(Request $request)
    {
        $data = $request->validate([
            'brand_name' => 'required|string|max:255',
            'icon' => 'required|image|mimes:jpeg,png,jpg,gif,webp,svg,avif|max:2048',
            'banner' => 'required|image|mimes:jpeg,png,jpg,gif,webp,svg,avif|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer',
            'category_id' => 'required|integer',
        ]);

        $data['status'] = $data['status'] ?? 1;

        if ($request->hasFile('icon')) {
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'brand_icon_banner');
        }

        if ($request->hasFile('banner')) {
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'brand_icon_banner');
        }

        $brand = Brand::create($data);
        return $this->sendSuccessResponse('Brand created successfully', $brand, 201);
    }

    // Update brand
    public function update(Request $request, $id)
    {
        $brand = Brand::findOrFail($id);

        $data = $request->validate([
            'brand_name' => 'nullable|string|max:255',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,svg,avif|max:2048',
            'banner' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,svg,avif|max:2048',
            'slug' => 'nullable|string|max:255',
            'status' => 'nullable|integer',
            'category_id' => 'nullable|integer',
        ]);

        if ($request->hasFile('icon')) {
            if ($brand->icon) Storage::disk('public')->delete($brand->icon);
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'brand_icon_banner');
        }

        if ($request->hasFile('banner')) {
            if ($brand->banner) Storage::disk('public')->delete($brand->banner);
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'brand_icon_banner');
        }

        $brand->update($data);

        return $this->sendSuccessResponse('Brand updated successfully', $brand->fresh());
    }

    // Delete brand
    public function destroy($id)
    {
        $brand = Brand::findOrFail($id);

        if ($brand->icon) Storage::disk('public')->delete($brand->icon);
        if ($brand->banner) Storage::disk('public')->delete($brand->banner);

        $brand->delete();

        return $this->sendSuccessResponse('Brand deleted successfully', null, 204);
    }
}

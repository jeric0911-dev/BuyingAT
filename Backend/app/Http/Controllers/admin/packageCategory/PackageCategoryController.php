<?php

namespace App\Http\Controllers\admin\packageCategory;

use App\Http\Controllers\BaseController;
use App\Models\PackageCategory;
use Illuminate\Http\Request;

class PackageCategoryController extends BaseController
{
    // Get all categories
    public function index()
    {
        $packages = PackageCategory::all();
        return $this->sendSuccessResponse('Package categories retrieved successfully', $packages);
    }

    // Get one category
    public function show($id)
    {
        $package = PackageCategory::findOrFail($id);
        return $this->sendSuccessResponse('Package category retrieved successfully', $package);
    }

    // Store a new category
    public function store(Request $request)
    {
        $data = $request->validate([
            'title'    => 'required|string|unique:package_categories|max:99',
            'duration' => 'required|integer',
        ]);

        $package = PackageCategory::create($data);
        return $this->sendSuccessResponse('Package category created successfully', $package, 201);
    }

    // Update an existing category
    public function update(Request $request, $id)
    {
        $package = PackageCategory::findOrFail($id);

        $data = $request->validate([
            'title'    => 'required|string|unique:package_categories|max:99',
            'duration' => 'required|integer',
            'status'   => 'nullable|boolean',
        ]);

        $package->update($data);

        return $this->sendSuccessResponse('Package category updated successfully', $package);
    }

    // Delete a category
    public function delete($id)
    {
        $package = PackageCategory::findOrFail($id);
        $package->delete();

        return $this->sendSuccessResponse('Package category deleted successfully');
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\Package;
use App\Models\PackageAdvantage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;
use App\Models\PackageCategory;

class PackageController extends BaseController
{
    // Get all packages
    public function index()
    {
        $packages = Package::with('packageAdvantage')->get();
        return $this->sendSuccessResponse('Packages retrieved successfully', $packages);
    }

    // Get all packages
    public function getAllPackagesByCategory()
    {
        $packages = PackageCategory::with('packages.packageAdvantage')->get();
        return $this->sendSuccessResponse('Packages retrieved successfully', $packages);
    }

    // Get a single package
    public function show($id)
    {
        $package = Package::with('packageAdvantage')->findOrFail($id);
        return $this->sendSuccessResponse('Package retrieved successfully', $package);
    }

    // Store a new package
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'one_month_price' => 'nullable',
            'six_month_price' => 'nullable',
            'one_year_price' => 'nullable',
            'icon' => 'nullable|string',
            'duration' => 'required|integer',
            'product_count' => 'required|integer',
            'advert_count' => 'nullable|integer',
            'status' => 'required|integer'
        ]);

        if ($request->hasFile('icon')) {
            $imagePath = $request->file('icon')->store('package_icon', 'public');
            $data['icon'] = $imagePath;
        }

        $package = Package::create($data);

        $this->syncAdvantages($request, $package->id);

        return $this->sendSuccessResponse('Package created successfully', $package);
    }

    // Update a package
    public function update(Request $request, $id)
    {
        $package = Package::findOrFail($id);

        $data = $request->validate([
            'title' => 'string',
            'one_month_price' => 'nullable',
            'six_month_price' => 'nullable',
            'one_year_price' => 'nullable',
            'icon' => 'nullable|string',
            'duration' => 'integer',
            'property_count' => 'required|integer',
            'advert_count' => 'nullable|integer',
            'status' => 'integer'
        ]);

        if ($request->hasFile('icon')) {
            if ($package->icon) {
                Storage::disk('public')->delete($package->icon);
            }
            $imagePath = $request->file('icon')->store('package_icon', 'public');
            $data['icon'] = $imagePath;
        }

        $package->update($data);

        $package->packageAdvantage()->delete();
        $this->syncAdvantages($request, $package->id);

        return $this->sendSuccessResponse('Package updated successfully', $package);
    }

    // Delete a package
    public function destroy($id)
    {
        $package = Package::findOrFail($id);

        if ($package->icon) {
            Storage::disk('public')->delete($package->icon);
        }

        $package->packageAdvantage()->delete();
        $package->delete();

        return $this->sendSuccessResponse('Package deleted successfully');
    }

    // Private helper to sync advantages
    private function syncAdvantages(Request $request, $packageId)
    {
        $packageAdvantage = $request->package_advantage;

        if (is_string($packageAdvantage)) {
            $packageAdvantage = json_decode($packageAdvantage, true);
        }

        if (is_array($packageAdvantage)) {
            foreach ($packageAdvantage as $advantage) {
                $iconType = $advantage['icon_type'] ?? '';

                if ($iconType !== null) {
                    PackageAdvantage::create([
                        'package_id' => $packageId,
                        'title' => $advantage['title'],
                        'icon_type' => $iconType,
                    ]);
                }
            }
        }
    }
}

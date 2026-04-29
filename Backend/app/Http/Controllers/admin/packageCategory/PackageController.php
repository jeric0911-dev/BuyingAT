<?php

namespace App\Http\Controllers\admin\packageCategory;

use App\Http\Controllers\BaseController;
use App\Models\Package;
use App\Models\PackageAdvantage;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class PackageController extends BaseController
{
    // Get all packages
    public function index()
    {
        $packages = Package::with('packageAdvantage', 'packageCategory')->get();
        return $this->sendSuccessResponse('Packages retrieved successfully', $packages);
    }

    // Get one package
    public function show($id)
    {
        $package = Package::with('packageAdvantage')->findOrFail($id);
        return $this->sendSuccessResponse('Package retrieved successfully', $package);
    }

    // store a new package
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string',
            'price' => 'required|numeric',
            'product_count' => 'required|integer',
            'advert_count' => 'nullable|integer',
            'package_category_id' => 'required|integer'
        ]);

        $package = Package::create($data);

        $packageAdvantage = $request->package_advantage;
        $this->createPackageAdvantages($packageAdvantage, $package->id);

        return $this->sendSuccessResponse('Package created successfully', $package, 201);
    }

    // Update package status
    public function updateStatus(Request $request, $id)
    {
        $package = Package::findOrFail($id);
        $data = $request->validate(['status' => 'integer']);
        $package->status = $data['status'];
        $package->save();

        return $this->sendSuccessResponse('Package status updated successfully', $package);
    }

    // Get the best-selling package
    public function getBestSellingPackage()
    {
        $bestSellingPackage = Package::select('packages.id', DB::raw('MAX(packages.title) as title'), DB::raw('COUNT(user_packages.id) as package_count'))
            ->leftJoin('user_packages', 'packages.id', '=', 'user_packages.package_id')
            ->groupBy('packages.id')
            ->orderByDesc('package_count')
            ->first();

        return $this->sendSuccessResponse('Best-selling package retrieved successfully', $bestSellingPackage);
    }

    // update package
    public function update(Request $request, $id)
    {
        Log::info($request->all());
        $package = Package::findOrFail($id);
        $data = $request->validate([
            'title' => 'required|string',
            'price' => 'required|numeric',
            'product_count' => 'required|integer',
            'advert_count' => 'nullable|integer',
            'package_category_id' => 'required|integer',
            'status' => 'nullable|integer'
        ]);

        $package->update($data);
        $package->packageAdvantage()->delete();

        $packageAdvantage = $request->package_advantage;
        $this->createPackageAdvantages($packageAdvantage, $package->id);

        return $this->sendSuccessResponse('Package updated successfully', $package);
    }

    // Delete package
    public function destroy($id)
    {
        $package = Package::findOrFail($id);

        $package->packageAdvantage()->delete();
        $package->delete();

        return $this->sendSuccessResponse('Package deleted successfully');
    }

    //create package advantages
    private function createPackageAdvantages($packageAdvantage, $packageId)
    {
        if (is_string($packageAdvantage)) {
            $packageAdvantage = json_decode($packageAdvantage, true);
        }

        if (is_array($packageAdvantage)) {
            foreach ($packageAdvantage as $advantage) {
                PackageAdvantage::create([
                    'package_id' => $packageId,
                    'title' => $advantage
                ]);
            }
        }
    }
}

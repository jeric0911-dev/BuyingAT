<?php

namespace App\Http\Controllers;

use App\Models\FeatureConfig;
use Illuminate\Http\Request;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;
class FeatureConfigController extends BaseController
{
    // Get all feature configs
    public function index()
    {
        $featureConfigs = FeatureConfig::all();
        return $this->sendSuccessResponse('Feature configurations retrieved successfully', $featureConfigs);
    }

    // Get single feature config by ID
    public function show($id)
    {
        $featureConfig = FeatureConfig::findOrFail($id);
        return $this->sendSuccessResponse('Feature configuration retrieved successfully', $featureConfig);
    }

    // Store a new feature config
    public function store(Request $request)
    {
        $data = $request->validate([
            'normal_user_price' => 'required|string',
            'premium_user_price' => 'required|string'
        ]);

        $featureConfig = FeatureConfig::create($data);
        return $this->sendSuccessResponse('Feature configuration created successfully', $featureConfig);
    }

    // Update a feature config
    public function update(Request $request, $id)
    {
        $featureConfig = FeatureConfig::findOrFail($id);

        $data = $request->validate([
            'normal_user_price' => 'required|string',
            'premium_user_price' => 'required|string'
        ]);

        $featureConfig->update($data);

        return $this->sendSuccessResponse('Feature configuration updated successfully', $featureConfig);
    }

    // Delete a feature config
    public function destroy($id)
    {
        $featureConfig = FeatureConfig::findOrFail($id);
        $featureConfig->delete();

        return $this->sendSuccessResponse('Feature configuration deleted successfully', $featureConfig);
    }
}

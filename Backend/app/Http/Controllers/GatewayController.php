<?php

namespace App\Http\Controllers;

use App\Models\Gateway;
use Illuminate\Http\Request;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class GatewayController extends BaseController
{
    // Get all gateways
    public function index()
    {
        $gateways = Gateway::all();
        return $this->sendSuccessResponse('Gateways retrieved successfully', $gateways);
    }

    // Get active gateways for frontend
    public function getAllFromFrontend()
    {
        $gateways = Gateway::where('status', 1)->get();
        return $this->sendSuccessResponse('Active gateways retrieved successfully', $gateways);
    }

    // Get one gateway by alias
    public function show($alias)
    {
        $gateway = Gateway::where('alias', $alias)->firstOrFail();
        return $this->sendSuccessResponse('Gateway retrieved successfully', $gateway);
    }

    // Store new gateway
    public function store(Request $request)
    {
        $data = $request->validate([
            'gateway_name' => 'required|string',
            'alias' => 'nullable|string|unique:gateways',
            'gateway_parameters' => 'required|array',
            'supported_currencies' => 'sometimes|array',
            'extras' => 'sometimes|array',
            'description' => 'sometimes|string',
            'status' => 'sometimes|integer',
        ]);

        if (isset($data['supported_currencies'])) {
            $data['supported_currencies'] = json_encode($data['supported_currencies']);
        }

        if (isset($data['extras'])) {
            $data['extras'] = json_encode($data['extras']);
        }

        $data['gateway_parameters'] = json_encode($data['gateway_parameters']);

        $gateway = Gateway::create($data);

        return $this->sendSuccessResponse('Gateway created successfully', $gateway);
    }

    // Update gateway by alias
    public function update(Request $request, $alias)
    {
        $gateway = Gateway::where('alias', $alias)->firstOrFail();

        $data = $request->validate([
            'gateway_name' => 'sometimes|string',
            'alias' => 'sometimes|string|unique:gateways,alias,' . $gateway->id,
            'gateway_parameters' => 'sometimes|array',
            'supported_currencies' => 'sometimes|array',
            'extras' => 'sometimes|array',
            'description' => 'sometimes|string',
            'status' => 'sometimes|integer',
        ]);

        if (isset($data['supported_currencies'])) {
            $data['supported_currencies'] = json_encode($data['supported_currencies']);
        }

        if (isset($data['extras'])) {
            $data['extras'] = json_encode($data['extras']);
        }

        if (isset($data['gateway_parameters'])) {
            $data['gateway_parameters'] = json_encode($data['gateway_parameters']);
        }

        $gateway->update($data);

        return $this->sendSuccessResponse('Gateway updated successfully', $gateway);
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\PusherConfig;
use Illuminate\Http\Request;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class PusherConfigController extends BaseController
{
    // Get first pusher config
    public function getFirst()
    {
        $getConfig = PusherConfig::first();
        return $this->sendSuccessResponse('Pusher config retrieved successfully', $getConfig);
    }

    // Update pusher config
    public function update(Request $request)
    {
        $getConfig = PusherConfig::firstOrFail();

        $data = $request->validate([
            'pusher_app_id' => 'required|string',
            'pusher_app_key' => 'required|string',
            'pusher_app_secret' => 'required|string',
            'pusher_host' => 'required|string',
            'pusher_port' => 'required|string',
            'pusher_scheme' => 'required|string',
            'pusher_app_cluster' => 'required|string',
        ]);

        $getConfig->update($data);

        return $this->sendSuccessResponse('Pusher config updated successfully', $getConfig->fresh());
    }
}

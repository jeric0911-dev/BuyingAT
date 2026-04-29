<?php

namespace App\Http\Controllers;

use App\Models\GoogleLoginConfig;
use Illuminate\Http\Request;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class GoogleLoginConfigController extends BaseController
{
    // Get the first Google login config
    public function getFirst()
    {
        $googleConfig = GoogleLoginConfig::select('google_client_id')->first();
        return $this->sendSuccessResponse('Google login config retrieved successfully', $googleConfig);
    }

    // Update the config
    public function update(Request $request)
    {
        $googleConfig = GoogleLoginConfig::firstOrFail();

        $data = $request->validate([
            'google_client_id' => 'required|string',
            'google_client_secret' => 'required|string',
            'google_redirect_uri' => 'required|string',
        ]);

        $googleConfig->update($data);

        return $this->sendSuccessResponse('Google login config updated successfully', $googleConfig);
    }
}

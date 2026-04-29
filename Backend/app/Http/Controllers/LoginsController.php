<?php

namespace App\Http\Controllers;

use App\Models\Logins;
use Illuminate\Http\Request;
use Jenssegers\Agent\Agent;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class LoginsController extends BaseController
{
    public function index($id)
    {
        $logins = Logins::where('user_id', $id)
            ->orderBy('created_at', 'desc')
            ->get();

        return $this->sendSuccessResponse('Data retrieved successfully', $logins);
    }

    public function logins(Request $request)
    {
        $user = auth()->user()->name;
        $ipAddress = $request->ip();
        $agent = new Agent();
        $browserOs = $agent->browser() . ' on ' . $agent->platform();

        $location = $this->getCityAndCountry();
        $city = $location['city'] . ', ' . $location['country'];

        $data = Logins::create([
            'user' => $user,
            'user_id' => auth()->user()->id,
            'login_at' => now(),
            'ip' => $ipAddress,
            'city' => $city,
            'browser_os' => $browserOs,
        ]);

        return $this->sendSuccessResponse('Login logged successfully', $data);
    }

    private function getCityAndCountry()
    {
        $ipInfoToken = 'a88f54e9c65182';
        $ipInfoUrl = "http://ipinfo.io/json?token=$ipInfoToken";

        $ipInfoResponse = file_get_contents($ipInfoUrl);
        $ipInfoData = json_decode($ipInfoResponse);

        if ($ipInfoData && property_exists($ipInfoData, 'city') && property_exists($ipInfoData, 'country')) {
            return [
                'city' => $ipInfoData->city,
                'country' => $ipInfoData->country,
            ];
        }

        return [
            'city' => 'Unknown',
            'country' => 'Unknown',
        ];
    }
}

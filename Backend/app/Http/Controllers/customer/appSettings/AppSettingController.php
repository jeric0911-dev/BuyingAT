<?php

namespace App\Http\Controllers\customer\appSettings;

use App\Http\Controllers\BaseController;
use App\Models\AppSetting;
use App\Models\Currency;
use Illuminate\Http\Request;

class AppSettingController extends BaseController
{
    // Show app settings with currency info
    public function show()
    {
        $appSetting = AppSetting::first();

        if (!$appSetting) {
            return $this->sendErrorResponse('App settings not found');
        }

        return $this->sendSuccessResponse('Data retrieved successfully', $appSetting);
    }

    public function getOne()
    {
        $appSetting = AppSetting::first();

        if (!$appSetting) {
            return $this->sendErrorResponse('App settings not found');
        }

        return $this->sendSuccessResponse('Data retrieved successfully', $appSetting);
    }
}

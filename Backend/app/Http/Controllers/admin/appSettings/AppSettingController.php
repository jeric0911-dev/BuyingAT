<?php
namespace App\Http\Controllers\admin\appSettings;

use App\Http\Controllers\BaseController;
use App\Models\AppSetting;
use Illuminate\Http\Request;
use App\Traits\ImageTrait;

class AppSettingController extends BaseController
{
    use ImageTrait;
    
    // Show app settings
    public function show()
    {
        $appSetting = AppSetting::first();

        if (!$appSetting) {
            return $this->sendErrorResponse('App settings not found', null, 404);
        }

        return $this->sendSuccessResponse('Data retrieved successfully', $appSetting);
    }

    // Update or create app settings
    public function update(Request $request)
    {
        $data = $request->validate([
            'site_title' => 'nullable|string',
            'currency_id' => 'nullable|integer',
            'currency_symbol' => 'nullable|string',
            'front_end_base_url' => 'nullable|url',
            'back_end_base_url' => 'nullable|url',

            'login_page_title' => 'nullable|string|max:255',
            'header_title' => 'nullable|string|max:255',
            'pixel_id' => 'nullable|string|max:255',
            'google_analytics_id' => 'nullable|string|max:255',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:1000',
            'app_base_url' => 'nullable|url',
            'frontend_url' => 'nullable|url',
        ]);

        if ($request->hasFile('web_app_logo')) {
            $data['web_app_logo'] = $this->compressAndUploadImage($request->file('web_app_logo'), 'settings');
        }

        if ($request->hasFile('fav_icon')) {
            $data['fav_icon'] = $this->compressAndUploadImage($request->file('fav_icon'), 'settings');
        }

        $appSetting = AppSetting::first();

        if ($appSetting) {
            $appSetting->update($data);
        } else {
            $appSetting = AppSetting::create($data);
        }

        return $this->sendSuccessResponse('App settings saved successfully', $appSetting->fresh());
    }
}

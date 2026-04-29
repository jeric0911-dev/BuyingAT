<?php

namespace App\Http\Controllers;

use App\Models\MailConfig;
use Illuminate\Http\Request;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Log;

use App\Http\Controllers\BaseController;

class MailConfigController extends BaseController
{
    // Get the first (and only) mail config
    public function getFirst()
    {
        $mailConfig = MailConfig::first();
        if (!$mailConfig) {
            return $this->sendErrorResponse('Mail configuration not found', null, 404);
        }
        Log::info($mailConfig);

        return $this->sendSuccessResponse('Retrieved successfully', $mailConfig);
    }

    // Update the mail config
    public function update(Request $request)
    {
        $mailConfig = MailConfig::first();
        // Log::info($mailConfig);
        if (!$mailConfig) {
            return ResponseService::error('Mail configuration not found', null, 404);
        }

        $data = $request->validate([
            'mailer' => 'required|string',
            'host' => 'required|string',
            'port' => 'required|string',
            'username' => 'required|string',
            'password' => 'required|string',
            'encryption' => 'required|string',
            'mail_from_address' => 'required|string',
            'mail_from_name' => 'required|string',
        ]);

        $mailConfig->update($data);

        $mailConfig->refresh();

        return $this->sendSuccessResponse('Updated successfully', $mailConfig);
    }
}

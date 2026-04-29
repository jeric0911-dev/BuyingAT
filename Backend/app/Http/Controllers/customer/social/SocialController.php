<?php

namespace App\Http\Controllers\customer\social;

use App\Http\Controllers\BaseController;
use App\Http\Controllers\Controller;
use App\Models\Social;
use Illuminate\Http\Request;
use App\Services\ResponseService;

class SocialController extends BaseController
{
    // Get all social icons
    public function index()
    {
        $socials = Social::all();

        if ($socials->isEmpty()) {
            return $this->sendErrorResponse('No social data found');
        }

        return $this->sendSuccessResponse('Social data retrieved successfully', $socials);
    }

    // Get a single social icon by ID
    public function show($id)
    {
        $social = Social::findOrFail($id);
        return $this->sendSuccessResponse('Social data retrieved successfully', $social);
    }
}

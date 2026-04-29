<?php

namespace App\Http\Controllers\customer\morePage;

use App\Http\Controllers\BaseController;
use App\Models\MorePage;
use Illuminate\Http\Request;
use App\Services\ResponseService;

class MorePageController extends BaseController
{
    // Get all pages
    public function index()
    {
        $pages = MorePage::all();

        if ($pages->isEmpty()) {
            return $this->sendErrorResponse('No pages found', [], 404);
        }

        return $this->sendSuccessResponse('Pages retrieved successfully', $pages);
    }

    // Get one page by slug
    public function show($slug)
    {
        $page = MorePage::where('slug', $slug)->first();

        if (!$page) {
            return $this->sendErrorResponse('Page not found', [], 404);
        }

        return $this->sendSuccessResponse('Page retrieved successfully', $page);
    }
}

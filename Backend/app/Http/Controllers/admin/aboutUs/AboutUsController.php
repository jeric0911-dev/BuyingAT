<?php

namespace App\Http\Controllers\admin\aboutUs;

use App\Http\Controllers\BaseController;

use Illuminate\Http\Request;
use App\Models\AboutUs;
use App\Services\ResponseService;

class AboutUsController extends BaseController
{
    //get one
    public function getOne(){
        $getOne = AboutUs::first();
        return $this->sendSuccessResponse('data retrieved successfully', $getOne);
    }

    //store about us data
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'nullable|string',
            'content' => 'string'
        ]);

        $existingData = AboutUs::first();
        if ($existingData) {
            return $this->sendErrorResponse('data already exists', 409);
        }

        $aboutData = AboutUs::create($data);
        return $this->sendSuccessResponse('data created', $aboutData, 201);
    }

    //update about us data
    public function update(Request $request)
    {
        $aboutUs = AboutUs::first();

        $data = $request->validate([
            'title' => 'nullable|string',
            'content' => 'string'
        ]);

        $aboutUs = $aboutUs->update($data);

        return $this->sendSuccessResponse('data updated', $aboutUs, 200);
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\AdvertInfo;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

use App\Http\Controllers\BaseController;

class AdvertInfoController extends BaseController
{
    // Get all advert information
    public function index()
    {
        $advertInfos = AdvertInfo::with('productUser.userType')->get();

        if ($advertInfos->isEmpty()) {
            return $this->sendErrorResponse('No advert information found');
        }

        return $this->sendSuccessResponse('Advert information retrieved successfully', $advertInfos);
    }

    // Store advert information
    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
        ]);

        $advertInfo = AdvertInfo::create($data);

        return $this->sendSuccessResponse('Advert information created successfully', $advertInfo, Response::HTTP_CREATED);
    }

    // Update advert information
    public function update(Request $request, $id)
    {
        $advertInfo = AdvertInfo::findOrFail($id);

        $data = $request->validate([
            'user_id' => 'required|exists:users,id',
            'product_id' => 'required|exists:products,id',
        ]);

        $advertInfo->update($data);

        return $this->sendSuccessResponse('Advert information updated successfully', $advertInfo);
    }

    // Delete advert information
    public function destroy($id)
    {
        $advertInfo = AdvertInfo::findOrFail($id);
        $advertInfo->delete();

        return $this->sendSuccessResponse('Advert information deleted successfully');
    }
}

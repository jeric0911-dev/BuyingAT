<?php

namespace App\Http\Controllers\admin\listingType;

use App\Http\Controllers\BaseController;
use App\Models\ListingType;
use Illuminate\Http\Request;

class ListingTypeController extends BaseController
{
    // Get all listing types
    public function index()
    {
        $listingTypes = ListingType::all();
        return $this->sendSuccessResponse('Listing types retrieved successfully', $listingTypes);
    }

    // Get single listing type
    public function show($id)
    {
        $listingType = ListingType::findOrFail($id);
        return $this->sendSuccessResponse('Listing type retrieved successfully', $listingType);
    }

    // Store new listing type
    public function store(Request $request)
    {
        $data = $request->validate([
            'listing_name' => 'required|string|max:255',
        ]);

        $listingType = ListingType::create($data);
        return $this->sendSuccessResponse('Listing type created successfully', $listingType, 201);
    }

    // Update listing type
    public function update(Request $request, $id)
    {
        $listingType = ListingType::findOrFail($id);

        $data = $request->validate([
            'listing_name' => 'required|string|max:255',
        ]);

        $listingType->update($data);
        return $this->sendSuccessResponse('Listing type updated successfully', $listingType);
    }

    // Delete listing type
    public function destroy($id)
    {
        $listingType = ListingType::findOrFail($id);
        $listingType->delete();

        return $this->sendSuccessResponse('Listing type deleted successfully');
    }
}

<?php

namespace App\Http\Controllers\admin\city;

use App\Http\Controllers\BaseController;
use App\Models\City;
use Illuminate\Http\Request;

class CityController extends BaseController
{
    // Get all cities
    public function index()
    {
        $cities = City::with('country')->get();
        return $this->sendSuccessResponse('Cities retrieved successfully', $cities);
    }

    // Store a new city
    public function store(Request $request)
    {
        $data = $request->validate([
            'country_id' => 'required|exists:countries,id',
            'status' => 'nullable|string',
            'city_name' => 'required|string',
            'lat' => 'nullable',
            'long' => 'nullable',
        ]);

        $data['status'] = $data['status'] ?? 1;

        $city = City::create($data);

        return $this->sendSuccessResponse('City created successfully', $city, 201);
    }

    // Get a single city
    public function show($id)
    {
        $city = City::with('country')->findOrFail($id);
        return $this->sendSuccessResponse('City retrieved successfully', $city);
    }

    // Update an existing city
    public function update(Request $request, $id)
    {
        $city = City::findOrFail($id);

        $data = $request->validate([
            'country_id' => 'nullable|exists:countries,id',
            'status' => 'nullable|string',
            'city_name' => 'nullable|string',
            'lat' => 'nullable',
            'long' => 'nullable',
        ]);

        $city->update($data);

        return $this->sendSuccessResponse('City updated successfully', $city);
    }

    // Delete a city
    public function destroy($id)
    {
        $city = City::findOrFail($id);

        $city->delete();

        return $this->sendSuccessResponse('City deleted successfully', null);
    }
}

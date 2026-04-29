<?php

namespace App\Http\Controllers\admin\country;

use App\Http\Controllers\BaseController;
use App\Models\Country;
use Illuminate\Http\Request;

class CountryController extends BaseController
{
    // Get all countries
    public function index()
    {
        $countries = Country::all();
        return $this->sendSuccessResponse('Countries retrieved successfully', $countries);
    }

    // Store country
    public function store(Request $request)
    {
        $data = $request->validate([
            'status' => 'nullable|string',
            'country_name' => 'required|string',
            'iso_code' => 'nullable|string',
            'phone_code' => 'nullable|string'
        ]);

        $data['status'] = $data['status'] ?? 1;

        $country = Country::create($data);

        return $this->sendSuccessResponse('Country created successfully', $country, 201);
    }

    // Get single country
    public function show($id)
    {
        $country = Country::with('cities')->findOrFail($id);
        return $this->sendSuccessResponse('Country retrieved successfully', $country);
    }

    // Update country
    public function update(Request $request, $id)
    {
        $country = Country::findOrFail($id);

        $data = $request->validate([
            'status' => 'nullable|string',
            'country_name' => 'required|string',
            'iso_code' => 'nullable|string',
            'phone_code' => 'nullable|string'
        ]);

        $data['status'] = $data['status'] ?? 1;

        $country->update($data);

        return $this->sendSuccessResponse('Country updated successfully', $country);
    }

    // Delete country and its cities
    public function destroy($id)
    {
        $country = Country::with('cities')->findOrFail($id);
        $deletedCities = $country->cities;

        foreach ($deletedCities as $city) {
            $city->delete();
        }

        $country->delete();

        return $this->sendSuccessResponse('Country and its cities deleted successfully', [
            'deleted_country' => $country,
            'deleted_cities' => $deletedCities,
        ]);
    }
}

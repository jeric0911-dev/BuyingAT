<?php

namespace App\Http\Controllers\customer\state;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\State;

class StateController extends BaseController
{
    // Get all states with their countries
    public function index()
    {
        $states = State::all();

        if ($states->isEmpty()) {
            return $this->sendErrorResponse('No state data found');
        }

        return $this->sendSuccessResponse('States retrieved successfully', $states);
    }

    // Get single state with its country
    public function show($id)
    {
        $state = State::with('country')->find($id);

        if (!$state) {
            return $this->sendErrorResponse('State not found');
        }

        return $this->sendSuccessResponse('State retrieved successfully', $state);
    }
}

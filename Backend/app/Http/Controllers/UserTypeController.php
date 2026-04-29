<?php

namespace App\Http\Controllers;

use App\Models\UserType;
use Illuminate\Http\Request;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class UserTypeController extends BaseController
{
    // Get all user types
    public function index()
    {
        $userTypes = UserType::all();

        if ($userTypes->isEmpty()) {
            return $this->sendErrorResponse('No user types found', [], 404);
        }

        return $this->sendSuccessResponse('User types retrieved successfully', $userTypes);
    }

    // Store user type
    public function store(Request $request)
    {
        $data = $request->validate([
            'type' => 'required|string',
        ]);

        $userType = UserType::create($data);
        return $this->sendSuccessResponse('User type created successfully', $userType, 201);
    }

    // Get a single user type
    public function show($id)
    {
        $userType = UserType::findOrFail($id);
        return $this->sendSuccessResponse('User type retrieved successfully', $userType);
    }

    // Update user type
    public function update(Request $request, $id)
    {
        $userType = UserType::findOrFail($id);

        $data = $request->validate([
            'type' => 'required|string',
        ]);

        $userType->update($data);
        return $this->sendSuccessResponse('User type updated successfully', $userType);
    }

    // Delete user type
    public function destroy($id)
    {
        $userType = UserType::findOrFail($id);
        $userType->delete();
        return $this->sendSuccessResponse('User type deleted successfully');
    }
}

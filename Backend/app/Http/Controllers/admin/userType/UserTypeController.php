<?php

namespace App\Http\Controllers\admin\userType;

use App\Http\Controllers\BaseController;
use App\Models\UserType;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class UserTypeController extends BaseController
{
    // Get all user types
    public function index()
    {
        $userTypes = UserType::all();
        return $this->sendSuccessResponse('User types retrieved successfully', $userTypes);
    }

    // Store user type
    public function store(Request $request)
    {
        $data = $request->validate([
            'type' => 'required|string',
        ]);

        $userType = UserType::create($data);

        return $this->sendSuccessResponse('User type created successfully', $userType, Response::HTTP_CREATED);
    }

    // Get single user type
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

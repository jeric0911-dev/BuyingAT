<?php

namespace App\Http\Controllers\admin\auth;

use App\Http\Controllers\BaseController;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Laravel\Sanctum\PersonalAccessTokenFactory;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use App\Models\Admin;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Hash;
use App\Models\AdminType;


class AdminController extends BaseController
{
    //get all admins
    public function index()
    {
        try {
            $admins = Admin::with('adminType')->get();

            return $this->sendSuccessResponse('retrived successfully',  $admins);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('something went wrong', $th->getMessage());
        }
    }

    //get one admin
    public function show($id)
    {
        try {
            $admin = Admin::with('adminType')->findOrFail($id);

            return $this->sendSuccessResponse('retrived successfully', $admin);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('something went wrong', $th->getMessage());
        }
    }

    //store admin
    public function store(Request $request)
    {
        try {
            $data = $request->validate([
                'username' => 'required|string|max:255',
                'email' => 'required|email|unique:admins,email',
                'password' => 'required|string|min:6',
                'admin_type_id' => 'required|exists:admin_types,id',
            ]);

            $data['password'] = Hash::make($data['password']);

            $admin = Admin::create($data);

            $token = $admin->createToken('admin_token')->plainTextToken;

            $adminType = AdminType::findOrFail($request->admin_type_id);
            $admin->assignRole($adminType->type);

            return $this->sendSuccessResponse('signup successfully', [
                'admin' => $admin,
                'token' => $token,
                'token_type' => 'Bearer',
            ], 201);


        } catch (\Throwable $th) {
            return $this->sendErrorResponse('something went wrong', $th->getMessage());
        }
    }

    //update admin user
    public function update(Request $request, $id)
    {
        try {
            $admin = Admin::findOrFail($id);

            $data = $request->validate([
                'username' => 'required|string|max:255',
                'email' => 'required|email|unique:admins,email,' . $admin->id,
                'password' => 'nullable|string|min:6',
                'admin_type_id' => 'required|exists:admin_types,id',
            ]);

            if ($request->filled('password')) {
                $data['password'] = bcrypt($data['password']);
            } else {
                unset($data['password']);
            }

            $admin->update($data);
            $adminType = AdminType::findOrFail($request->admin_type_id);
            $admin->assignRole($adminType->type);
            return $this->sendSuccessResponse('updated successfully', $admin, 201);

        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Something went wrong', $th->getMessage());
        }
    }

    //delete admin
    public function destroy($id)
    {
        try {
            $admin = Admin::findOrFail($id);
            $admin->delete();

            return $this->sendSuccessResponse('deleted successfully');
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Something went wrong', $th->getMessage());
        }
    }


    //login admin
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $admin = Admin::with('adminType', 'adminType.roleParameters')->where('email', $request->email)->first();

        if (!$admin) {
            throw ValidationException::withMessages([
                'email' => ['Admin not found.'],
            ]);
        }

        if (!Hash::check($request->password, $admin->password)) {
            throw ValidationException::withMessages([
                'password' => ['Invalid admin credentials.'],
            ]);
        }

        $token = $admin->createToken('admin_token')->plainTextToken;

        return $this->sendSuccessResponse('Logged in', [
            'admin' => $admin,
            'token' => $token,
        ]);
    }

    //logout admin
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return $this->sendSuccessResponse('logged out successfully');
    }

}

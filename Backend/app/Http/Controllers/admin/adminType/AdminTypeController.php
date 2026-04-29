<?php

namespace App\Http\Controllers\admin\adminType;

use App\Http\Controllers\BaseController;
use App\Models\AdminType;
use App\Models\Admin;
use App\Models\AdminRolePermission;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Database\Eloquent\ModelNotFoundException;

class AdminTypeController extends BaseController
{
    // Get all admin types
    public function index()
    {
        $adminTypes = AdminType::with('roleParameters')->get();

        if ($adminTypes->isEmpty()) {
            return $this->sendErrorResponse('No admin types found', 404);
        }

        return $this->sendSuccessResponse('Admin types retrieved successfully', $adminTypes);
    }

    // Get a single admin type
    public function show($id)
    {
        try {
            $adminType = AdminType::with('roleParameters')->findOrFail($id);
            return $this->sendSuccessResponse('Admin type retrieved successfully', $adminType);
        } catch (ModelNotFoundException $e) {
            return $this->sendErrorResponse('Admin type not found', 404);
        }
    }

    // Store a new admin type
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|string|max:255|unique:admin_types,type',
            'role_parameters' => 'required|array',
            'role_parameters.*.name' => 'required|string|max:255',
            'role_parameters.*.view' => 'required|boolean',
            'role_parameters.*.edit' => 'required|boolean',
            'role_parameters.*.delete' => 'required|boolean'
        ]);

        DB::beginTransaction();

        try {
            $adminType = AdminType::create([
                'type' => $validated['type']
            ]);

            foreach ($validated['role_parameters'] as $param) {
                AdminRolePermission::create([
                    'admin_type_id' => $adminType->id,
                    'name' => $param['name'],
                    'view' => $param['view'],
                    'edit' => $param['edit'],
                    'delete' => $param['delete']
                ]);
            }

            DB::commit();

            $adminType->load('roleParameters');

            return $this->sendSuccessResponse('Admin type created successfully', $adminType, Response::HTTP_CREATED);
        } catch (\Throwable $th) {
            DB::rollBack();
            return $this->sendErrorResponse($th->getMessage(), 500);
        }
    }

    // Update an existing admin type
    public function update(Request $request, $id)
    {
        DB::beginTransaction();

        try {
            $validated = $request->validate([
                'type' => 'nullable|string|max:255|unique:admin_types,type,' . $id,
                'role_parameters' => 'required|array',
                'role_parameters.*.name' => 'required|string|max:255',
                'role_parameters.*.view' => 'required|integer',
                'role_parameters.*.edit' => 'required|integer',
                'role_parameters.*.delete' => 'required|integer'
            ]);

            $adminType = AdminType::findOrFail($id);

            if ($adminType->type === 'super') {
                return $this->sendErrorResponse('You cannot edit the super admin role', 403);
            }

            $adminUser = Admin::findOrFail(auth()->user()->id);
            if ($adminUser->adminType->type !== 'super') {
                return $this->sendErrorResponse('Only super admins can edit roles', 403);
            }

            if (isset($validated['type'])) {
                $adminType->update(['type' => $validated['type']]);
            }

            foreach ($validated['role_parameters'] as $param) {
                $adminType->roleParameters()->updateOrCreate(
                    ['name' => $param['name']],
                    [
                        'view' => $param['view'],
                        'edit' => $param['edit'],
                        'delete' => $param['delete']
                    ]
                );
            }

            DB::commit();

            $adminType->load('roleParameters');

            return $this->sendSuccessResponse('Admin type updated successfully', $adminType);
        } catch (\Throwable $th) {
            DB::rollBack();
            return $this->sendErrorResponse($th->getMessage(), 500);
        }
    }

    // Delete an admin type
    public function destroy($id)
    {
        try {
            $adminType = AdminType::findOrFail($id);
            $adminType->roleParameters()->delete();
            $adminType->delete();

            return $this->sendSuccessResponse('Admin type deleted successfully');
        } catch (ModelNotFoundException $e) {
            return $this->sendErrorResponse('Admin type not found', 404);
        }
    }
}

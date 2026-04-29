<?php

namespace App\Http\Controllers\Admin\AdminType;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\AdminType;
use App\Models\AdminRolePermission;
use Illuminate\Support\Facades\Log;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class AdminTypeControllerWithSpatie extends BaseController
{
    // List all admin types
    public function index()
    {
        try {
            $adminTypes = AdminType::with('roleParameters')->get();
            return $this->sendSuccessResponse('Admin Types fetched successfully.', $adminTypes);
        } catch (\Exception $e) {
            return $this->sendErrorResponse('Something went wrong.', $e->getMessage());
        }
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

    // Store new admin type with permissions
    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|unique:admin_types,type',
            'role_parameters' => 'required|array',
            'role_parameters.*.name' => 'required|string',
            'role_parameters.*.view' => 'boolean',
            'role_parameters.*.edit' => 'boolean',
            'role_parameters.*.delete' => 'boolean',
        ]);

        DB::beginTransaction();

        try {
            // Create AdminType and Role
            $adminType = AdminType::create(['type' => $validated['type']]);
            $role = Role::firstOrCreate([
                'name' => $validated['type'],
                'guard_name' => 'admin',
            ]);

            $allPermissions = [];

            foreach ($validated['role_parameters'] as $param) {
                AdminRolePermission::create([
                    'admin_type_id' => $adminType->id,
                    'name' => $param['name'],
                    'view' => $param['view'] ?? false,
                    'edit' => $param['edit'] ?? false,
                    'delete' => $param['delete'] ?? false,
                ]);

                foreach (['view', 'edit', 'delete'] as $action) {
                    if (!empty($param[$action])) {
                        $permName = "{$param['name']}.{$action}";
                        $permission = Permission::firstOrCreate([
                            'name' => $permName,
                            'guard_name' => 'admin'
                        ]);
                        $allPermissions[] = $permission->name;
                    }
                }
            }

            $role->syncPermissions($allPermissions);

            DB::commit();

            return $this->sendSuccessResponse($adminType->load('roleParameters'), 'Admin Type created successfully.');
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Failed to create Admin Type', [
                'error' => $e->getMessage(),
                'request' => $request->all()
            ]);
            return $this->sendErrorResponse('Failed to create Admin Type.', $e->getMessage());
        }
    }

    // Update admin type and permissions
    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'type' => 'required|string',
            'role_parameters' => 'required|array',
            'role_parameters.*.name' => 'required|string',
            'role_parameters.*.view' => 'boolean',
            'role_parameters.*.edit' => 'boolean',
            'role_parameters.*.delete' => 'boolean',
        ]);

        DB::beginTransaction();

        try {
            $adminType = AdminType::findOrFail($id);

            // Check if the type name has changed
            $oldTypeName = $adminType->type;
            $newTypeName = $validated['type'];

            // Update admin type name
            $adminType->update(['type' => $newTypeName]);

            // Get or create the related Spatie Role
            $role = Role::firstOrCreate([
                'name' => $newTypeName,
                'guard_name' => 'admin',
            ]);

            // Optional: rename old role name if type was renamed
            if ($oldTypeName !== $newTypeName) {
                $oldRole = Role::where('name', $oldTypeName)->first();
                if ($oldRole && $oldRole->id !== $role->id) {
                    $oldRole->delete(); // remove old role if no longer used
                }
            }

            // Delete existing custom admin role permissions
            AdminRolePermission::where('admin_type_id', $adminType->id)->delete();

            // Track all permission names for sync
            $allPermissions = [];

            foreach ($validated['role_parameters'] as $param) {
                AdminRolePermission::create([
                    'admin_type_id' => $adminType->id,
                    'name' => $param['name'],
                    'view' => $param['view'] ?? false,
                    'edit' => $param['edit'] ?? false,
                    'delete' => $param['delete'] ?? false,
                ]);

                foreach (['view', 'edit', 'delete'] as $action) {
                    if (!empty($param[$action])) {
                        $permName = "{$param['name']}.{$action}";
                        $permission = Permission::firstOrCreate([
                            'name' => $permName,
                            'guard_name' => 'admin'
                        ]);
                        $allPermissions[] = $permission->name;
                    }
                }
            }

            // Sync all new permissions to the role
            if ($role) {
                $role->syncPermissions($allPermissions);
            }

            DB::commit();

            return $this->sendSuccessResponse(
                $adminType->load('roleParameters'),
                'Admin Type updated successfully.'
            );
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Failed to update Admin Type', [
                'error' => $e->getMessage(),
                'request' => $request->all()
            ]);
            return $this->sendErrorResponse('Failed to update Admin Type.', $e->getMessage());
        }
    }

    // Delete admin type
    public function destroy($id)
    {
        DB::beginTransaction();

        try {
            $adminType = AdminType::findOrFail($id);

            // Delete associated role and permissions
            Role::where('name', $adminType->type)->delete();
            AdminRolePermission::where('admin_type_id', $id)->delete();
            $adminType->delete();

            DB::commit();

            return $this->sendSuccessResponse('Admin Type deleted successfully.', null);
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->sendErrorResponse('Failed to delete Admin Type.', $e->getMessage());
        }
    }
}

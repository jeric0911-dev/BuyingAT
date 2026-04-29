<?php

namespace App\Http\Controllers\admin\user;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Product;
use App\Services\ResponseService;

class UserController extends BaseController
{
    public function getAllUsers(Request $request)
    {
        try {
            $limit = $request->query('limit', 10);
            $status = $request->query('status');

            $query = User::select('id', 'name', 'email', 'phone', 'status', 'profile_img', 'user_type', 'created_at', 'blacklist', 'violation_count', 'last_violation_at')->with('userPackage');

            if (!is_null($status)) {
                $query->where('status', $status);
            }

            $users = $query->orderBy('created_at', 'desc')->paginate($limit);

            return ResponseService::successWithPagination('Users retrieved successfully', $users);
        } catch (\Throwable $th) {
            return ResponseService::error('No user found', $th->getMessage());
        }
    }


    //get single user
    public function getSingleUser(Request $request, $id)
    {
        try {
            if (!$id) {
                return ResponseService::error('User ID is required', 'User ID is missing');
            }

            $user = User::select('*')->findOrFail($id);

            if ($user->shop) {
                $shopProducts = $user->shop->products()->with('getGalleryImages', 'getCategory', 'getSubCategory', 'getBrand', 'colors', 'sizes', 'additionalInfo', 'variants', 'getAdvertInfo', 'getProductUser')->get();
                $user->products = $shopProducts;
            } else {
                $userProducts = Product::where('user_id', $user->id)->with('getGalleryImages', 'getCategory', 'getSubCategory', 'getBrand', 'colors', 'sizes', 'additionalInfo', 'variants', 'getAdvertInfo', 'getProductUser')->get();
                $user->products = $userProducts;
            }

            return ResponseService::success('User information retrieved successfully', $user);
        } catch (\Throwable $th) {
            return ResponseService::error('No user found', $th->getMessage());
        }
    }

    //update user profile infos
    public function updateUserStatus(Request $request)
    {
        try {
            $user = User::findOrFail($request->user_id);

            $data = $request->validate([
                'status' => 'required|in:1,0',
            ]);

            $user->status = $data['status'];
            $user->save();

            return ResponseService::success('User updated successfully', $user);
        } catch (\Throwable $th) {
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }
}

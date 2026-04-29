<?php

namespace App\Http\Controllers\admin\adminDashboard;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Shop;
use App\Models\SupportTicket;
use App\Models\ClientQuery;
use App\Models\Admin;
use App\Models\Category;
use App\Models\ContactUs;
use App\Models\CardRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Response;
use App\Services\ResponseService;

class AdminDashboardDataController extends BaseController
{
    // Get product by user
    public function getProductByUser(Request $request, $id)
    {
        try {
            $status = $request->input('status');

            $getProductByUser = Product::with([
                'getCategory',
                'getCountry',
                'getCity',
                'getGalleryImage',
                'colors',
                'sizes',
                'getAdvertInfo',
                'getProductUser'
            ])->where('user_id', $id);

            if ($status) {
                $getProductByUser->where('status', $status);
            }

            $getProductByUser = $getProductByUser->orderBy('created_at', 'desc')->get();

            $getUser = User::with('userPackage', 'wallet')->where('id', $id)->first();

            return $this->sendSuccessResponse('Product retrieved successfully', [
                'products' => $getProductByUser,
                'user' => $getUser
            ]);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Something went wrong', $th->getMessage());
        }
    }

    // Update user data
    public function updateUser(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);

            $data = $request->validate([
                'name' => 'string|max:255',
                'user_name' => 'string|max:255',
                'email' => 'email|unique:users,email,' . $id,
                'phone' => 'string|unique:users,phone,' . $id,
                'password' => 'string|nullable',
                'user_type_id' => 'exists:user_types,id',
                'country_id' => 'exists:countries,id',
                'city_id' => 'exists:cities,id',
                'zip_code' => 'string|nullable',
                'is_number_verified' => 'nullable|boolean',
                'user_img' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
                'facebook_id' => 'nullable|string|max:255',
                'google_id' => 'nullable|string|max:255',
                'location_lat' => 'nullable|string|max:255',
                'location_long' => 'nullable|string|max:255',
            ]);

            if ($request->hasFile('user_img')) {
                if ($user->user_img) {
                    Storage::disk('public')->delete($user->user_img);
                }

                $imagePath = $request->file('user_img')->store('user_images', 'public');
                $data['user_img'] = $imagePath;
            }

            if (!empty($data['password'])) {
                $data['password'] = Hash::make($data['password']);
            } else {
                unset($data['password']);
            }

            $user->update($data);

            return $this->sendSuccessResponse('User updated successfully', $user);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Something went wrong', $th->getMessage());
        }
    }

    // Admin dashboard product filter
    public function dataFilter(Request $request)
    {
        try {
            $status = $request->input('status');
            $query = Product::query();

            if ($status) {
                $query->where('status', $status);
            }

            $results = $query->with([
                'getCategory',
                'getCountry',
                'getCity',
                'getGalleryImage',
                'colors',
                'sizes',
                'getAdvertInfo',
                'getProductUser'
            ])->orderBy('created_at', 'desc')->get();

            return $this->sendSuccessResponse('Product filtered successfully', $results);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Something went wrong', $th->getMessage());
        }
    }

    // Total payments
    public function totalPayments(Request $request)
    {
        try {
            $limit = $request->input('limit', 10);
            $status = $request->input('status');
            $payments = Transaction::with('user');

            if ($status) {
                $payments = $payments->where('status', $status);
            }

            $payments = $payments->orderBy('created_at', 'desc')->paginate($limit);

            return $this->sendPaginatedResponse('Payments retrieved successfully', $payments);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Something went wrong', $th->getMessage());
        }
    }

    // Get statistics for the admin dashboard
    public function getStats()
    {
        $stats = [
            'active_cards'     => CardRequest::where('request_status', 'approved')->count(),
            'pending_cards'    => CardRequest::where('request_status', 'pending')->count(),
            'rejected_cards'   => CardRequest::where('request_status', 'rejected')->count(),

            'active_users'     => User::where('status', 1)->count(),
            'inactive_users'   => User::where('status', 0)->count(),

            'active_tickets'   => SupportTicket::where('status', 1)->count(),
            'client_queries'   => ContactUs::count(),

            'free_package_users'     => User::whereHas('userPackage', function ($q) {
                                        $q->where('package_name', 'free');
                                    })->count(),

            'standard_package_users' => User::whereHas('userPackage', function ($q) {
                                            $q->where('package_name', 'standard');
                                        })->count(),

            'premium_package_users'  => User::whereHas('userPackage', function ($q) {
                                            $q->where('package_name', 'premium');
                                        })->count(),

            'successful_deposits' => Transaction::where('status', 'success')->count(),

            'admins'           => Admin::count(),
            'categories'       => Category::count(),
        ];

        return $this->sendSuccessResponse('Stats fetched successfully', $stats);
    }
}

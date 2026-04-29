<?php

namespace App\Http\Controllers\admin\shop;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use App\Models\Shop;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Traits\ImageTrait;
use App\Traits\MailConfigTrait;

use App\Mail\ShopCreationApprovedEmail;
use App\Mail\ShopRejectionEmail;
use App\Mail\ShopDisabledEmail;
use App\Models\User;

use Illuminate\Support\Facades\Mail;


class ShopController extends BaseController
{
    use ImageTrait, MailConfigTrait;

    // List all shops for the authenticated user
    public function index()
    {
        $limit = request()->query('limit', 20);
        $status = request()->query('status');

        if ($status) {
            $shops = Shop::where('status', $status)->orderBy('created_at', 'desc')->paginate($limit);
        } else {
            $shops = Shop::orderBy('created_at', 'desc')->paginate($limit);
        }
        return $this->sendPaginatedResponse('Shops retrieved successfully', $shops);
    }

    // List all products for the authenticated user
    public function listUserProducts(Request $request)
    {
        $products = Product::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return $this->sendSuccessResponse('Products retrieved successfully', $products);
    }

    // Store a new shop
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'banner' => 'required|image|mimes:jpg,jpeg,png,webp,avif|max:2048',
            'user_id' => 'required|exists:users,id',
        ]);

        $bannerPath = $this->compressAndUploadImage($request->file('banner'), 'shop_banners');

        $shop = Shop::create([
            'user_id' => $data['user_id'],
            'name' => $data['name'],
            'description' => $data['description'],
            'banner' => $bannerPath,
        ]);

        return $this->sendSuccessResponse('Shop created successfully', $shop);
    }

    // Show single shop
    public function show($id)
    {
        $shop = Shop::where('id', $id)->firstOrFail();
        return $this->sendSuccessResponse('Shop retrieved successfully', $shop);
    }

    // Update a shop
    public function update(Request $request, $id)
    {
        $shop = Shop::where('id', $id)->firstOrFail();

        $data = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'banner' => 'sometimes|image|mimes:jpg,jpeg,png,webp,avif|max:2048',
            'user_id' => 'sometimes|required|exists:users,id',
        ]);

        if ($request->hasFile('banner')) {
            if ($shop->banner && Storage::disk('public')->exists($shop->banner)) {
                Storage::disk('public')->delete($shop->banner);
            }
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'shop_banners');
        }

        $shop->update($data);

        return $this->sendSuccessResponse('Shop updated successfully', $shop);
    }

    //approve or reject shop
    public function approveOrReject(Request $request)
    {
        $shop = Shop::where('id', $request->input('shop_id'))->firstOrFail();

        $data = $request->validate([
            'status' => 'required|in:active,rejected,disabled',
        ]);

        // Fetch the user
        $user = User::find($shop->user_id);
        if (!$user) {
            return $this->sendErrorResponse('User not found', 404);
        }

        $mailData = $this->getMailConfig();

        // Send email based on status
        switch ($data['status']) {
            case 'active':
                $user->update(['user_type' => 'vendor']);

                Mail::to($user->email)->send(
                    (new ShopCreationApprovedEmail($user->name, $shop->name))
                        ->from($mailData['from_email'], $mailData['from_name'])
                );
                break;

            case 'rejected':
                Mail::to($user->email)->send(
                    (new ShopRejectionEmail($user->name, $shop->name))
                        ->from($mailData['from_email'], $mailData['from_name'])
                );
                break;

            case 'disabled':
                $user->update(['user_type' => 'regular']);

                Mail::to($user->email)->send(
                    (new ShopDisabledEmail($user->name, $shop->name))
                        ->from($mailData['from_email'], $mailData['from_name'])
                );
                break;
        }

        $shop->update(['status' => $data['status']]);

        return $this->sendSuccessResponse('Shop status updated successfully', $shop);
    }



    // Delete a shop
    public function destroy($id)
    {
        $shop = Shop::where('user_id', Auth::id())->findOrFail($id);

        if ($shop->banner && Storage::disk('public')->exists($shop->banner)) {
            Storage::disk('public')->delete($shop->banner);
        }

        $shop->delete();

        return $this->sendSuccessResponse('Shop deleted successfully');
    }
}

<?php

namespace App\Http\Controllers\admin\social;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use App\Models\Social;
use App\Traits\ImageTrait;

class SocialController extends BaseController
{
    use ImageTrait;

    // Get all social icons
    public function index()
    {
        $socials = Social::all();
        return $this->sendSuccessResponse('Social data retrieved successfully', $socials);
    }

    // Get a single social icon
    public function show($id)
    {
        $social = Social::findOrFail($id);
        return $this->sendSuccessResponse('Social data retrieved successfully', $social);
    }

    // Store a new social icon
    public function store(Request $request)
    {
        $data = $request->validate([
            'link' => 'required|string|max:255',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp,avif|max:2048',
        ]);

        if ($request->hasFile('icon')) {
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'social_icon');
        }

        $social = Social::create($data);

        return $this->sendSuccessResponse('Social created successfully', $social, Response::HTTP_CREATED);
    }

    // Update an existing social icon
    public function update(Request $request, $id)
    {
        $social = Social::findOrFail($id);

        $data = $request->validate([
            'link' => 'required|string|max:255',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp,avif|max:2048',
        ]);

        if ($request->hasFile('icon')) {
            if ($social->icon && Storage::disk('public')->exists($social->icon)) {
                Storage::disk('public')->delete($social->icon);
            }
            $data['icon'] = $this->compressAndUploadImage($request->file('icon'), 'social_icon');
        }

        $social->update($data);

        return $this->sendSuccessResponse('Social updated successfully', $social);
    }

    // Delete a social icon
    public function destroy($id)
    {
        $social = Social::findOrFail($id);

        if ($social->icon && Storage::disk('public')->exists($social->icon)) {
            Storage::disk('public')->delete($social->icon);
        }

        $social->delete();

        return $this->sendSuccessResponse('Social data deleted successfully', null, Response::HTTP_NO_CONTENT);
    }
}

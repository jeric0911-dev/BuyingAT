<?php

namespace App\Http\Controllers\admin\heroSection;

use App\Http\Controllers\BaseController;
use App\Models\HeroSection;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class HeroSectionController extends BaseController
{
    // Get hero section data
    public function show()
    {
        $heroData = HeroSection::first();
        return $this->sendSuccessResponse('Hero section retrieved successfully', $heroData);
    }

    // Create or update hero section
    public function storeOrUpdate(Request $request)
    {
        $data = $request->validate([
            'hero_title'       => 'required|string',
            'hero_description' => 'required|string',
            'logo'             => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp,avif|max:2048',
            'banner'           => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,webp,avif|max:2048',
            'section'          => 'nullable|string|max:255',
        ]);

        $heroData = HeroSection::first();

        // Handle logo upload
        if ($request->hasFile('logo')) {
            if ($heroData && $heroData->logo) {
                Storage::disk('public')->delete($heroData->logo);
            }
            $data['logo'] = $request->file('logo')->store('hero_section', 'public');
        }

        // Handle banner upload
        if ($request->hasFile('banner')) {
            if ($heroData && $heroData->banner) {
                Storage::disk('public')->delete($heroData->banner);
            }
            $data['banner'] = $request->file('banner')->store('hero_section', 'public');
        }

        if ($heroData) {
            $heroData->update($data);
            $message = 'Hero section updated successfully';
        } else {
            $heroData = HeroSection::create($data);
            $message = 'Hero section created successfully';
        }

        return $this->sendSuccessResponse($message, $heroData->fresh());
    }
}

<?php

namespace App\Http\Controllers\admin\sliderAndAds;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\Slider;
use App\Traits\ImageTrait;

class SliderController extends BaseController
{
    use ImageTrait;

    // Get all sliders
    public function index()
    {
        $sliders = Slider::all();
        return $this->sendSuccessResponse('Sliders retrieved successfully', $sliders);
    }

    // Get a specific slider by ID
    public function show($id)
    {
        $slider = Slider::findOrFail($id);
        return $this->sendSuccessResponse('Slider retrieved successfully', $slider);
    }

    // Store a new slider
    public function store(Request $request)
    {
        $data = $request->validate([
            'img' => 'required|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'link' => 'required|url|max:255',
        ]);

        if ($request->hasFile('img')) {
            $data['img'] = $this->uploadImage($request);
        }

        $slider = Slider::create($data);

        return $this->sendSuccessResponse('Slider stored successfully', $slider, 201);
    }

    // Update an existing slider
    public function update(Request $request, $id)
    {
        $slider = Slider::findOrFail($id);

        $data = $request->validate([
            'img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'link' => 'nullable|url|max:255',
        ]);

        if ($request->hasFile('img')) {
            if ($slider->img && Storage::disk('public')->exists($slider->img)) {
                Storage::disk('public')->delete($slider->img);
            }
            $data['img'] = $this->uploadImage($request);
        }

        $slider->update($data);

        return $this->sendSuccessResponse('Slider updated successfully', $slider);
    }

    // Delete a slider
    public function destroy($id)
    {
        $slider = Slider::findOrFail($id);

        if ($slider->img && Storage::disk('public')->exists($slider->img)) {
            Storage::disk('public')->delete($slider->img);
        }

        $slider->delete();

        return $this->sendSuccessResponse('Slider deleted successfully');
    }

    // image upload helper function
    private function uploadImage(Request $request)
    {
        return $this->compressAndUploadImage($request->file('img'), 'sliders');
    }
}

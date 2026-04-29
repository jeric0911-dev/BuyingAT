<?php

namespace App\Http\Controllers\admin\testimonial;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Testimonial;
use Illuminate\Support\Facades\Storage;
use App\Traits\ImageTrait;

class TestimonialController extends BaseController
{
    use ImageTrait;

    // Get all testimonials
    public function index()
    {
        $testimonials = Testimonial::all();
        return $this->sendSuccessResponse('All testimonials loaded successfully', $testimonials);
    }

    // Get single testimonial
    public function show($id)
    {
        $testimonial = Testimonial::findOrFail($id);
        return $this->sendSuccessResponse('Testimonial loaded successfully', $testimonial);
    }

    // Store testimonial
    public function store(Request $request)
    {
        $data = $request->validate([
            'reviewer_name' => 'nullable|string|max:255',
            'message' => 'nullable|string|max:1000',
            'img' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'review' => 'nullable|string|max:255',
        ]);

        if ($request->hasFile('img')) {
            $data['img'] = $this->compressAndUploadImage($request->file('img'), 'testimonial_Images');
        }

        $testimonial = Testimonial::create($data);

        return $this->sendSuccessResponse('Testimonial created successfully', $testimonial, 201);
    }

    // Update testimonial
    public function update(Request $request, $id)
    {
        $testimonial = Testimonial::findOrFail($id);

        $data = $request->validate([
            'reviewer_name' => 'nullable|string|max:255',
            'message' => 'nullable|string|max:1000',
            'img' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'review' => 'nullable|string|max:255',
        ]);

        if ($request->hasFile('img')) {
            if ($testimonial->img) {
                Storage::disk('public')->delete($testimonial->img);
            }
            $data['img'] = $this->compressAndUploadImage($request->file('img'), 'testimonial_Images');
        }

        $testimonial->update($data);

        return $this->sendSuccessResponse('Testimonial updated successfully', $testimonial);
    }

    // Delete testimonial
    public function destroy($id)
    {
        $testimonial = Testimonial::findOrFail($id);

        if ($testimonial->img) {
            Storage::disk('public')->delete($testimonial->img);
        }

        $testimonial->delete();

        return $this->sendSuccessResponse('Testimonial deleted successfully');
    }
}

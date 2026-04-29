<?php

namespace App\Http\Controllers\customer\testimonial;

use App\Http\Controllers\BaseController;
use App\Models\Testimonial;
use App\Services\ResponseService;
use Illuminate\Http\Request;

class TestimonialController extends BaseController
{
    // Get all testimonials
    public function index(Request $request)
    {
        $testimonials = Testimonial::all();

        if ($testimonials->isEmpty()) {
            return $this->sendErrorResponse('No testimonials found');
        }

        return $this->sendSuccessResponse('All testimonials loaded successfully', $testimonials);
    }

    // Get a single testimonial
    public function show($id)
    {
        $testimonial = Testimonial::findOrFail($id);
        return $this->sendSuccessResponse('Testimonial loaded successfully', $testimonial);
    }
}

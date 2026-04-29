<?php

namespace App\Http\Controllers\admin\faq;

use App\Http\Controllers\BaseController;
use App\Models\Faq;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class FaqController extends BaseController
{
    // Get all FAQs
    public function index()
    {
        $faqs = Faq::all();
        return $this->sendSuccessResponse('FAQs retrieved successfully', $faqs);
    }

    // Store FAQ
    public function store(Request $request)
    {
        $data = $request->validate([
            'qua' => 'required|string',
            'ans' => 'required|string',
        ]);

        $faq = Faq::create($data);

        return $this->sendSuccessResponse('FAQ created successfully', $faq, Response::HTTP_CREATED);
    }

    // Get single FAQ
    public function show($id)
    {
        $faq = Faq::findOrFail($id);
        return $this->sendSuccessResponse('FAQ retrieved successfully', $faq);
    }

    // Update FAQ
    public function update(Request $request, $id)
    {
        $faq = Faq::findOrFail($id);

        $data = $request->validate([
            'qua' => 'required|string',
            'ans' => 'required|string',
        ]);

        $faq->update($data);

        return $this->sendSuccessResponse('FAQ updated successfully', $faq->fresh());
    }

    // Delete FAQ
    public function destroy($id)
    {
        $faq = Faq::findOrFail($id);
        $faq->delete();
        return $this->sendSuccessResponse('FAQ deleted successfully', null, 200);
    }
}

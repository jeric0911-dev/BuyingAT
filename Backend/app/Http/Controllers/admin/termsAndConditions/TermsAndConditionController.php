<?php

namespace App\Http\Controllers\admin\termsAndConditions;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\TermsAndCondition;

class TermsAndConditionController extends BaseController
{
    // Get the first terms and conditions record
    public function getOne()
    {
        $getOne = TermsAndCondition::first();
        return $this->sendSuccessResponse('Terms and conditions retrieved successfully', $getOne);
    }

    // Store new terms and conditions
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'nullable|string',
            'content' => 'required|string',
        ]);

        $termsAndConditionData = TermsAndCondition::create($data);

        return $this->sendSuccessResponse('Terms and conditions created successfully', $termsAndConditionData, 201);
    }

    // Update existing terms and conditions
    public function update(Request $request, $id)
    {
        $termsAndCondition = TermsAndCondition::findOrFail($id);

        $data = $request->validate([
            'title' => 'nullable|string',
            'content' => 'required|string',
        ]);

        $termsAndCondition->update($data);

        return $this->sendSuccessResponse('Terms and conditions updated successfully', $termsAndCondition);
    }
}

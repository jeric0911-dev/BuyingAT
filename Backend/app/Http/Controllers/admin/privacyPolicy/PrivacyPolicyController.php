<?php

namespace App\Http\Controllers\admin\privacyPolicy;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\PrivacyPolicy;

class PrivacyPolicyController extends BaseController
{
    // Get the first privacy policy
    public function getOne()
    {
        $getOne = PrivacyPolicy::first();
        return $this->sendSuccessResponse('Privacy policy retrieved successfully', $getOne);
    }

    // Store new privacy policy
    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'nullable|string',
            'content' => 'required|string',
        ]);

        $privacyPolicy = PrivacyPolicy::create($data);

        return $this->sendSuccessResponse('Privacy policy created successfully', $privacyPolicy, 201);
    }

    // Update privacy policy
    public function update(Request $request, $id)
    {
        $privacyPolicy = PrivacyPolicy::findOrFail($id);

        $data = $request->validate([
            'title' => 'nullable|string',
            'content' => 'required|string',
        ]);

        $privacyPolicy->update($data);

        return $this->sendSuccessResponse('Privacy policy updated successfully', $privacyPolicy);
    }
}

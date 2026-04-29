<?php

namespace App\Http\Controllers\admin\language;

use App\Http\Controllers\BaseController;
use App\Models\Language;
use Illuminate\Http\Request;

class LanguageController extends BaseController
{
    // Get all languages
    public function index()
    {
        $languages = Language::all();
        return $this->sendSuccessResponse('Languages retrieved successfully', $languages);
    }

    // Store a new language
    public function store(Request $request)
    {
        $data = $request->validate([
            'language_name' => 'required|string',
        ]);

        $language = Language::create($data);
        return $this->sendSuccessResponse('Language created successfully', $language, 201);
    }

    // Show a specific language
    public function show($id)
    {
        $language = Language::findOrFail($id);
        return $this->sendSuccessResponse('Language retrieved successfully', $language);
    }

    // Update a specific language
    public function update(Request $request, $id)
    {
        $language = Language::findOrFail($id);

        $data = $request->validate([
            'language_name' => 'required|string',
        ]);

        $language->update($data);

        return $this->sendSuccessResponse('Language updated successfully', $language);
    }

    // Delete a specific language
    public function destroy($id)
    {
        $language = Language::findOrFail($id);
        $language->delete();

        return $this->sendSuccessResponse('Language deleted successfully');
    }
}

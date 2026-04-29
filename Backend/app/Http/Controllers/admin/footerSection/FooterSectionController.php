<?php

namespace App\Http\Controllers\admin\footerSection;

use App\Http\Controllers\BaseController;
use App\Models\FooterSection;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Response;
use App\Traits\ImageTrait;

class FooterSectionController extends BaseController
{
    use ImageTrait;

    // Get the footer section data
    public function show()
    {
        $footerData = FooterSection::first();
        return $this->sendSuccessResponse('Footer section retrieved successfully', $footerData);
    }

    // Store or update the footer section
    public function storeOrUpdate(Request $request)
    {
        $data = $request->validate([
            'footer_logo'   => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif,svg|max:2048',
            'number'        => 'required|string|max:255',
            'address'       => 'required|string|max:255',
            'mail'          => 'required|string|max:255',
            'copyright'     => 'nullable|string|max:255',
            'google_play'   => 'nullable|string|max:255',
            'app_store'     => 'nullable|string|max:255',
        ]);

        $footerData = FooterSection::first();

        if ($request->hasFile('footer_logo')) {
            if ($footerData && $footerData->footer_logo) {
                Storage::disk('public')->delete($footerData->footer_logo);
            }
            $data['footer_logo'] = $this->compressAndUploadImage($request->file('footer_logo'), 'footer_logo');
        }

        if ($footerData) {
            $footerData->update($data);
            $message = 'Footer section updated successfully';
        } else {
            $footerData = FooterSection::create($data);
            $message = 'Footer section created successfully';
        }

        return $this->sendSuccessResponse($message, $footerData->fresh());
    }
}

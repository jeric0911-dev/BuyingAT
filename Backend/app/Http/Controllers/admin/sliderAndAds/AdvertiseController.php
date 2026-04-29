<?php

namespace App\Http\Controllers\admin\sliderAndAds;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\Advertise;
use App\Traits\ImageTrait;

class AdvertiseController extends BaseController
{
    use ImageTrait;

    // Get first
    public function index()
    {
        $advertise = Advertise::first();

        if (!$advertise) {
            return $this->sendErrorResponse('Ad not found', [], 404);
        }

        return $this->sendSuccessResponse('Ad retrieved successfully', $advertise);
    }

    // Store or update the single advertisement entry
    public function upsert(Request $request)
    {
        $rules = [];
        foreach (range(1, 8) as $i) {
            $rules["img_$i"] = 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048';
            $rules["link_$i"] = 'nullable|url|max:255';
        }

        $validated = $request->validate($rules);

        $advertise = Advertise::first() ?? new Advertise();

        foreach (range(1, 8) as $i) {
            $imgKey = "img_$i";
            $linkKey = "link_$i";

            if ($request->hasFile($imgKey)) {
                if ($advertise->$imgKey && Storage::disk('public')->exists($advertise->$imgKey)) {
                    Storage::disk('public')->delete($advertise->$imgKey);
                }

                $validated[$imgKey] = $request->file($imgKey)->store('advertise', 'public');
            } else {
                $validated[$imgKey] = $advertise->$imgKey;
            }

            $validated[$linkKey] = $request->input($linkKey, $advertise->$linkKey);
        }

        $advertise->fill($validated)->save();

        return $this->sendSuccessResponse('Ad saved successfully', $advertise);
    }

    // Delete the only ad entry
    public function destroy()
    {
        $advertise = Advertise::first();

        if (!$advertise) {
            return $this->sendErrorResponse('Ad not found', [], 404);
        }

        foreach (range(1, 8) as $i) {
            $imgKey = "img_$i";
            if ($advertise->$imgKey && Storage::disk('public')->exists($advertise->$imgKey)) {
                Storage::disk('public')->delete($advertise->$imgKey);
            }
        }

        $advertise->delete();

        return $this->sendSuccessResponse('Ad deleted successfully');
    }
}

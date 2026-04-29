<?php

namespace App\Http\Controllers\admin\state;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\State;
use App\Traits\ImageTrait;
use Illuminate\Http\Response;

class StateController extends BaseController
{
    use ImageTrait;

    // Get all states
    public function index()
    {
        $states = State::with('country')->get();
        return $this->sendSuccessResponse('States retrieved successfully', $states);
    }

    // Store a new state
    public function store(Request $request)
    {
        $data = $request->validate([
            'country_id' => 'required|exists:countries,id',
            'status' => 'nullable|string',
            'state_name' => 'required|string',
            'img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'lat' => 'nullable',
            'long' => 'nullable'
        ]);

        $data['status'] = $data['status'] ?? 1;

        if ($request->hasFile('img')) {
            $data['img'] = $this->compressAndUploadImage($request->file('img'), 'state_image');
        }

        $state = State::create($data);

        return $this->sendSuccessResponse('State created successfully', $state, Response::HTTP_CREATED);
    }

    // Get a single state
    public function show($id)
    {
        $state = State::with('country')->findOrFail($id);
        return $this->sendSuccessResponse('State retrieved successfully', $state);
    }

    // Update an existing state
    public function update(Request $request, $id)
    {
        $state = State::findOrFail($id);

        $data = $request->validate([
            'country_id' => 'nullable|exists:countries,id',
            'status' => 'nullable|string',
            'state_name' => 'nullable|string',
            'img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'lat' => 'nullable',
            'long' => 'nullable'
        ]);

        if ($request->hasFile('img')) {
            if ($state->img && Storage::disk('public')->exists($state->img)) {
                Storage::disk('public')->delete($state->img);
            }

            $data['img'] = $this->compressAndUploadImage($request->file('img'), 'state_image');
        }

        $state->update($data);

        return $this->sendSuccessResponse('State updated successfully', $state);
    }

    // Delete a state
    public function destroy($id)
    {
        $state = State::findOrFail($id);

        if ($state->img && Storage::disk('public')->exists($state->img)) {
            Storage::disk('public')->delete($state->img);
        }

        $state->delete();

        return $this->sendSuccessResponse('State deleted successfully', null, Response::HTTP_NO_CONTENT);
    }
}

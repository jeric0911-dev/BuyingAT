<?php

namespace App\Http\Controllers;

use App\Models\ContactUs;
use Illuminate\Http\Request;
use App\Http\Controllers\BaseController;

class ContactUsController extends BaseController
{
    // Get all contact messages
    public function index()
    {
        $contacts = ContactUs::all();
        return $this->sendSuccessResponse('Contact messages retrieved successfully', $contacts);
    }

    // Get a single contact message
    public function show($id)
    {
        $contact = ContactUs::findOrFail($id);
        return $this->sendSuccessResponse('Contact message retrieved successfully', $contact);
    }

    // Store a new contact message
    public function store(Request $request)
    {
        $data = $request->validate([
            'name'    => 'required|string|max:255',
            'email'   => 'required|email|max:255',
            'message' => 'required|string',
        ]);

        $contact = ContactUs::create($data);

        return $this->sendSuccessResponse('Message submitted successfully', $contact);
    }

    // Update a contact message
    public function update(Request $request, $id)
    {
        $contact = ContactUs::findOrFail($id);

        $data = $request->validate([
            'name'    => 'sometimes|required|string|max:255',
            'email'   => 'sometimes|required|email|max:255',
            'message' => 'sometimes|required|string',
        ]);

        $contact->update($data);

        return $this->sendSuccessResponse('Contact message updated successfully', $contact);
    }

    // Delete a contact message
    public function destroy($id)
    {
        $contact = ContactUs::findOrFail($id);
        $contact->delete();

        return $this->sendSuccessResponse('Contact message deleted successfully');
    }
}

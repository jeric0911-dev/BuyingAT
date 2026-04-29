<?php

namespace App\Http\Controllers\admin\contactUs;

use App\Http\Controllers\BaseController;
use Faker\Provider\Base;
use Illuminate\Http\Request;
use App\Models\ContactUs;

class ContactUsController extends BaseController
{
    // Get all contact messages
    public function index(Request $request)
    {
        $limit = $request->get('limit', 10);
        $contacts = ContactUs::orderBy('created_at', 'desc')->paginate($limit);
        
        return $this->sendPaginatedResponse('Contact messages retrieved successfully', $contacts);
    }

    // Get a single contact message
    public function show($id)
    {
        $contact = ContactUs::findOrFail($id);
        return $this->sendSuccessResponse('Contact message retrieved successfully', $contact);
    }

    // Delete a contact message
    public function destroy($id)
    {
        $contact = ContactUs::findOrFail($id);
        $contact->delete();

        return $this->sendSuccessResponse('Contact message deleted successfully');
    }
}

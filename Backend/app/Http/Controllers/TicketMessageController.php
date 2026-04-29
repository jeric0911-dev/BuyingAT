<?php
namespace App\Http\Controllers;

use App\Models\TicketMessage;
use App\Models\TicketAttachment;
use Illuminate\Http\Request;
use Carbon\Carbon;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class TicketMessageController extends BaseController
{
    // Get all messages for a ticket
    public function getMessages($id)
    {
        $messages = TicketMessage::with([
            'attachments',
            'supportTicket' => function ($query) {
                $query->select('id', 'ticket_id', 'status');
            },
            'user' => function ($query) {
                $query->select('id', 'name', 'profile_img');
            },
        ])->where('ticket_id', $id)->orderBy('created_at', 'desc')->get();

        return $this->sendSuccessResponse('Messages retrieved successfully', $messages);
    }

    // Store a new message for a ticket
    public function store(Request $request)
    {
        $data = $request->validate([
            'ticket_id' => 'required|integer',
            'message' => 'required|string',
            'file' => 'array',
            'file.*' => 'mimes:jpeg,png,jpg,gif,bmp,tiff,svg,pdf,doc,docx,ppt,pptx,xls,xlsx,mp4,mov,avi,wmv|max:2048',
        ]);

        $user = auth()->user();
        $isAdmin = isset($user->admin_type_id);

        // Build message data
        $messageData = [
            'ticket_id' => $data['ticket_id'],
            'message' => $data['message'],
        ];

        if (!$isAdmin) {
            $messageData['user_id'] = $user->id;
        }

        $message = TicketMessage::create($messageData);

        // Handle file uploads
        if ($request->hasFile('file')) {
            $filesData = [];

            foreach ($request->file('file') as $file) {
                $filePath = $file->store('ticket_attachments', 'public');

                $fileData = [
                    'ticket_id' => $data['ticket_id'],
                    'message_id' => $message->id,
                    'file' => $filePath,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                if (!$isAdmin) {
                    $fileData['user_id'] = $user->id;
                }

                $filesData[] = $fileData;
            }

            TicketAttachment::insert($filesData);
        }

        return $this->sendSuccessResponse('Message created successfully', $message, 201);
    }

}

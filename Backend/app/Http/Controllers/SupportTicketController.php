<?php

namespace App\Http\Controllers;

use App\Models\SupportTicket;
use App\Models\TicketAttachment;
use App\Models\TicketMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class SupportTicketController extends BaseController
{
    // Get all support tickets
    public function index()
    {
        $tickets = SupportTicket::where('user_id', auth()->user()->id)->orderBy('created_at', 'desc')->get();
        return $this->sendSuccessResponse('Tickets retrieved successfully', $tickets);
    }

    // Get all support tickets
    public function allForAdmins()
    {
        $tickets = SupportTicket::query();
        $status = request()->query('status');

        if ($status) {
            $tickets->where('status', $status);
        }

        $tickets = $tickets->orderBy('created_at', 'desc')->get();

        return $this->sendSuccessResponse('Tickets retrieved successfully', $tickets);
    }

    // Get one ticket
    public function show($id)
    {
        $ticket = SupportTicket::with([
            'attachment',
            'messages' => function ($query) {
                $query->select('id', 'ticket_id', 'user_id', 'message', 'created_at');
            },
            'user' => function ($query) {
                $query->select('id', 'name', 'profile_img');
            },
        ])->findOrFail($id);
        return $this->sendSuccessResponse('Ticket retrieved successfully', $ticket);
    }

    // Store a new support ticket
    public function store(Request $request)
    {
        $data = $request->validate([
            'subject' => 'required|string',
            'priority' => 'required|string|max:255',
            'message' => 'required|string',
            'file' => 'array',
            'file.*' => 'mimes:jpeg,png,jpg,gif,bmp,tiff,svg,pdf,doc,docx,ppt,pptx,xls,xlsx,mp4,mov,avi,wmv,zip|max:2048',
        ]);

        $user = auth()->user();
        $isAdmin = isset($user->admin_type_id);

        $ticketData = [
            'subject' => $data['subject'],
            'priority' => $data['priority'],
            'message' => $data['message'],
            'status' => $data['status'] ?? 1,
            'ticket_id' => 'TICKET#' . Str::random(8),
        ];

        if (!$isAdmin) {
            $ticketData['user_id'] = $user->id;
        }

        $ticket = SupportTicket::create($ticketData);

        // Same logic for TicketMessage
        $messageData = [
            'ticket_id' => $ticket->id,
            'message' => $data['message'],
        ];

        if (!$isAdmin) {
            $messageData['user_id'] = $user->id;
        }

        TicketMessage::create($messageData);

        // Same logic for attachments
        if ($request->hasFile('file')) {
            $filesData = [];

            foreach ($request->file('file') as $file) {
                $filePath = $file->store('ticket_attachments', 'public');

                $fileData = [
                    'ticket_id' => $ticket->id,
                    'file' => $filePath,
                ];

                if (!$isAdmin) {
                    $fileData['user_id'] = $user->id;
                }

                $filesData[] = $fileData;
            }

            TicketAttachment::insert($filesData);
        }

        return $this->sendSuccessResponse('Ticket created successfully', [
            'ticket' => $ticket->fresh(),
            'files' => $ticket->attachment,
        ], 201);
    }


    // Close ticket
    public function closeTicket($id)
    {
        $ticket = SupportTicket::findOrFail($id);
        $ticket->update(['status' => 0]);

        return $this->sendSuccessResponse('Ticket closed successfully');
    }

    // Update ticket
    public function update(Request $request, $id)
    {
        $ticket = SupportTicket::findOrFail($id);

        $data = $request->validate([
            'subject' => 'required|string',
            'priority' => 'required|string|max:255',
            'message' => 'required|string',
            'file' => 'array',
            'file.*' => 'mimes:jpeg,png,jpg,gif,bmp,tiff,svg,pdf,doc,docx,ppt,pptx,xls,xlsx,mp4,mov,avi,wmv|max:2048',
        ]);

        foreach ($ticket->attachment as $attachment) {
            Storage::disk('public')->delete($attachment->file);
        }

        $ticket->update([
            'subject' => $data['subject'],
            'priority' => $data['priority'],
            'message' => $data['message'],
            'status' => $data['status'],
        ]);

        $ticket->attachment()->delete();

        if ($request->hasFile('file')) {
            $filesData = [];

            foreach ($request->file('file') as $file) {
                $filePath = $file->store('ticket_attachments', 'public');
                $filesData[] = [
                    'ticket_id' => $ticket->id,
                    'file' => $filePath,
                ];
            }

            TicketAttachment::insert($filesData);
        }

        return $this->sendSuccessResponse('Ticket updated successfully', [
            'ticket' => $ticket->fresh(),
            'files' => $ticket->attachment,
        ]);
    }

    // Delete ticket
    public function destroy($id)
    {
        $ticket = SupportTicket::findOrFail($id);
        $ticket->delete();

        return $this->sendSuccessResponse('Ticket deleted successfully');
    }
}

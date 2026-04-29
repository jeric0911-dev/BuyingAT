<?php

namespace App\Http\Controllers\customer\conversation;

use Illuminate\Http\Request;
use App\Models\ConversationThread;
use App\Models\Message;
use App\Events\MessageSent;
use App\Http\Controllers\BaseController;
use App\Services\ResponseService;
use Faker\Provider\Base;
use Illuminate\Support\Facades\Log;

class MessageController extends BaseController
{
    // Send message
    public function createMessage(Request $request)
    {
        $validated = $request->validate([
            'conversation_id' => 'required|exists:conversation_threads,id',
            'message' => 'required|string',
        ]);

        $validated['user_id'] = auth()->id();

        $message = Message::create($validated);

        // Broadcast immediately without queuing
        try {
            $broadcast = broadcast(new MessageSent($message));
            \Log::info('📡 Message broadcasted successfully', [
                'message_id' => $message->id,
                'conversation_id' => $message->conversation_id,
                'broadcast_result' => $broadcast
            ]);
        } catch (\Exception $e) {
            \Log::error('❌ Failed to broadcast message', [
                'message_id' => $message->id,
                'error' => $e->getMessage()
            ]);
        }

        return $this->sendSuccessResponse('Message sent successfully', $message, 201);
    }

    // Get all messages in a conversation
    public function getMessages($id)
    {
        $conversation = ConversationThread::findOrFail($id);

        $messages = $conversation->messages()->orderBy('created_at', 'desc')->get();

        return $this->sendSuccessResponse('Messages retrieved successfully', $messages);
    }

    // Send image attachment
    public function createAttachment(Request $request)
    {
        $validated = $request->validate([
            'conversation_id' => 'required|exists:conversation_threads,id',
            'url' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $attachment = new Message();
        $attachment->conversation_id = $validated['conversation_id'];
        $attachment->user_id = auth()->id();

        if ($request->hasFile('url')) {
            $imgPath = $request->file('url')->store('conversations_img', 'public');
            $attachment->url = $imgPath;
        }

        $attachment->save();

        broadcast(new MessageSent($attachment));

        return $this->sendSuccessResponse('Attachment created successfully', $attachment, 201);
    }
}

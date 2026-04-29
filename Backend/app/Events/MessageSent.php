<?php

namespace App\Events;

use App\Models\Message;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class MessageSent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;


    public $message;

    public function __construct(Message $message)
    {
        $this->message = $message;
        \Log::info('📨 MessageSent event created', [
            'message_id' => $message->id,
            'conversation_id' => $message->conversation_id,
            'user_id' => $message->user_id
        ]);
    }


    public function broadcastOn(): array
    {
        // Always broadcast to the conversation channel
        $conversationChannel = 'conversation.' . $this->message->conversation_id;

        // Try to load the conversation to get both participants (sender/receiver)
        $conversation = $this->message->conversation()->first();

        $channels = [
            new Channel($conversationChannel),
        ];

        if ($conversation) {
            // Broadcast to sender user channel
            if (!empty($conversation->sender_id)) {
                $channels[] = new Channel('user.' . $conversation->sender_id);
            }

            // Broadcast to receiver user channel (avoid duplicate if same as sender)
            if (!empty($conversation->receiver_id) && $conversation->receiver_id !== $conversation->sender_id) {
                $channels[] = new Channel('user.' . $conversation->receiver_id);
            }

            \Log::info('📡 Broadcasting to channels', [
                'conversation_channel' => $conversationChannel,
                'sender_channel' => isset($conversation->sender_id) ? 'user.' . $conversation->sender_id : null,
                'receiver_channel' => isset($conversation->receiver_id) ? 'user.' . $conversation->receiver_id : null,
            ]);
        } else {
            \Log::info('📡 Broadcasting to conversation channel only (no conversation loaded)', [
                'conversation_channel' => $conversationChannel,
            ]);
        }

        return $channels;
    }

    public function broadcastAs(){
        \Log::info('📡 Broadcasting as event', ['event' => 'message.sent']);
        return 'message.sent';
    }

    public function broadcastWith()
    {
        \Log::info('📡 Broadcasting with data', ['message' => $this->message->toArray()]);
        return ['message' => $this->message];
    }

    // php artisan queue:work

}

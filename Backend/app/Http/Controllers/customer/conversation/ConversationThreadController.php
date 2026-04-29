<?php

namespace App\Http\Controllers\customer\conversation;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\ConversationThread;
use App\Models\Product;
use App\Models\AdvertInfo;
use App\Models\User;
use App\Services\ResponseService;

class ConversationThreadController extends BaseController
{
    // Create new or return existing conversation thread
    public function create(Request $request)
    {
        $data = $request->validate([
            'sender_id' => 'required|exists:users,id',
            'receiver_id' => 'required|exists:users,id',
            'product_id' => 'nullable',
            'buyer_profile_id' => 'nullable|exists:buyer_profiles,id',
            'conversation_type' => 'required|in:product,buyer_profile',
        ]);

        // Determine which type of conversation and set appropriate fields
        if ($data['conversation_type'] === 'product') {
            $data['product_id'] = $data['product_id'] ?? null;
            $data['buyer_profile_id'] = null;
        } else {
            $data['buyer_profile_id'] = $data['buyer_profile_id'] ?? null;
            $data['product_id'] = null;
        }

        $existingThread = ConversationThread::where('sender_id', $data['sender_id'])
            ->where('receiver_id', $data['receiver_id'])
            ->where('conversation_type', $data['conversation_type']);

        if ($data['conversation_type'] === 'product') {
            $existingThread->where('product_id', $data['product_id']);
        } else {
            $existingThread->where('buyer_profile_id', $data['buyer_profile_id']);
        }

        $existingThread = $existingThread->first();

        if ($existingThread) {
            return ResponseService::success('Conversation thread already exists', $existingThread);
        }

        $thread = ConversationThread::create($data);

        // Handle product-specific metrics (only for actual product conversations)
        if ($data['conversation_type'] === 'product' && $data['product_id']) {
            try {
                // Try to find as a Product first (for actual products)
                $product = Product::find($data['product_id']);
                
                if ($product) {
                    // This is a real product, handle metrics
                    $advertInfo = $product->getAdvertInfo;

                    if ($advertInfo) {
                        $advertInfo->increment('messages');

                        if ($product->is_featured === true) {
                            $advertInfo->increment('after_ads_messages');
                        }

                        $advertInfo->save();
                    }
                }
                // If not found as Product, it's likely a card (seller_inventory)
                // Cards don't have advert metrics, so we skip them silently
            } catch (\Exception $e) {
                // Log the error but don't fail the conversation creation
                \Log::info('Product metrics not applicable for card conversation: ' . $e->getMessage());
            }
        }

        return $this->sendSuccessResponse('Conversation thread created successfully', $thread, 201);
    }

    // Get all threads
    public function index()
    {
        $threads = ConversationThread::all();

        return $this->sendSuccessResponse('All conversation threads retrieved successfully', $threads);
    }

    public function getUserConversationThreads()
    {
        $user = User::findOrFail(auth()->id());

        $conversationThreads = $user->conversations()
            ->select(['id', 'sender_id', 'receiver_id', 'product_id', 'buyer_profile_id', 'conversation_type', 'created_at'])
            ->with([
                'messages' => function ($query) {
                    $query->select(['id', 'conversation_id', 'user_id', 'message', 'created_at'])
                        ->orderBy('created_at', 'desc')
                        ->limit(1);
                },
                'sender' => function ($query) {
                    $query->select(['id', 'name', 'email', 'profile_img'])
                        ->with([
                            'profile' => function ($q) {
                                $q->select(['id', 'user_id', 'username', 'avatar', 'bio']);
                            }
                        ]);
                },
                'receiver' => function ($query) {
                    $query->select(['id', 'name', 'email', 'profile_img'])
                        ->with([
                            'profile' => function ($q) {
                                $q->select(['id', 'user_id', 'username', 'avatar', 'bio']);
                            }
                        ]);
                },
                'product' => function ($query) {
                    $query->select(['id', 'product_title', 'user_id', 'price', 'discounted_price', 'updated_at'])
                        ->with([
                            'getGalleryImages' => function ($q) {
                                $q->select(['id', 'product_id', 'img']);
                            },
                            'getProductUser' => function ($q) {
                                $q->select(['id', 'name', 'profile_img']);
                            }
                        ]);
                },
                'buyerProfile' => function ($query) {
                    $query->select(['id', 'user_id', 'categories', 'preferences', 'budget_min', 'budget_max'])
                        ->with([
                            'user' => function ($q) {
                                $q->select(['id', 'name', 'email', 'profile_img'])
                                    ->with([
                                        'profile' => function ($profileQuery) {
                                            $profileQuery->select(['id', 'user_id', 'username', 'avatar', 'bio']);
                                        }
                                    ]);
                            }
                        ]);
                }
            ])
            ->orderBy('created_at', 'desc')
            ->get();

        // Calculate unread_count for each conversation based on message read status
        foreach ($conversationThreads as $thread) {
            // Determine which read field to check based on user role
            $readField = ($thread->sender_id == $user->id) ? 'read_by_sender_at' : 'read_by_receiver_at';
            
            // Count messages from other user that haven't been read
            $unreadCount = \App\Models\Message::where('conversation_id', $thread->id)
                ->where('user_id', '!=', $user->id)
                ->whereNull($readField)
                ->count();

            // Set unread_count as an attribute that will be included in JSON
            $thread->unread_count = $unreadCount;
        }

        return $this->sendSuccessResponse('User conversation threads retrieved successfully', $conversationThreads);
    }


    // Get specific thread for a user
    public function getUserConversationThreadSingle($userId, $conversationId)
    {
        $user = User::findOrFail($userId);

        $conversationThread = $user->conversations()
            ->with('product.getTitleImage', 'product.getProductUser')
            ->find($conversationId);

        if (!$conversationThread) {
            return ResponseService::error('Conversation not found', null, 404);
        }

        return ResponseService::success('User conversation thread retrieved successfully', [
            'conversation_thread' => $conversationThread
        ]);
    }

    // Mark conversation as read
    public function markAsRead($conversationId)
    {
        try {
            $userId = auth()->id();
            $conversation = ConversationThread::findOrFail($conversationId);

            // Check if user is part of this conversation
            if ($conversation->sender_id != $userId && $conversation->receiver_id != $userId) {
                return $this->sendErrorResponse('Unauthorized', 403);
            }

            // Determine which read field to update based on user role
            $readField = ($conversation->sender_id == $userId) ? 'read_by_sender_at' : 'read_by_receiver_at';
            
            // Mark all unread messages from the other user as read
            \App\Models\Message::where('conversation_id', $conversationId)
                ->where('user_id', '!=', $userId)
                ->whereNull($readField)
                ->update([$readField => now()]);

            // Also update conversation thread read timestamps for backward compatibility
            if ($conversation->sender_id == $userId) {
                $conversation->sender_last_read_at = now();
            } else {
                $conversation->receiver_last_read_at = now();
            }
            $conversation->save();

            return $this->sendSuccessResponse('Conversation marked as read', $conversation);
        } catch (\Exception $e) {
            return $this->sendErrorResponse('Failed to mark conversation as read: ' . $e->getMessage(), 500);
        }
    }
}

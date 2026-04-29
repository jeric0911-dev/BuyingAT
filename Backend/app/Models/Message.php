<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\ConversationThread;
use App\Models\Product;

class Message extends Model
{
    use HasFactory;

    protected $fillable = [
        'conversation_id', 'user_id', 'message', 'read_by_sender_at', 'read_by_receiver_at',
    ];

    //get user by conversation
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    //conversation
    public function conversation()
    {
        return $this->belongsTo(ConversationThread::class, 'conversation_id', 'id');
    }

    //get property
    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}

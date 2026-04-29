<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ConversationThread extends Model
{
    use HasFactory;

    protected $fillable = [
        'sender_id', 'receiver_id', 'product_id', 'buyer_profile_id', 'conversation_type',
        'sender_last_read_at', 'receiver_last_read_at',
    ];

    //sender
    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    //receiver
    public function receiver()
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }

    //product relationship
    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    //buyer profile relationship
    public function buyerProfile()
    {
        return $this->belongsTo(BuyerProfile::class, 'buyer_profile_id');
    }

    //messages
    public function messages()
    {
        return $this->hasMany(Message::class, 'conversation_id', 'id');
    }
}

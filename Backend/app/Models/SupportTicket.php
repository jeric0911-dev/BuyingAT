<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SupportTicket extends Model
{
    use HasFactory;

    protected $fillable = ['subject', 'priority', 'message', 'status', 'ticket_id', 'user_id'];

    public function attachment ()
    {
        return $this->hasMany(TicketAttachment::class, 'ticket_id', 'id');
    }


    public function messages()
    {
        return $this->hasMany(TicketMessage::class, 'ticket_id', 'id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}

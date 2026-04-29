<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketMessage extends Model
{
    use HasFactory;

    protected $fillable = ['ticket_id', 'user_id', 'message'];

    public function supportTicket()
    {
        return $this->belongsTo(SupportTicket::class, 'ticket_id', 'id');
    }

    public function attachments()
    {
        return $this->hasMany(TicketAttachment::class, 'message_id');
    }

    public function user ()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

}

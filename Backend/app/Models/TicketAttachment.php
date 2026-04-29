<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketAttachment extends Model
{
    use HasFactory;
    public $timestamps = true;

    protected $fillable = ['ticket_id', 'file', 'user_id'];

    public function ticket()
    {
        return $this->belongsTo(SupportTicket::class);
    }

    public function message()
    {
        return $this->belongsTo(TicketMessage::class);
    }
}

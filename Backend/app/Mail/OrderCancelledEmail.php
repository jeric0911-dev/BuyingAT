<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class OrderCancelledEmail extends Mailable
{
    use Queueable, SerializesModels;

    public $user_name;
    public $order_id;

    public function __construct($user_name, $order_id)
    {
        $this->user_name = $user_name;
        $this->order_id = $order_id;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Your Order Has Been Cancelled'
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.order_cancelled',
        );
    }

    public function attachments(): array
    {
        return [];
    }
}

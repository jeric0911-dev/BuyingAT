<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ShopCreationRequestEmail extends Mailable
{
    use Queueable, SerializesModels;

    public $user_name;
    public $shop_name;

    public function __construct($user_name, $shop_name)
    {
        $this->user_name = $user_name;
        $this->shop_name = $shop_name;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Shop Creation Request Received',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.shop_creation_request',
        );
    }

    public function attachments(): array
    {
        return [];
    }
}

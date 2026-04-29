<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MailConfig extends Model
{
    use HasFactory;

    protected $fillable = ['mailer', 'host', 'port', 'username', 'password', 'encryption', 'mail_from_address', 'mail_from_name'];
}

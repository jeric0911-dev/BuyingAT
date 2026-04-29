<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PusherConfig extends Model
{
    use HasFactory;
    
    protected $fillable = ['pusher_app_id', 'pusher_app_key', 'pusher_app_secret', 'pusher_host', 'pusher_port', 'pusher_scheme', 'pusher_app_cluster'];
}

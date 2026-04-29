<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GoogleLoginConfig extends Model
{
    use HasFactory;
    
    protected $fillable = ['google_client_id', 'google_client_secret', 'google_redirect_uri'];
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppSetting extends Model
{
    use HasFactory;
    protected $fillable = [
        'site_title',
        'currency_id',
        'currency_symbol',
        'front_end_base_url',
        'back_end_base_url',
        'web_app_logo',
        'fav_icon',
        'login_page_title',
        'header_title',
        'pixel_id',
        'google_analytics_id',
        'meta_title',
        'meta_description',
        'app_base_url',
        'frontend_url',
    ];
}

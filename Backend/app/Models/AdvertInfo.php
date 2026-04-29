<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdvertInfo extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'product_id',
        'advert_date',
        'advert_start_date',
        'advert_end_date',
        'total_amount',
        'duration',
        'cost_till_now',
        'clicks',
        'calls',
        'messages',
        'favorites',
        'after_ads_clicks',
        'after_ads_calls',
        'after_ads_messages',
        'after_ads_favorites',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'product_id' => 'integer',
        'total_amount' => 'integer',
        'after_ads_clicks' => 'integer',
        'clicks' => 'integer',
        'calls' => 'integer',
        'messages' => 'integer',
        'favorites' => 'integer',
        'after_ads_favorites' => 'integer',
        'after_ads_calls' => 'integer',
        'after_ads_messages' => 'integer',
    ];


    //get user by advert info
    public function propertyUser()
    {
        return $this->hasOne(User::class, 'id','user_id');
    }
}

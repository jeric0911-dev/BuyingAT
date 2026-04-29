<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Feature extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'advert_date',
        'advert_start_date',
        'advert_end_date',
        'total_amount',
        'duration'
    ];
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PromotionTier extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'price',
        'duration_hours',
        'max_views',
        'is_active',
    ];
}



<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FeatureConfig extends Model
{
    use HasFactory;
    protected $fillable = ['normal_user_price', 'premium_user_price'];
}

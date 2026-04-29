<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Gateway extends Model
{
    use HasFactory;

    protected $fillable = ['gateway_name', 'alias', 'gateway_parameters', 'supported_currencies', 'extras', 'description', 'status'];
}

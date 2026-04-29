<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    /** @use HasFactory<\Database\Factories\RatingFactory> */
    use HasFactory;

    protected $guarded = [];

    //get product
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    //user info
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

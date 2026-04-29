<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    use HasFactory;

    protected $fillable = ['car_id', 'title', 'description', 'user_id'];

    public function product ()
    {
        return $this->belongsTo(Product::class, 'car_id', 'id');
    }


    public function user ()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}

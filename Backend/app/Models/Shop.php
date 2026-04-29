<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shop extends Model
{
    /** @use HasFactory<\Database\Factories\ShopFactory> */
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'banner',
        'slug',
        'status'
    ];

    //get products
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    //get user
    public function getUser()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }
}

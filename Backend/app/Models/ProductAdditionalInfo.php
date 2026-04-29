<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductAdditionalInfo extends Model
{
    /** @use HasFactory<\Database\Factories\ProductAdditionalInfoFactory> */
    use HasFactory;

    protected $guarded = [];

    //get product by product info
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}

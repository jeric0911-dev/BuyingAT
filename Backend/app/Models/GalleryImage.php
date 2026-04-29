<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GalleryImage extends Model
{
    use HasFactory;

    protected $fillable = ['product_id', 'img'];

    //get property
    public function property()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}

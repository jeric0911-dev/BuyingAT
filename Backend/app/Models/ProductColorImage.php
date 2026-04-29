<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductColorImage extends Model
{
    /** @use HasFactory<\Database\Factories\ProductColorImageFactory> */
    use HasFactory;

    protected $fillable = ['product_color_id', 'color_image'];

    public function color()
    {
        return $this->belongsTo(Color::class, 'product_color_id');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;
    protected $fillable = ['category_name', 'slug', 'icon', 'banner', 'status'];


    //get sub-categories by category
    public function subCategories()
    {
        return $this->hasMany(SubCategory::class);
    }

    //get clild category
    public function childCategories()
    {
        return $this->hasManyThrough(ChildCategory::class, SubCategory::class);
    }

    //get all active categories
    public function scopeActive($query)
    {
        return $query->select('id', 'category_name', 'slug', 'icon', 'banner')
                     ->where('status', 1);
    }

    //get all products by category
    public function products()
    {
        return $this->hasMany(Product::class);
    }

}

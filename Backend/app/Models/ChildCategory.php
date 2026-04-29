<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChildCategory extends Model
{
    use HasFactory;
    protected $fillable = ['child_category_name', 'sub_category_id','slug', 'icon', 'banner', 'status'];


    //get sub category
    public function subCategory()
    {
        return $this->belongsTo(SubCategory::class);
    }
}

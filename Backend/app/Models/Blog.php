<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Blog extends Model
{
    use HasFactory;

    protected $fillable = [
        'blog_title', 'blog_content', 'blog_category_id',
        'blog_thumb_img', 'cover_img', 'meta_tag', 'meta_description',
        'keyword', 'status', 'slug'
    ];


    protected $casts = [
        'blog_category_id' => 'integer',
    ];

    //get blog category
    public function category()
    {
        return $this->belongsTo(BlogCategory::class, 'blog_category_id');
    }

    //get blog comment
    public function blogComments()
    {
        return $this->hasMany(BlogComment::class);
    }
}

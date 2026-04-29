<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BlogComment extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'blog_id', 'comment'];

    public function getBlog ()
    {
        return $this->belongsTo(Blog::class, 'blog_id');
    }

    public function getUser ()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}

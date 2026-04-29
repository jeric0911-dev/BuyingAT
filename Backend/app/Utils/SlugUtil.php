<?php

namespace App\Utils;

use Illuminate\Support\Str;

class SlugUtil
{
    //generate slug from title
    public static function generateSlug(string $title): string
    {
        $randomSuffix = str_pad(mt_rand(1, 999), 3, '0', STR_PAD_LEFT);
        return Str::slug($title) . '_' . $randomSuffix;
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Package extends Model
{
    use HasFactory;
    public $guarded = [];

    public function packageCategory ()
    {
        return $this->belongsTo(PackageCategory::class);
    }

    public function packageAdvantage ()
    {
        return $this->hasMany(PackageAdvantage::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdminType extends Model
{
    use HasFactory;
    protected $fillable = ['type'];

    public function roleParameters()
    {
        return $this->hasMany(AdminRolePermission::class);
    }
}

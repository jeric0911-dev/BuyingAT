<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdminRolePermission extends Model
{
    use HasFactory;

    protected $fillable = ['admin_type_id', 'name', 'view', 'edit', 'delete'];

    //get admin role
    public function adminType ()
    {
        return $this->belongsTo(AdminType::class, 'admin_type_id');
    }
}

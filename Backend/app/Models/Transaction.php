<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;
    protected $fillable = ['transaction_id', 'user_id', 'initiated', 'payment_method', 'amount', 'status', 'conversion','currency', 'credits'];


    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}

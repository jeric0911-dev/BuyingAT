<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentsInfo extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_provider_id',
        'user_id',
        'product_id',
        'amount',
        'status',
    ];

    protected $casts = [
        'payment_provider_id' => 'integer',
        'user_id' => 'integer',
        'product_id' => 'integer',
        'status' => 'boolean'
    ];

    //get user by payment info
    public function paymentsInfoUser()
    {
        return $this->hasOne(User::class, 'id','user_id');
    }

    public function getProduct()
    {
        return $this->hasOne(Product::class, 'id','product_id');
    }

    //get payment provider
    public function getPaymentProvider()
    {
        return $this->hasOne(PaymentProvider::class, 'id','payment_provider_id');
    }
}

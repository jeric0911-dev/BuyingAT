<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PaymentsInfo;

class PaymentProvider extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'logo', 'status', 'api_key', 'base_url',
    ];

    protected $casts = [
        'status' => 'string',
    ];

    public function paymentInfos(){

        return $this->hasMany(paymentsInfo::class);

    }

}

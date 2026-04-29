<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CardCart extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'card_id',
        'vendor_id',
        'quantity',
        'sku',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function card()
    {
        return $this->belongsTo(SellerInventory::class, 'card_id');
    }

    public function vendor()
    {
        return $this->belongsTo(User::class, 'vendor_id');
    }
}

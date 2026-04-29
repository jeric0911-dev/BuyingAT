<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CardsCart extends Model
{
    protected $table = 'cards_cart';
    
    protected $fillable = [
        'customer_id',
        'card_id',
    ];

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function card()
    {
        return $this->belongsTo(SellerInventory::class, 'card_id');
    }
}

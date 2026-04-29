<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SellerInventory extends Model
{
    protected $table = 'seller_inventory';

    protected $fillable = [
        'user_id',
        'card_title',
        'description',
        'price',
        'price_type',
        'condition',
        'grade',
        'sport_type',
        'images',
        'weight',
        'is_promoted',
        'promotion_expires_at'
    ];

    protected $casts = [
        'images' => 'array',
        'price' => 'decimal:2',
        'weight' => 'decimal:2',
        'is_promoted' => 'boolean',
        'promotion_expires_at' => 'datetime'
    ];

    /**
     * The "booted" method of the model.
     */
    protected static function booted()
    {
        static::created(function ($sellerInventory) {
            // Automatically create a card request when a new inventory item is created
            CardRequest::create([
                'card_id' => $sellerInventory->id,
                'request_status' => 'pending'
            ]);
        });
    }

    /**
     * Get the user that owns the inventory item.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the card requests for this inventory item.
     */
    public function cardRequests(): HasMany
    {
        return $this->hasMany(CardRequest::class, 'card_id');
    }
}

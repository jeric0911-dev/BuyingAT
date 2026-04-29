<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BuyerProfile extends Model
{
    protected $fillable = [
        'user_id',
        'categories',
        'preferences',
        'budget_min',
        'budget_max',
        'is_verified_buyer',
        'profile_link',
        'monthly_spend_required',
        'auto_charge_amount',
        'is_exempt'
    ];

    protected $casts = [
        'categories' => 'array',
        'budget_min' => 'decimal:2',
        'budget_max' => 'decimal:2',
        'is_verified_buyer' => 'boolean',
        'monthly_spend_required' => 'decimal:2',
        'auto_charge_amount' => 'decimal:2',
        'is_exempt' => 'boolean'
    ];

    /**
     * Get the user that owns the buyer profile.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the buyer tags for the buyer profile.
     */
    public function buyerTags(): HasMany
    {
        return $this->hasMany(BuyerTag::class);
    }
}

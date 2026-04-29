<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BuyerTag extends Model
{
    protected $fillable = [
        'buyer_profile_id',
        'tag_name',
        'tag_type',
        'card_condition',
        'purchase_volume',
        'budget_tier'
    ];

    protected $casts = [
        'purchase_volume' => 'integer'
    ];

    /**
     * Get the buyer profile that owns the buyer tag.
     */
    public function buyerProfile(): BelongsTo
    {
        return $this->belongsTo(BuyerProfile::class);
    }
}

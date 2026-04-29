<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CardRequest extends Model
{
    protected $table = 'card_request';
    
    protected $fillable = [
        'card_id',
        'request_status',
    ];

    protected $casts = [
        'request_status' => 'string',
    ];

    /**
     * Get the seller inventory (card) that this request belongs to.
     */
    public function sellerInventory(): BelongsTo
    {
        return $this->belongsTo(SellerInventory::class, 'card_id');
    }

    /**
     * Scope for pending requests.
     */
    public function scopePending($query)
    {
        return $query->where('request_status', 'pending');
    }

    /**
     * Scope for approved requests.
     */
    public function scopeApproved($query)
    {
        return $query->where('request_status', 'approved');
    }

    /**
     * Scope for rejected requests.
     */
    public function scopeRejected($query)
    {
        return $query->where('request_status', 'rejected');
    }

    /**
     * Check if request is pending.
     */
    public function isPending(): bool
    {
        return $this->request_status === 'pending';
    }

    /**
     * Check if request is approved.
     */
    public function isApproved(): bool
    {
        return $this->request_status === 'approved';
    }

    /**
     * Check if request is rejected.
     */
    public function isRejected(): bool
    {
        return $this->request_status === 'rejected';
    }
}

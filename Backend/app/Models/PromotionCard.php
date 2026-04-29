<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PromotionCard extends Model
{
    use HasFactory;

    protected $table = 'promotion_card';

    protected $fillable = [
        'card_id',
        'promotion_price',
        'promotion_duration',
        'promotion_views',
        'promotion_type',
        'max_views',
        'expires_at',
        'is_active',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function scopeActive($query)
    {
        return $query->where('is_active', true)
            ->where(function ($q) {
                $q->where(function ($qq) {
                    $qq->where('promotion_type', 'time')
                       ->where(function ($qqq) {
                           $qqq->whereNull('expires_at')->orWhere('expires_at', '>', now());
                       });
                })->orWhere(function ($qq) {
                    $qq->where('promotion_type', 'impression')
                       ->where(function ($qqq) {
                           $qqq->whereNull('max_views')->orWhereColumn('promotion_views', '<', 'max_views');
                       });
                });
            });
    }
}



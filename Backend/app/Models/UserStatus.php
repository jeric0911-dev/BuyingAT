<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserStatus extends Model
{
    protected $table = 'user_status';
    
    protected $fillable = [
        'user_id',
        'is_online',
        'last_seen',
    ];

    protected $casts = [
        'is_online' => 'boolean',
        'last_seen' => 'datetime',
    ];

    /**
     * Get the user that owns the status.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Mark user as online.
     */
    public static function markOnline(int $userId): void
    {
        self::updateOrCreate(
            ['user_id' => $userId],
            [
                'is_online' => true,
                'last_seen' => now(),
            ]
        );
    }

    /**
     * Mark user as offline.
     */
    public static function markOffline(int $userId): void
    {
        self::updateOrCreate(
            ['user_id' => $userId],
            [
                'is_online' => false,
                'last_seen' => now(),
            ]
        );
    }

    /**
     * Update last seen timestamp.
     */
    public static function updateLastSeen(int $userId): void
    {
        self::updateOrCreate(
            ['user_id' => $userId],
            [
                'last_seen' => now(),
            ]
        );
    }
}

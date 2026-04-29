<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $guarded = [];



    protected $casts = [
        'password' => 'hashed',
        'user_type_id' => 'integer',
        'country_id' => 'integer',
        'city_id' => 'integer',
        'language_id' => 'integer',
        'blacklist' => 'array',
        'violation_count' => 'integer',
        'last_violation_at' => 'datetime',
    ];


    //get user type
    public function userType()
    {
        return $this->belongsTo(UserType::class, 'user_type_id');
    }

    //get country
    public function country()
    {
        return $this->belongsTo(Country::class, 'country_id');
    }

    //get city
    public function city()
    {
        return $this->belongsTo(City::class, 'city_id');
    }

    //get user profile
    public function profile()
    {
        return $this->hasOne(UserProfile::class);
    }

    //get buyer profile
    public function buyerProfile()
    {
        return $this->hasOne(BuyerProfile::class);
    }

    //get seller inventory
    public function sellerInventory()
    {
        return $this->hasMany(SellerInventory::class);
    }

    //get buyer profile requests
    public function buyerProfileRequests()
    {
        return $this->hasMany(BuyerProfileRequest::class);
    }

    //get user roles
    public function userRoles()
    {
        return $this->hasMany(UserRole::class);
    }

    //get state
    public function state()
    {
        return $this->belongsTo(State::class, 'state_id');
    }

    //get language
    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }

    //billing address
    public function getBillingAddress()
    {
        return $this->hasMany(BillingAddress::class, 'user_id');
    }

    //get shipping address
    public function getShippingAddress()
    {
        return $this->hasMany(ShippingAddress::class, 'user_id');
    }
    //get favorited
    public function favorite()
    {
        return $this->belongsToMany(Product::class, 'favorites', 'user_id', 'product_id')
         ->withPivot('id');
    }

    //get favorite property
    public function favoriteProduct()
    {
        return $this->belongsToMany(Product::class, 'favorites', 'user_id', 'product_id');
    }

    //get propert by user
    public function product()
    {
        return $this->hasMany(Product::class,  'user_id');
    }

    //get cart
    public function cartItems()
    {
        return $this->hasMany(Cart::class, 'customer_id');
    }

    //conversation related relationship
    public function conversations()
    {
        return $this->hasMany(ConversationThread::class, 'sender_id', 'id')
            ->orWhere(function ($query) {
                $query->where('receiver_id', $this->id);
            });
    }

    //messages associated with user
    public function messages()
    {
        return $this->hasMany(Message::class, 'user_id');
    }

    //get shop
    public function shop()
    {
        return $this->hasOne(Shop::class, 'user_id', 'id');
    }

    //package
    public function userPackage()
    {
        return $this->hasOne(UserPackage::class);
    }

    //wallet
    public function wallet()
    {
        return $this->hasOne(Wallet::class);
    }

    /**
     * Add violation to user's blacklist
     */
    public function addViolation($violationType, $content = null, $context = 'chat')
    {
        $blacklist = $this->blacklist ?? [];
        
        $violation = [
            'type' => $violationType,
            'content' => $content,
            'context' => $context,
            'timestamp' => now()->toISOString(),
            'ip' => request()->ip(),
            'user_agent' => request()->userAgent()
        ];
        
        $blacklist[] = $violation;
        
        $this->update([
            'blacklist' => $blacklist,
            'violation_count' => $this->violation_count + 1,
            'last_violation_at' => now()
        ]);
        
        return $this;
    }

    /**
     * Get recent violations (last 30 days)
     */
    public function getRecentViolations($days = 30)
    {
        $blacklist = $this->blacklist ?? [];
        $cutoffDate = now()->subDays($days);
        
        return collect($blacklist)->filter(function ($violation) use ($cutoffDate) {
            return \Carbon\Carbon::parse($violation['timestamp'])->isAfter($cutoffDate);
        })->values()->toArray();
    }

    /**
     * Get violation statistics
     */
    public function getViolationStats()
    {
        $blacklist = $this->blacklist ?? [];
        
        $stats = [
            'total_violations' => count($blacklist),
            'violation_count' => $this->violation_count,
            'last_violation' => $this->last_violation_at,
            'violations_by_type' => [],
            'violations_by_context' => [],
            'recent_violations' => $this->getRecentViolations()
        ];
        
        foreach ($blacklist as $violation) {
            $type = $violation['type'];
            $context = $violation['context'];
            
            $stats['violations_by_type'][$type] = ($stats['violations_by_type'][$type] ?? 0) + 1;
            $stats['violations_by_context'][$context] = ($stats['violations_by_context'][$context] ?? 0) + 1;
        }
        
        return $stats;
    }

    /**
     * Check if user has too many violations
     */
    public function hasExcessiveViolations($threshold = 10)
    {
        return $this->violation_count >= $threshold;
    }

    /**
     * Clear blacklist (admin function)
     */
    public function clearBlacklist()
    {
        $this->update([
            'blacklist' => null,
            'violation_count' => 0,
            'last_violation_at' => null
        ]);
        
        return $this;
    }

    /**
     * Referrals made by this user (users they invited).
     */
    public function referrals()
    {
        return $this->hasMany(Referral::class, 'referrer_id');
    }

    /**
     * The referral record indicating who referred this user (if any).
     */
    public function referrer()
    {
        return $this->hasOne(Referral::class, 'referred_user_id');
    }

    /**
     * Affiliate commissions earned by this user as referrer.
     */
    public function affiliateCommissions()
    {
        return $this->hasMany(AffiliateCommission::class, 'referrer_id');
    }

    protected $hidden = [
        'password',
        'remember_token',
    ];
}

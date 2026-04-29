<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_title',
        'category_id',
        'sub_category_id',
        'child_category_id',
        'brand_id',
        'shop_id',
        'user_id',
        'product_description',
        'additional_info',
        'slug_url',
        'stock',
        'sku',
        'price',
        'discounted_price',
        'shipping_class',
        'delivery_time',
        'status',
        'tags',
    ];

    protected $casts = [
        'category_id' => 'integer',
        'sub_category_id' => 'integer',
        'child_category_id' => 'integer',
        'user_id' => 'integer',
        'country_id' => 'integer',
        'city_id' => 'integer',
        'is_favorite' => 'boolean',
        'is_boosting' => 'boolean',
    ];

    // Get category
    public function getCategory()
    {
        return $this->belongsTo(Category::class, 'category_id', 'id');
    }

    // Get sub-category
    public function getSubCategory()
    {
        return $this->belongsTo(SubCategory::class, 'sub_category_id', 'id');
    }

    // Get child-category
    public function getChildCategory()
    {
        return $this->belongsTo(ChildCategory::class, 'child_category_id', 'id');
    }

    // Get brand
    public function getBrand()
    {
        return $this->belongsTo(Brand::class, 'brand_id', 'id');
    }

    // Get listing type
    public function getListingType()
    {
        return $this->belongsTo(ListingType::class, 'listing_type_id', 'id');
    }

    // Get country
    public function getCountry()
    {
        return $this->belongsTo(Country::class, 'country_id', 'id');
    }

    // Get city
    public function getCity()
    {
        return $this->belongsTo(City::class, 'city_id', 'id');
    }

    // Get gallery images
    public function getGalleryImages()
    {
        return $this->hasMany(GalleryImage::class, 'product_id');
    }

    // Get product colors
    public function colors()
    {
        return $this->hasMany(Color::class);
    }

    // Get product sizes
    public function sizes()
    {
        return $this->hasMany(Size::class);
    }

    // Get advert info
    public function getAdvertInfo()
    {
        return $this->hasOne(AdvertInfo::class, 'product_id');
    }

    // Get product user
    public function getProductUser()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    //get shop
    public function shop()
    {
        return $this->belongsTo(Shop::class, 'shop_id');
    }

    // Get favorited by users
    public function favoritedByUsers()
    {
        return $this->belongsToMany(User::class, 'favorites', 'product_id', 'user_id')
            ->withTimestamps();
    }

    // Product additional data
    public function additionalInfo()
    {
        return $this->hasOne(ProductAdditionalInfo::class);
    }

    // Product variants
    public function variants()
    {
        return $this->hasMany(ProductVariant::class);
    }

    // Product reports
    public function reports()
    {
        return $this->hasMany(Report::class, 'car_id');
    }
    
    // Get product ratings
    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }

    // Get active products
    public function scopeActive($query)
    {
        return $query->where('status', 1);
    }

    public function stocks()
    {
        return $this->hasMany(ProductStock::class);
    }

    // Get featured products
    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }
}

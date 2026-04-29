<?php

namespace App\Http\Controllers\customer\homePage;

use App\Http\Controllers\BaseController;
use App\Models\Category;
use App\Models\Product;
use App\Services\ResponseService;
use Illuminate\Http\Request;

class HomepageDataController extends BaseController
{
    //shop with categories
    public function shopWithCategories()
    {
        $categories = Category::active()->get();

        return $this->sendSuccessResponse('Categories retrieved successfully', $categories);
    }

    //best deals
    public function bestDeals()
    {
        $products = Product::active()
            ->whereNotNull('discounted_price')
            ->whereColumn('discounted_price', '<', 'price')
            ->select([
                'id',
                'product_title',
                'category_id',
                'sub_category_id',
                'brand_id',
                'price',
                'discounted_price',
                'slug_url',
                'user_id',
                'stock',
                'status'
            ])
            ->with([
                'getGalleryImages' => function ($query) {
                    $query->select('id', 'product_id', 'img');
                }
            ])
            ->orderByRaw('((price - discounted_price) / price) DESC')
            ->take(10)
            ->get();

        return $this->sendSuccessResponse('Best Deals retrieved successfully', $products);
    }


    //featured product
    public function featuredProducts()
    {
        $products = Product::featured()
            ->active()
            ->select([
                'id',
                'product_title',
                'category_id',
                'sub_category_id',
                'brand_id',
                'user_id',
                'price',
                'discounted_price',
                'slug_url',
                'stock',
                'status'
            ])
            ->with([
                'getGalleryImages' => function ($query) {
                    $query->select('id', 'product_id', 'img');
                },
                'ratings' => function ($query) {
                    $query->select('id', 'product_id', 'rating');
                }
            ])
            ->withAvg('ratings', 'rating')
            ->withCount('ratings')
            ->take(8)
            ->get();

        return $this->sendSuccessResponse('Featured Products retrieved successfully', $products);
    }

    //Electronics accessories
    public function electronicsAccessories()
    {
        $products = Product::active()
        ->select([
            'id',
            'product_title',
            'category_id',
            'sub_category_id',
            'brand_id',
            'user_id',
            'price',
            'discounted_price',
            'slug_url',
            'stock',
            'status'
        ])
        ->whereHas('getCategory', function ($query) {
            $query->where('category_name', 'Electronics');
        })
        ->with([
            'getGalleryImages' => function ($query) {
                $query->select('id', 'product_id', 'img');
            }
        ])
        ->take(8)
        ->get();

        return $this->sendSuccessResponse('Electronics Accessories retrieved successfully', $products);
    }

    //random category products
    public function randomCategoryProducts()
    {
        try {
            // Get all category IDs that have at least one active product
            $categoryIds = Category::whereHas('products', function ($query) {
                $query->active();
            })->pluck('id');

            if ($categoryIds->isEmpty()) {
                return $this->sendErrorResponse('No categories with active products found.', 404);
            }

            // Select one random category
            $randomCategoryId = $categoryIds->random();
            $randomCategory = Category::find($randomCategoryId);

            // Get 10 active products from that category
            $products = Product::active()
                ->where('category_id', $randomCategoryId)
                ->select([
                    'id',
                    'product_title',
                    'category_id',
                    'sub_category_id',
                    'brand_id',
                    'user_id',
                    'price',
                    'discounted_price',
                    'slug_url',
                    'stock',
                    'status'
                ])
                ->with([
                    'getGalleryImages:id,product_id,img',
                    'ratings:id,product_id,rating'
                ])
                ->withAvg('ratings', 'rating')
                ->withCount('ratings')
                ->take(8)
                ->get();

            return $this->sendSuccessResponse("Products from random category: {$randomCategory->category_name}", [
                'category' => [
                    'id' => $randomCategory->id,
                    'title' => $randomCategory->category_name
                ],
                'products' => $products
            ]);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Failed to retrieve random category products.', $th->getMessage(), 500);
        }
    }

    //top Rated
    public function topRated()
    {
        $products = Product::active()
            ->select([
                'id',
                'product_title',
                'category_id',
                'sub_category_id',
                'brand_id',
                'price',
                'discounted_price',
                'slug_url',
                'user_id',
                'stock',
                'status'
            ])
            ->with([
                'getGalleryImages' => function ($query) {
                    $query->select('id', 'product_id', 'img');
                },
                'ratings' => function ($query) {
                    $query->select('id', 'product_id', 'rating');
                }
            ])
            ->withAvg('ratings', 'rating')
            ->orderByDesc('ratings_avg_rating')
            ->take(10)
            ->get();

        return $this->sendSuccessResponse('Top Rated Products retrieved successfully', $products);
    }

    //new Arrivals
    public function newArrivals()
    {
        $products = Product::active()
            ->select([
                'id',
                'product_title',
                'category_id',
                'sub_category_id',
                'brand_id',
                'user_id',
                'price',
                'discounted_price',
                'slug_url',
                'stock',
                'status'
            ])
            ->with([
                'getGalleryImages' => function ($query) {
                    $query->select('id', 'product_id', 'img');
                }
            ])
            ->orderByDesc('created_at')
            ->take(10)
            ->get();

        return $this->sendSuccessResponse('Data retrieved successfully', $products);
    }
}

<?php

namespace App\Services\product;

use Illuminate\Http\Request;

class ProductFilterService {

    public function applyFilters(Request $request, $query)
    {
        $search = $request->query('search');
        $listingTypeId = $request->query('listing_type_id');
        $categoryId = $request->query('category_id');
        $subCategoryId = $request->query('sub_category_id');
        $childCategoryId = $request->query('child_category_id');
        $brandId = $request->query('brand_id');
        $minPrice = $request->query('min_price');
        $maxPrice = $request->query('max_price');
        $sortBy = $request->query('sort_by');
        $sortDirection = $request->query('sort_direction', 'desc');
        $perPage = $request->query('limit') ?? 20;
        $status = $request->query('status', 'Active');
        $isFeatured = $request->query('is_featured');


        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('product_title', 'like', '%' . $search . '%')
                ->orWhere('product_description', 'like', '%' . $search . '%');
            });
        }

        if ($listingTypeId) $query->where('listing_type_id', $listingTypeId);
        if ($categoryId) $query->where('category_id', $categoryId);
        if ($subCategoryId) $query->where('sub_category_id', $subCategoryId);
        if ($childCategoryId) $query->where('child_category_id', $childCategoryId);

        if ($brandId) {
            $brandIdsArray = is_array($brandId) ? $brandId : explode(',', $brandId);
            $query->whereIn('brand_id', array_filter($brandIdsArray));
        }

        if ($minPrice) $query->where('price', '>=', $minPrice);
        if ($maxPrice) $query->where('price', '<=', $maxPrice);
        if ($minPrice && $maxPrice) $query->whereBetween('price', [$minPrice, $maxPrice]);
        if ($isFeatured) $query->where('is_featured', $isFeatured);

        $query->where('status', $status);

        $query->withAvg('ratings', 'rating')->withCount('ratings');

        if ($sortBy === 'price') {
            $query->orderBy('price', $sortDirection);
        } elseif ($sortBy === 'rating') {
            $query->orderBy('ratings_avg_rating', $sortDirection);
        } elseif ($sortBy === 'discount'){
            $query->orderByRaw('((price - discounted_price) / price) DESC');
        }else {
            $query->orderBy('created_at', 'desc');
        }

        $data = $query->select([
            'id',
            'product_title',
            'price',
            'discounted_price',
            'product_description',
            'stock',
            'sku',
            'is_featured',
            'category_id',
            'listing_type_id',
            'brand_id',
            'user_id'
        ])
        ->with([
            'getGalleryImages' => function ($query) {
                $query->select(['id', 'img', 'product_id']);
            }
        ])
        ->withAvg('ratings', 'rating')
        ->withCount('ratings')
        ->paginate($perPage);

        return $data;
    }
}

<?php

namespace App\Http\Controllers\customer\searchAndFilter;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Car;
use App\Services\ResponseService;
use Illuminate\Pagination\LengthAwarePaginator;

class SearchAndFilterController extends BaseController
{
    // General filter
    public function filter(Request $request)
    {
        $results = $this->applyFilters($request, Product::query(), 0);
        return ResponseService::success('Car filtered successfully', $results['data'], $results['pagination']);
    }

    // Featured filter
    public function featuredProductFilter(Request $request)
    {
        $results = $this->applyFilters($request, Car::query(), 1);
        return ResponseService::success('Property filtered successfully', $results['data'], $results['pagination']);
    }

    // Shared logic for filter & featuredCarFilter
    private function applyFilters(Request $request, $query, $isFeatured)
    {
        $listingType = $request->input('listing_type');
        $propertyCategory = $request->input('category');
        $country = $request->input('country');
        $city = $request->input('city');
        $minPrice = $request->input('min_price');
        $maxPrice = $request->input('max_price');
        $sortBy = $request->input('sort_by');
        $sortDirection = $request->input('sort_direction', 'desc');
        $perPage = 20;

        if ($listingType) $query->where('listing_type_id', $listingType);
        if ($propertyCategory) $query->where('category_id', $propertyCategory);
        if ($city) {
            $query->where('city_id', $city);
        } elseif ($country) {
            $query->where('country_id', $country);
        }

        if ($minPrice) $query->where('price', '>=', $minPrice);
        if ($maxPrice) $query->where('price', '<=', $maxPrice);
        if ($minPrice && $maxPrice) $query->whereBetween('price', [$minPrice, $maxPrice]);

        if ($sortBy === 'price') {
            $query->orderBy('price', $sortDirection);
        } elseif ($sortBy === 'created_at') {
            $query->orderBy('created_at', $sortDirection);
        }

        $query->where('is_featured', $isFeatured);
        $query->where('status', 'active');

        $data = $query->with([
            'getCategory',
            'getListingType',
            'getCountry',
            'getCity',
            'getFacility',
            'getOutdoorFacility',
            'getTitleImage',
            'getGalleryImage',
            'get3dImage',
            'getVideoLink',
            'getAdvertInfo',
            'getCarUser'
        ])->get();

        // Manual pagination
        $page = LengthAwarePaginator::resolveCurrentPage();
        $items = collect($data);
        $paginated = new LengthAwarePaginator(
            $items->forPage($page, $perPage),
            $items->count(),
            $perPage,
            $page,
            ['path' => LengthAwarePaginator::resolveCurrentPath()]
        );

        return [
            'data' => $paginated->values()->toArray(),
            'pagination' => [
                'current_page' => $paginated->currentPage(),
                'total_items' => $paginated->total(),
                'per_page' => $paginated->perPage(),
                'total_pages' => $paginated->lastPage(),
                'has_more_pages' => $paginated->hasMorePages(),
                'next_page_url' => $paginated->nextPageUrl(),
                'prev_page_url' => $paginated->previousPageUrl(),
            ]
        ];
    }
}

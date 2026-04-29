<?php

namespace App\Http\Controllers\customer\homepageData;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use App\Models\Category;
use App\Models\City;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Services\ResponseService;

class HomepageDataController extends BaseController
{
    protected function paginate($results, $perPage)
    {
        $page = \Illuminate\Pagination\LengthAwarePaginator::resolveCurrentPage();
        $paginationInfo = collect($results)->slice(($page - 1) * $perPage, $perPage)->all();
        $results = new \Illuminate\Pagination\LengthAwarePaginator(
            $paginationInfo,
            count($results),
            $perPage,
            $page,
            ['path' => \Illuminate\Pagination\LengthAwarePaginator::resolveCurrentPath()]
        );

        return [$results, [
            'current_page' => $results->currentPage(),
            'total_items' => $results->total(),
            'per_page' => $results->perPage(),
            'total_pages' => $results->lastPage(),
            'has_more_pages' => $results->hasMorePages(),
            'next_page_url' => $results->nextPageUrl(),
            'prev_page_url' => $results->previousPageUrl(),
        ]];
    }

    public function featuredListing(Request $request)
    {
        $query = Product::query()->where('is_featured', 1);
        $sortBy = $request->input('sort_by');
        $sortDirection = $request->input('sort_direction', 'desc');

        if ($sortBy === 'price' || $sortBy === 'created_at') {
            $query->orderBy($sortBy, $sortDirection);
        }

        $results = $query->with([
            'getCategory', 'getListingType', 'getCountry', 'getCity',
            'getGalleryImage', 'colors', 'sizes', 'getAdvertInfo', 'getProductUser'
        ])->where('status', 'active')->get();

        [$results, $pagination] = $this->paginate($results, 12);

        return ResponseService::success('Featured Product', $results->values(), ['paginationInfo' => $pagination]);
    }

    public function popularListing(Request $request)
    {
        $sortDirection = $request->input('sort_direction', 'desc');

        $query = Product::query()->orderBy(
            DB::raw('(SELECT clicks FROM advert_infos WHERE product_id = products.id ORDER BY clicks DESC LIMIT 1)'),
            $sortDirection
        );

        $results = $query->with([
            'getCategory', 'getListingType', 'getCountry', 'getCity',
            'getGalleryImage', 'colors', 'sizes', 'getAdvertInfo', 'getProductUser'
        ])->where('status', 'active')->get();

        [$results, $pagination] = $this->paginate($results, 20);

        return ResponseService::success('Popular Property', $results->values(), ['paginationInfo' => $pagination]);
    }

    public function favoriteListing(Request $request)
    {
        $sortDirection = $request->input('sort_direction', 'desc');

        $query = Product::query()->orderBy(
            DB::raw('(SELECT favorites FROM advert_infos WHERE product_id = products.id ORDER BY favorites DESC LIMIT 1)'),
            $sortDirection
        );

        $results = $query->with([
            'getCategory', 'getListingType', 'getCountry', 'getCity',
            'getGalleryImage', 'colors', 'sizes', 'getAdvertInfo', 'getProductUser'
        ])->where('status', 'active')->get();

        [$results, $pagination] = $this->paginate($results, 20);

        return ResponseService::success('Popular Products', $results->values(), ['paginationInfo' => $pagination]);
    }

    public function recentlyAddedListing(Request $request)
    {
        $sortDirection = $request->input('sort_direction', 'desc');

        $results = Product::query()
            ->orderBy('created_at', $sortDirection)
            ->with([
                'getCategory', 'getListingType', 'getCountry', 'getCity',
                'getGalleryImage', 'colors', 'sizes', 'getAdvertInfo', 'getProductUser'
            ])
            ->where('status', 'active')->get();

        [$results, $pagination] = $this->paginate($results, 20);

        return ResponseService::success('Popular Product', $results->values(), ['paginationInfo' => $pagination]);
    }

    public function getAllCategory()
    {
        try {
            $categories = Category::with([
                'products', 'products.getCategory', 'products.getCountry',
                'products.getCity', 'products.getGalleryImage',
                'products.colors', 'products.sizes', 'products.getAdvertInfo', 'products.getProductUser'
            ])->get();

            return ResponseService::success('All categories retrieved successfully', $categories);
        } catch (\Throwable $th) {
            return ResponseService::error($th->getMessage());
        }
    }

    public function getPopularCities()
    {
        try {
            $popularCities = City::withCount('products')->orderByDesc('products_count')->get();

            return ResponseService::success('Popular cities retrieved successfully', $popularCities);
        } catch (\Throwable $th) {
            return ResponseService::error($th->getMessage());
        }
    }

    public function dealers()
    {
        try {
            $dealers = User::whereHas('userType', fn($q) => $q->where('type', 'dealer'))->get();
            [$results, $pagination] = $this->paginate($dealers, 20);

            return ResponseService::success('Popular Product', $results->values(), ['paginationInfo' => $pagination]);
        } catch (\Throwable $th) {
            return ResponseService::error($th->getMessage());
        }
    }

    public function productByDealer($id)
    {
        try {
            $query = Product::query();

            $results = $query->with([
                'getCategory', 'getCountry', 'getCity', 'getGalleryImage',
                'colors', 'sizes', 'getAdvertInfo', 'getProductUser'
            ])->where('user_id', $id)->where('status', 'active')->get();

            [$results, $pagination] = $this->paginate($results, 20);
            $user = User::with('country')->find($id);

            return ResponseService::success('Car by Agent', $results->values(), [
                'paginationInfo' => $pagination,
                'user' => $user
            ]);
        } catch (\Throwable $th) {
            return ResponseService::error($th->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers\customer\category;

use App\Http\Controllers\BaseController;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use App\Models\Category;
use Illuminate\Support\Facades\DB;

class CategoryController extends BaseController
{
    //get all categories
    public function index()
    {
        $categories = Category::select('id', 'category_name', 'slug', 'icon', 'banner')
            ->with([
                'subCategories' => function ($query) {
                    $query->select('id', 'sub_category_name', 'category_id', 'slug', 'icon', 'banner');
                },
                'subCategories.childCategories' => function ($query) {
                    $query->select('id', 'child_category_name', 'sub_category_id', 'slug', 'icon', 'banner');
                }
            ])
            ->get();

        return $this->sendSuccessResponse('Category list retrieved successfully', $categories);
    }

    //get one
    public function show($id)
    {
        $category = Category::select('id', 'category_name', 'slug', 'icon', 'banner')
            ->with([
                'subCategories' => function ($query) {
                    $query->select('id', 'sub_category_name', 'category_id', 'slug', 'icon', 'banner');
                },
                'subCategories.childCategories' => function ($query) {
                    $query->select('id', 'child_category_name', 'sub_category_id', 'slug', 'icon', 'banner');
                }
            ])
            ->where('id', $id)
            ->firstOrFail();

        return $this->sendSuccessResponse('Category retrieved successfully', $category);
    }

    // Get top categories by product count and order count
    public function topCategories()
    {
        $categories = \DB::table('categories')
            ->leftJoin('products', 'products.category_id', '=', 'categories.id')
            ->leftJoin('ordered_items', 'ordered_items.product_id', '=', 'products.id')
            ->select(
                'categories.id',
                'categories.category_name',
                'categories.slug',
                'categories.icon',
                'categories.banner',
                \DB::raw('COUNT(DISTINCT products.id) as product_count'),
                \DB::raw('COUNT(ordered_items.id) as order_count')
            )
            ->groupBy('categories.id', 'categories.category_name', 'categories.slug', 'categories.icon', 'categories.banner')
            ->orderByDesc('order_count')
            ->limit(10)
            ->get();

        return $this->sendSuccessResponse('Top categories retrieved successfully', $categories);
    }

}

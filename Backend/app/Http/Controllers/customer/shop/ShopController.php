<?php

namespace App\Http\Controllers\customer\shop;

use App\Http\Controllers\BaseController;

use App\Models\Shop;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Services\ResponseService;
use Illuminate\Support\Str;
use App\Mail\ShopCreationRequestEmail;
use App\Traits\MailConfigTrait;
use App\Models\User;
use Illuminate\Support\Facades\Mail;

class ShopController extends BaseController
{
    use MailConfigTrait;

    // List all shops for
    public function index()
    {
        $shops = Shop::where('user_id', Auth::id())->get();
        return $this->sendSuccessResponse('Shop Retrived successfully', $shops);
    }

    //get shop by slug
    public function shopBySlug(Request $request, $slug)
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
        $perPage = $request->query('limit') ?? 10;
        $productQuery = Product::query();

        $shop = Shop::where('slug', $slug)
            ->where('status', 'active')
            ->select('id', 'user_id', 'name', 'slug', 'description', 'banner', 'status', 'created_at', 'updated_at')
            ->with([
                'getUser' => function ($q) {
                    $q->select('id', 'name', 'email', 'profile_img', 'secondery_email', 'phone', 'country_id','state_id')
                        ->with([
                            'country:id,country_name',
                            'state:id,state_name',
                        ]);
                }
            ])
            ->first();

        if (!$shop) {
            return $this->sendErrorResponse('Shop not found', [], 404);
        }

        $shopRating = Product::where('shop_id', $shop->id)
            ->join('ratings', 'products.id', '=', 'ratings.product_id')
            ->avg('ratings.rating');

        $shopRatingCount = Product::where('shop_id', $shop->id)
        ->join('ratings', 'products.id', '=', 'ratings.product_id')
        ->count('ratings.rating');

        $shop->average_rating = round($shopRating, 2);
        $shop->rating_count = $shopRatingCount;

        $productQuery = Product::where('shop_id', $shop->id)
            ->select(
                'id',
                'product_title',
                'user_id',
                'category_id',
                'sub_category_id',
                'brand_id',
                'shop_id',
                'price',
                'discounted_price',
                'sku',
                'stock',
                'is_featured',
                'status',
                'created_at',
                'updated_at'
            )
            ->with([
                'getGalleryImages:id,product_id,img'
            ])
            ->withCount('ratings')
            ->withAvg('ratings', 'rating');

        $productQuery->where('status', 1);

        if ($listingTypeId) {
            $productQuery->where('listing_type_id', $listingTypeId);
        }
        if ($categoryId) {
            $productQuery->where('category_id', $categoryId);
        }
        if ($subCategoryId) {
            $productQuery->where('sub_category_id', $subCategoryId);
        }
        if ($childCategoryId) {
            $productQuery->where('child_category_id', $childCategoryId);
        }
        if ($brandId) {
            $brandIdsArray = is_array($brandId) ? $brandId : explode(',', $brandId);
            $productQuery->whereIn('brand_id', array_filter($brandIdsArray));
        }

        if ($minPrice) {
            $productQuery->where('price', '>=', $minPrice);
        }

        if ($maxPrice) {
            $productQuery->where('price', '<=', $maxPrice);
        }
        if ($minPrice && $maxPrice) {
            $productQuery->whereBetween('price', [$minPrice, $maxPrice]);
        }
        if ($search) {
            $productQuery->where(function ($query) use ($search) {
                $query->where('product_title', 'like', '%' . $search . '%')
                    ->orWhere('product_description', 'like', '%' . $search . '%');
            });
        }

        if ($sortBy === 'price') {
            $productQuery->orderBy('price', $sortDirection);
        } elseif ($sortBy === 'rating') {
            $productQuery->orderBy('ratings_avg_rating', $sortDirection);
        } else {
            $productQuery->orderBy('created_at', 'desc');
        }

        $products = $productQuery->paginate($perPage);

        return $this->sendPaginatedResponse2(
            'Shop Retrieved successfully',
            $products,
            200,
            ['shop' => $shop],
            'products'
        );
    }

    //shop products
    public function listShopProducts(Request $request)
    {
        $shopId = $request->query('shop_id');

        if (!$shopId) {
            return $this->sendErrorResponse('shop_id query parameter is required.', [], 400);
        }

        $products = Product::select([
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
            ->where('shop_id', $request->query('shop_id'))
            ->orderBy('created_at', 'desc')
            ->get();

        return $this->sendSuccessResponse('Products retrieved successfully', $products);

    }

    //shop products
    public function listUserProducts(Request $request, $user_id)
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
        $perPage = $request->query('limit') ?? 10;
        $productQuery = Product::query();

        $user = User::select([
            'id',
            'name',
            'email',
            'phone',
            'profile_img',
            'country_id',
            'state_id',
            'created_at',
            ])->with('country:id,country_name')->with('state:id,state_name')->find($user_id);

        $userRating = Product::where('products.user_id', $user_id)
            ->join('ratings', 'products.id', '=', 'ratings.product_id')
            ->avg('ratings.rating');

        $userRatingCount = Product::where('products.user_id', $user_id)
            ->join('ratings', 'products.id', '=', 'ratings.product_id')
            ->count('ratings.rating');


        $user->average_rating = round($userRating, 2);
        $user->rating_count = $userRatingCount;

        $productQuery = Product::where('user_id', $user_id)
        ->select(
            'id',
            'product_title',
            'user_id',
            'category_id',
            'sub_category_id',
            'brand_id',
            'shop_id',
            'price',
            'discounted_price',
            'sku',
            'stock',
            'is_featured',
            'status',
            'created_at',
            'updated_at'
        )
        ->with([
            'getGalleryImages:id,product_id,img'
        ])
        ->withCount('ratings')
        ->withAvg('ratings', 'rating');

       $productQuery->where('status', 1);
       $productQuery->whereNull('shop_id');


        if ($listingTypeId) {
            $productQuery->where('listing_type_id', $listingTypeId);
        }
        if ($categoryId) {
            $productQuery->where('category_id', $categoryId);
        }
        if ($subCategoryId) {
            $productQuery->where('sub_category_id', $subCategoryId);
        }
        if ($childCategoryId) {
            $productQuery->where('child_category_id', $childCategoryId);
        }
        if ($brandId) {
            $brandIdsArray = is_array($brandId) ? $brandId : explode(',', $brandId);
            $productQuery->whereIn('brand_id', array_filter($brandIdsArray));
        }

        if ($minPrice) {
            $productQuery->where('price', '>=', $minPrice);
        }

        if ($maxPrice) {
            $productQuery->where('price', '<=', $maxPrice);
        }
        if ($minPrice && $maxPrice) {
            $productQuery->whereBetween('price', [$minPrice, $maxPrice]);
        }
        if ($search) {
            $productQuery->where(function ($query) use ($search) {
                $query->where('product_title', 'like', '%' . $search . '%')
                    ->orWhere('product_description', 'like', '%' . $search . '%');
            });
        }

        if ($sortBy === 'price') {
            $productQuery->orderBy('price', $sortDirection);
        } elseif ($sortBy === 'rating') {
            $productQuery->orderBy('ratings_avg_rating', $sortDirection);
        } else {
            $productQuery->orderBy('created_at', 'desc');
        }

        $products = $productQuery->paginate($perPage);

        return $this->sendPaginatedResponse2(
            'Shop Retrieved successfully',
            $products,
            200,
            ['user' => $user],
            'products'
        );
    }


    //create shop
    public function store(Request $request)
    {
        $existingShop = Shop::where('user_id', Auth::id())->first();
        if ($existingShop) {
            return $this->sendErrorResponse('You already have a shop.', [], 409);
        }

        //send mail to user
        $user = User::find(auth()->id());

        if (!$user) {
            return $this->sendErrorResponse('User not found', 404);
        }

        $mailData = $this->getMailConfig();

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'banner' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $bannerPath = $request->file('banner')->store('banners', 'public');

        $slug = Str::slug($data['name']);
        $originalSlug = $slug;
        $counter = 1;

        while (Shop::where('slug', $slug)->exists()) {
            $slug = $originalSlug . '-' . $counter++;
        }

        $shop = Shop::create([
            'user_id' => Auth::id(),
            'name' => $data['name'],
            'description' => $data['description'],
            'banner' => $bannerPath,
            'slug' => $slug,
        ]);

        Mail::to($user->email)
            ->send((new ShopCreationRequestEmail($user->name, $shop->name))
                ->from($mailData['from_email'], $mailData['from_name'])
            );

        return $this->sendSuccessResponse('Shop created successfully and Waiting for Confirmation', $shop, 201);
    }

    // Show single shop
    public function show($id)
    {
        $shop = Shop::where('user_id', Auth::id())->findOrFail($id);
        return $this->sendSuccessResponse('Shop retrived successfully', $shop);
    }

    // Update a shop
    public function update(Request $request)
    {
        $shop = Shop::where('user_id', Auth::id())->first();

        if (!$shop) {
            return $this->sendErrorResponse('Shop not found.', [], 404);
        }

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'banner' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        if ($data['name'] !== $shop->name) {
            $slug = Str::slug($data['name']);
            $originalSlug = $slug;
            $counter = 1;

            while (Shop::where('slug', $slug)->where('id', '!=', $shop->id)->exists()) {
                $slug = $originalSlug . '-' . $counter++;
            }

            $shop->slug = $slug;
        }

        if ($request->hasFile('banner')) {

            if ($shop->banner && \Storage::disk('public')->exists($shop->banner)) {
                \Storage::disk('public')->delete($shop->banner);
            }

            $shop->banner = $request->file('banner')->store('banners', 'public');
        }

        $shop->name = $data['name'];
        $shop->description = $data['description'];
        $shop->save();

        return $this->sendSuccessResponse('Shop updated successfully', $shop);
    }


    // Delete a shop
    public function destroy($id)
    {
        $shop = Shop::where('user_id', Auth::id())->findOrFail($id);

        if ($shop->banner && Storage::disk('public')->exists($shop->banner)) {
            Storage::disk('public')->delete($shop->banner);
        }

        $shop->delete();

        return $this->sendSuccessResponse('Shop deleted successfully');
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //vendor routes
    //Shop by vendor
    public function shopByVendor()
    {
        if ( auth()->user()->user_type !== 'vendor') {
            return $this->sendErrorResponse('You are not a vendor', [], 403);
        }

        $shop = Shop::where('user_id', Auth::id())->with([
                'getUser' => function ($query) {
                    $query->select(['id', 'name', 'email', 'profile_img', 'secondery_email', 'phone', 'country_id', 'state_id'])
                        ->with([
                            'country:id,country_name',
                            'state:id,state_name'
                        ]);
                }
            ])->first();

        $shopRating = Product::where('shop_id', $shop->id)
            ->join('ratings', 'products.id', '=', 'ratings.product_id')
            ->avg('ratings.rating');

        $shopRatingCount = Product::where('shop_id', $shop->id)
        ->join('ratings', 'products.id', '=', 'ratings.product_id')
        ->count('ratings.rating');

        $shop->average_rating = $shopRating;
        $shop->rating_count = $shopRatingCount;
        return $this->sendSuccessResponse('Shop Retrieved successfully', $shop);
    }

    //get shop or user product
    public function shopProducts(Request $request)
    {
        $search = $request->query('search');
        $status = $request->query('status', 'active');
        $sortBy = $request->query('sort_by');
        $sortDirection = $request->query('sort_direction', 'desc');
        $perPage = $request->query('limit', 10);

        $shop = Shop::where('user_id', Auth::id())->first();

        $productQuery = Product::query();

        if ($shop) {
            $productQuery->where('shop_id', $shop->id);
        } else {
            $productQuery->where('user_id', Auth::id());
        }

        $productQuery->select(
            'id',
            'product_title',
            'user_id',
            'category_id',
            'sub_category_id',
            'brand_id',
            'shop_id',
            'price',
            'discounted_price',
            'sku',
            'stock',
            'is_featured',
            'status',
            'created_at',
            'updated_at'
        )
        ->with([
            'getGalleryImages:id,product_id,img',
            'colors' => function ($query) {
                $query->select(['id', 'color', 'color_name', 'stock', 'product_id']);
                $query->with(['images' => function ($subQuery) {
                    $subQuery->select(['id', 'color_image', 'product_color_id']);
                }]);
            },
            'sizes' => function ($query) {
                $query->select(['id', 'size', 'stock', 'product_id']);
            },
            'variants' => function ($query) {
                $query->select(['id', 'variant_name', 'price', 'discounted_price', 'stock', 'product_id']);
            },
            'stocks'
        ])
        ->withCount('ratings')
        ->withAvg('ratings', 'rating')
        ->where('status', $status );

        if ($search) {
            $productQuery->where(function ($query) use ($search) {
                $query->where('product_title', 'like', "%{$search}%")
                    ->orWhere('product_description', 'like', "%{$search}%");
            });
        }

        if ($sortBy === 'price') {
            $productQuery->orderBy('price', $sortDirection);
        } elseif ($sortBy === 'rating') {
            $productQuery->orderBy('ratings_avg_rating', $sortDirection);
        } else {
            $productQuery->orderBy('created_at', 'desc');
        }

        $products = $productQuery->paginate($perPage);

        return $this->sendPaginatedResponse('Products retrieved successfully', $products, 200);
    }

    //get all shops slugs
    public function getShopSlugs()
    {
        $slugs = Shop::where('status', 'active')->pluck('slug');
        return $this->sendSuccessResponse('Shop slugs retrieved successfully', $slugs);
    }

}

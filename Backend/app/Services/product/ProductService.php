<?php

namespace App\Services\product;

use App\Models\Product;
use App\Models\AdvertInfo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use App\Utils\SkuGeneratorUtil;

class ProductService
{
    //get all products
    public function getAllProducts()
    {
        return Product::select([
            'id',
            'product_title',
            'price',
            'discounted_price',
            'product_description',
            'stock',
            'sku',
            'is_featured',
        ])->with([
            'getGalleryImages' => function ($query) {
                $query->select(['img', 'product_id']);
            },
        ])->orderBy('created_at', 'desc')->get();
    }

    //get single product
    public function getProductById($id)
    {
        return Product::select([
            'id',
            'product_title',
            'price',
            'discounted_price',
            'product_description',
            'stock',
            'sku',
            'is_featured',
            'status',
            'category_id',
            'sub_category_id',
            'brand_id',
            'user_id',
            'shop_id'
        ])->with([
            'getGalleryImages' => function ($query) {
                $query->select(['img', 'product_id']);
            },
            'getCategory' => function ($query) {
                $query->select(['id', 'category_name']);
            },
            'getSubCategory' => function ($query) {
                $query->select(['id', 'sub_category_name']);
            },
            'getBrand' => function ($query) {
                $query->select(['id', 'brand_name']);
            },
            'colors' => function ($query) {
                $query->select(['id', 'color', 'color_name', 'stock', 'product_id']);
                $query->with(['images' => function ($subQuery) {
                    $subQuery->select(['id', 'color_image', 'product_color_id']);
                }]);
            },
            'sizes' => function ($query) {
                $query->select(['id', 'size', 'stock', 'product_id']);
            },
            'additionalInfo' => function ($query) {
                $query->select(['id', 'description', 'additional_info', 'specification', 'product_id']);
            },
            'variants' => function ($query) {
                $query->select(['id', 'variant_name', 'price', 'discounted_price', 'stock', 'product_id']);
            },
            'getAdvertInfo' => function ($query) {
                $query->select(['id', 'product_id']);
            },
            'ratings' => function ($query) {
                $query->select(['id', 'rating', 'message', 'product_id', 'user_id', 'created_at']);
                $query->with(['user' => function ($subQuery) {
                    $subQuery->select(['id', 'name', 'profile_img']);
                }]);
            },
            'stocks',
            'getProductUser' => function ($query) {
                $query->select(['id', 'name', 'profile_img', 'user_type' ]);
            },
            'shop' => function ($query) {
                $query->select('id', 'name', 'slug');
            }
        ])
        ->withAvg('ratings', 'rating')
        ->withCount('ratings')
        ->findOrFail($id);
    }

    //create product
    public function createProduct(Request $request)
    {
        DB::beginTransaction();

        try {
            $data = $this->validateRequest($request);
            $data['user_id'] = auth()->user()->id;

            $shop = auth()->user()->shop;
            $data['shop_id'] = $shop ? $shop->id : null;
            $data['additional_info'] = $request->input('additional_info', 'no additional info');

            $colors = is_string($data['colors']) ? json_decode($data['colors'], true) : ($data['colors'] ?? []);
            $sizes = is_string($data['sizes']) ? json_decode($data['sizes'], true) : ($data['sizes'] ?? []);
            $variants = is_string($data['variations']) ? json_decode($data['variations'], true) : ($data['variations'] ?? []);

            $hasColors = !empty($colors);
            $hasSizes = !empty($sizes);
            $hasVariants = !empty($variants);

            $product = Product::create($data);
            $sku = SkuGeneratorUtil::generate($product->id);

            if (!$hasColors && !$hasSizes && !$hasVariants) {
                $product->sku = $sku;
                logger("Saving SKU: $sku to product ID: " . $product->id);
                Log::info('Saving SKU', ['sku' => $sku, 'product_id' => $product->id]);
                $product->save();
            }

            // Additional Info
            if (!empty($data['additional_info_description']) || !empty($data['additional_info_json']) || !empty($data['specification'])) {
                $product->additionalInfo()->create([
                    'description' => $data['additional_info_description'] ?? '',
                    'additional_info' => json_encode($data['additional_info_json'] ?? []),
                    'specification' => json_encode($data['specification'] ?? [])
                ]);
            }

            // Gallery Images
            if ($request->hasFile('img')) {
                foreach ($request->file('img') as $image) {
                    $path = $image->store('gallery_images', 'public');
                    $product->getGalleryImages()->create(['img' => $path]);
                }
            }

            // COLORS + color images
            if (!empty($colors)) {
                foreach ($colors as $index => $colorData) {
                    if (empty($colorData['color']) && empty($colorData['color_name']) && empty($colorData['stock'])) {
                        continue;
                    }

                    $color = $product->colors()->create([
                        'color_name' => $colorData['color_name'] ?? 'Unnamed Color',
                        'color' => $colorData['color'] ?? 'No code given',
                        'stock' => isset($colorData['stock']) ? (int) $colorData['stock'] : 0,
                    ]);

                    $imageKey = "colors{$index}";
                    if ($request->hasFile($imageKey)) {
                        foreach ($request->file($imageKey) as $image) {
                            $path = $image->store('color_images', 'public');
                            $color->images()->create(['color_image' => $path]);
                        }
                    }
                }
            }

            // SIZES
            if (!empty($sizes)) {
                foreach ($sizes as $sizeData) {
                    if (!empty($sizeData['size']) || !empty($sizeData['stock'])) {
                        $product->sizes()->create([
                            'size' => $sizeData['size'],
                            'stock' => isset($sizeData['stock']) ? (int) $sizeData['stock'] : 0,
                        ]);
                    }
                }
            }

            // VARIANTS
            if (!empty($variants)) {
                foreach ($variants as $variant) {
                    if (!empty($variant['variant_name']) || !empty($variant['price'])) {
                        $product->variants()->create([
                            'variant_name' => $variant['variant_name'],
                            'price' => $variant['price'],
                            'discounted_price' => $variant['discounted_price'] ?? null,
                            'stock' => isset($variant['stock']) ? (int) $variant['stock'] : 0,
                        ]);
                    }
                }
            }

            // Advert Info
            $advertInfo = $product->getAdvertInfo()->create([
                'user_id' => $request->user()->id,
            ]);

            DB::commit();

            return [
                'product' => $product,
                'advert_info' => $advertInfo,
            ];

        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }
    }


    //update product
    public function updateProduct(Request $request, $id)
    {
        DB::beginTransaction();

        try {

            $data = $this->validateRequestUpdate($request);

            $product = Product::findOrFail($id);

            $data['additional_info'] = $request->input('additional_info', 'no additional info');

            $product->update($data);

            // Update or create additional info
            $product->additionalInfo()->updateOrCreate(
                ['product_id' => $product->id],
                [
                    'description' => $request->input('additional_info_description', ''),
                    'additional_info' => json_encode($request->input('additional_info_json', [])),
                    'specification' => json_encode($request->input('specification', [])),
                ]
            );

            if ($request->hasFile('img')) {
                foreach ($product->getGalleryImages as $galleryImage) {
                    Storage::disk('public')->delete($galleryImage->img);
                }
                $product->getGalleryImages()->delete();

                foreach ($request->file('img') as $image) {
                    $path = $image->store('gallery_images', 'public');
                    $product->getGalleryImages()->create(['img' => $path]);
                }
            }

            // COLORS
            $colors = $data['colors'] ?? null;
            if (!empty($colors)) {

                if (is_string($colors)) {
                    $colors = json_decode($colors, true);
                }

                if (is_array($colors)) {
                    $colors = array_filter($colors, function ($colorData) {
                        return !empty($colorData['color']) || !empty($colorData['color_name']) || !empty($colorData['stock']);
                    });

                    if (count($colors) > 0) {
                        $product->colors()->each(function ($color) {
                            foreach ($color->images as $img) {
                                Storage::disk('public')->delete($img->color_image);
                            }
                            $color->images()->delete();
                            $color->delete();
                        });

                        foreach ($colors as $index => $colorData) {
                            $color = $product->colors()->create([
                                'color_name' => $colorData['color_name'] ?? 'Unnamed Color',
                                'color' => $colorData['color'] ?? 'No code given',
                                'stock' => isset($colorData['stock']) ? (int) $colorData['stock'] : 0,
                            ]);

                            $imageKey = "colors{$index}";
                            if ($request->hasFile($imageKey)) {
                                foreach ($request->file($imageKey) as $colorImage) {
                                    $path = $colorImage->store('color_images', 'public');
                                    $color->images()->create(['color_image' => $path]);
                                }
                            }
                        }
                    }
                }
            }

            // SIZES
            $sizes = $data['sizes'] ?? null;
            if (!empty($sizes)) {
                if (is_string($sizes)) {
                    $sizes = json_decode($sizes, true);
                }

                if (is_array($sizes)) {
                    $sizes = array_filter($sizes, function ($sizeData) {
                        return !empty($sizeData['size']) || !empty($sizeData['stock']);
                    });

                    if (count($sizes) > 0) {
                        $product->sizes()->delete();

                        foreach ($sizes as $sizeData) {
                            $product->sizes()->create([
                                'size' => $sizeData['size'],
                                'stock' => isset($sizeData['stock']) ? (int) $sizeData['stock'] : 0,
                            ]);
                        }
                    }
                }
            }

            // VARIANTS
            $variants = $data['variations'] ?? null;
            if (!empty($variants)) {
                if (is_string($variants)) {
                    $variants = json_decode($variants, true);
                }

                if (is_array($variants)) {
                    $variants = array_filter($variants, function ($variant) {
                        return !empty($variant['variant_name']) || !empty($variant['price']);
                    });

                    if (count($variants) > 0) {
                        $product->variants()->delete();

                        foreach ($variants as $variant) {
                            $product->variants()->create([
                                'variant_name' => $variant['variant_name'],
                                'price' => $variant['price'],
                                'discounted_price' => $variant['discounted_price'] ?? null,
                                'stock' => isset($variant['stock']) ? (int) $variant['stock'] : 0,
                            ]);
                        }
                    }
                }
            }

            // Update or create advert info
            $advertInfo = AdvertInfo::updateOrCreate(
                ['user_id' => $product->user_id],
                ['product_id' => $product->id]
            );

            DB::commit();

            return [
                'product' => $product->fresh(),
                'advert_info' => $advertInfo,
            ];
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }
    }

    //delete product
    public function deleteProduct($id)
    {
        DB::beginTransaction();

        try {
            $product = Product::findOrFail($id);

            foreach ($product->getGalleryImages as $galleryImage) {
                Storage::disk('public')->delete($galleryImage->img);
            }
            $product->getGalleryImages()->delete();

            foreach ($product->colors as $color) {
                foreach ($color->images as $image) {
                    Storage::disk('public')->delete($image->color_image);
                }
                $color->images()->delete();
                $color->delete();
            }

            $product->sizes()->delete();

            $product->variants()->delete();

            $product->additionalInfo()->delete();

            $product->getAdvertInfo()->delete();

            $product->delete();

            DB::commit();

            return response()->json(['message' => 'Product deleted successfully.'], 200);

        } catch (\Throwable $th) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to delete product.'], 500);
        }
    }


    //unpublish product
    public function unpublishProduct($product)
    {
        $getProduct = $product->update(['status' => 'Unpublished']);
        return $product;
    }

    //validate request
    private function validateRequest(Request $request)
    {
        return $request->validate([
            'product_title' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'sub_category_id' => 'nullable|exists:sub_categories,id',
            'child_category_id' => 'exists:child_categories,id',
            'brand_id' => 'exists:brands,id',
            'product_description' => 'required|string',
            'additional_info' => 'nullable|string',
            'slug_url' => 'string',
            'stock' => 'string',
            'sku' => 'string',
            'price' => 'numeric',
            'discounted_price' => 'nullable|numeric',
            'shipping_time' => 'nullable|string',
            'delivery_class' => 'nullable|string',
            'status' => 'nullable|string',
            'tags' => 'string',
            'is_favorite' => 'string',
            'is_featured' => 'string',
            'img' => 'required',
            'img.*' => 'image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'colors' => 'string',
            'colors.*' => 'string',
            'sizes' => 'string',
            'sizes.*' => 'string',
            'variations' => 'string',
            'additional_info_description' => 'string',
            'additional_info_json' => 'string',
            'specification' => 'string'
        ]);
    }

    //validate request
    private function validateRequestUpdate(Request $request)
    {
        return $request->validate([
            'product_title' => 'nullable|string',
            'category_id' => 'nullable|exists:categories,id',
            'sub_category_id' => 'nullable|exists:sub_categories,id',
            'child_category_id' => 'exists:child_categories,id',
            'brand_id' => 'exists:brands,id',
            'product_description' => 'nullable|string',
            'additional_info' => 'nullable|string',
            'slug_url' => 'string',
            'stock' => 'string',
            'sku' => 'string',
            'price' => 'numeric',
            'discounted_price' => 'nullable|numeric',
            'shipping_time' => 'nullable|string',
            'delivery_class' => 'nullable|string',
            'status' => 'nullable|string',
            'tags' => 'string',
            'is_favorite' => 'string',
            'is_featured' => 'string',
            'img' => 'required',
            'img.*' => 'image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'colors' => 'string',
            'colors.*' => 'string',
            'sizes' => 'string',
            'sizes.*' => 'string',
            'variations' => 'string',
            'additional_info_description' => 'string',
            'additional_info_json' => 'string',
            'specification' => 'string'
        ]);
    }

    //manage stock
    public function manageStock(Request $request, $product)
    {
        $data = $request->validate([
            'stock' => 'required|integer|min:0'
        ]);

        $product->update(['stock' => $data['stock']]);

        return $product;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //methods related to admin panel
    public function getAllProductsAdmin($limit = 15, $status = 'Active')
    {
        $product = Product::query();
        if ($status) {
            $product->where('status', $status);
        }
        return $product->select([
            'id',
            'product_title',
            'price',
            'discounted_price',
            'product_description',
            'stock',
            'sku',
            'is_featured',
            'status',
            'category_id',
            'sub_category_id',
            'brand_id',
            'user_id'
        ])->with([
            'getGalleryImages' => function ($query) {
                $query->select(['img', 'product_id']);
            },
            'getCategory' => function ($query) {
                $query->select(['id', 'category_name']);
            },
            'getSubCategory' => function ($query) {
                $query->select(['id', 'sub_category_name']);
            },
            'getBrand' => function ($query) {
                $query->select(['id', 'brand_name']);
            },
            'colors' => function ($query) {
                $query->select(['id', 'color', 'color_name', 'stock', 'product_id']);
                $query->with(['images' => function ($subQuery) {
                    $subQuery->select(['id', 'color_image', 'product_color_id']);
                }]);
            },
            'sizes' => function ($query) {
                $query->select(['id', 'size', 'stock', 'product_id']);
            },
            'additionalInfo' => function ($query) {
                $query->select(['id', 'description', 'additional_info', 'specification', 'product_id']);
            },
            'variants' => function ($query) {
                $query->select(['id', 'variant_name', 'price', 'discounted_price', 'stock', 'product_id']);
            },
            'getAdvertInfo' => function ($query) {
                $query->select(['id', 'product_id']);
            },
            'getProductUser' => function ($query) {
                $query->select(['id', 'name', 'profile_img', 'user_type' ]);
            }
        ])->orderBy('created_at', 'desc')->paginate($limit);
    }

    //approve or reject product
    public function approveOrRejectProduct($product, $status)
    {
        $getProduct = $product->update(['status' => $status]);
        return $product;
    }
}

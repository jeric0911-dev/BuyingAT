<?php

namespace App\Http\Controllers\customer\productStock;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use App\Models\ProductStock;
use App\Models\Product;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Log;
use App\Utils\SkuGeneratorUtil;

class ProductStockController extends BaseController
{
    //get all product stocks
    public function getAllProductStocks(Request $request)
    {
        try {
            $limit = $request->query('limit', 10);
            $productStocks = ProductStock::with(['product', 'variant', 'color', 'size'])
                ->paginate($limit);
            return $this->sendPaginatedResponse('Product stocks retrieved successfully', $productStocks);
        } catch (\Exception $e) {
            return $this->sendErrorResponse($e->getMessage(), 500);
        }
    }

    //get single product stock
    public function getSingleProductStock($id)
    {
        try {
            $productStock = ProductStock::with(['product', 'variant', 'color', 'size'])
                ->findOrFail($id);
            return $this->sendSuccessResponse($productStock, 200);
        } catch (\Exception $e) {
            return $this->sendErrorResponse('Product stock not found', 404);
        }
    }

    //create product stock
    public function createProductStock(Request $request)
    {
        $data = $request->validate([
            'product_id' => 'required|exists:products,id',
            'variant_id' => 'nullable|exists:product_variants,id',
            'color_id' => 'nullable|exists:colors,id',
            'size_id' => 'nullable|exists:sizes,id',
            'stock' => 'required|integer|min:0'
        ]);

        $product = Product::where('id', $data['product_id'])
                        ->where('user_id', auth()->id())
                        ->first();

        if (!$product) {
            return $this->sendError('You are not authorized to add stock for this product.', [], 403);
        }

        $exists = ProductStock::where('product_id', $data['product_id'])
            ->where('variant_id', $data['variant_id'])
            ->where('color_id', $data['color_id'])
            ->where('size_id', $data['size_id'])
            ->exists();

        if ($exists) {
            return $this->sendErrorResponse('This stock combination already exists.', [], 422);
        }

        $data['sku'] = SkuGeneratorUtil::generate(
            $data['product_id'],
            $data['variant_id'] ?? null,
            $data['color_id'] ?? null,
            $data['size_id'] ?? null
        );

        $productStock = ProductStock::create($data);

        return $this->sendSuccessResponse($productStock, 201);
    }


    public function createOrUpdateMultipleProductStocks(Request $request)
    {
        try {
            $data = $request->validate([
                'stocks' => 'required|array|min:1',
                'stocks.*.product_id' => 'required|exists:products,id',
                'stocks.*.variant_id' => 'nullable|exists:product_variants,id',
                'stocks.*.color_id' => 'nullable|exists:colors,id',
                'stocks.*.size_id' => 'nullable|exists:sizes,id',
                'stocks.*.stock' => 'required|integer|min:0',
            ]);

            $results = [];

            foreach ($data['stocks'] as $item) {
                $product = Product::find($item['product_id']);
                if (!$product || $product->user_id !== auth()->id()) {
                    continue;
                }

                $stock = ProductStock::where('product_id', $item['product_id'])
                    ->where('variant_id', $item['variant_id'] ?? null)
                    ->where('color_id', $item['color_id'] ?? null)
                    ->where('size_id', $item['size_id'] ?? null)
                    ->first();

                if ($stock) {
                    // Update existing stock
                    $stock->update(['stock' => $item['stock']]);
                    $results[] = $stock;
                } else {
                    // Create new stock with SKU
                    $item['sku'] = SkuGeneratorUtil::generate(
                        $item['product_id'],
                        $item['variant_id'] ?? null,
                        $item['color_id'] ?? null,
                        $item['size_id'] ?? null
                    );

                    $results[] = ProductStock::create($item);
                }
            }

            return $this->sendSuccessResponse(count($results) . ' stock(s) processed successfully', $results, 201);
        } catch (\Throwable $th) {
            Log::error('Failed to create or update product stocks: ' . $th->getMessage());
            return $this->sendErrorResponse('Failed to create or update product stocks', $th->getMessage(), 500);
        }
    }

    //update product stock
    public function updateProductStock(Request $request, $id)
    {
        $productStock = ProductStock::findOrFail($id);

        if ($productStock->product->user_id !== auth()->id()) {
            return $this->sendError('You are not authorized to update stock for this product.', [], 403);
        }

        $data = $request->validate([
            'product_id' => 'sometimes|required|exists:products,id',
            'variant_id' => 'nullable|exists:product_variants,id',
            'color_id' => 'nullable|exists:colors,id',
            'size_id' => 'nullable|exists:sizes,id',
            'stock' => 'sometimes|required|integer|min:0'
        ]);

        $productStock->update($data);

        return $this->sendSuccessResponse($productStock, 200);
    }

    //update multiple product stocks
    public function updateMultipleProductStocks(Request $request)
    {
        $data = $request->validate([
            'stocks' => 'required|array|min:1',
            'stocks.*.product_id' => 'required|exists:products,id',
            'stocks.*.variant_id' => 'nullable|exists:product_variants,id',
            'stocks.*.color_id' => 'nullable|exists:colors,id',
            'stocks.*.size_id' => 'nullable|exists:sizes,id',
            'stocks.*.stock' => 'required|integer|min:0',
        ]);

        $updatedStocks = [];

        foreach ($data['stocks'] as $item) {
            $product = Product::find($item['product_id']);
            if (!$product || $product->user_id !== auth()->id()) {
                continue;
            }

            $stock = ProductStock::where('product_id', $item['product_id'])
                ->where('variant_id', $item['variant_id'] ?? null)
                ->where('color_id', $item['color_id'] ?? null)
                ->where('size_id', $item['size_id'] ?? null)
                ->first();

            if ($stock) {
                $stock->update(['stock' => $item['stock']]);
                $updatedStocks[] = $stock;
            }
        }

        return $this->sendSuccessResponse($updatedStocks, count($updatedStocks) . ' stock(s) updated successfully', 200);
    }

    //delete product stock
    public function deleteProductStock($id)
    {
        $productStock = ProductStock::findOrFail($id);

        if ($productStock->product->user_id !== auth()->id()) {
            return $this->sendErrorResponse('You are not authorized to delete stock for this product.', [], 403);
        }

        $productStock->delete();

        return $this->sendSuccessResponse(null, 204);
    }
}

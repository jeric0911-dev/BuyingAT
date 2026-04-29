<?php

namespace App\Http\Controllers\Customer\Product;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use Illuminate\Http\Request;
use App\Services\product\ProductService;
use App\Services\product\ProductFilterService;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\ModelNotFoundException;

use function PHPUnit\Framework\isEmpty;

class ProductController extends BaseController
{
    protected $productService;
    protected $productFilterService;

    public function __construct(ProductService $productService, ProductFilterService $productFilterService)
    {
        $this->productService = $productService;
        $this->productFilterService = $productFilterService;
    }

    // Get all products
    public function index()
    {
        $products = $this->productService->getAllProducts();

        if ($products->isEmpty()) {
            return $this->sendErrorResponse('No products found', [], 404);
        }

        return $this->sendSuccessResponse('Product list retrieved successfully', $products);
    }

    // Get single product
    public function show($id)
    {
        $product = $this->productService->getProductById($id);

        return $this->sendSuccessResponse('Product retrieved successfully', $product);
    }

    // Store product
    public function store(Request $request)
    {
        $productData = $this->productService->createProduct($request);
        return $this->sendSuccessResponse('Product created', $productData, 201);
    }

    // Update product
    public function update(Request $request, $id)
    {
        $updatedProduct = $this->productService->updateProduct($request, $id);
        return $this->sendSuccessResponse('Updated successfully', $updatedProduct, 200);
    }

    //data filter
    public function filter(Request $request)
    {
        $updatedProduct = $this->productFilterService->applyFilters($request, Product::query());

        return $this->sendPaginatedResponse(
            'Filtered products retrieved successfully',
            $updatedProduct,
            200
        );
    }

    // unpublish product
    public function unpublish(Request $request)
    {
        $getProduct = $this->productService->getProductById($request->product_id);

        if ( !$getProduct ) {
            return $this->sendErrorResponse('Product not found...');
        }

        if (auth()->user()->id !== $getProduct->getProductUser->id) {
            return $this->sendErrorResponse('this product does not belong to you');
        }

        $product = $this->productService->unpublishProduct($getProduct);
        return $this->sendSuccessResponse('Unpublished successfully', $product);
    }

    //manage stock
    public function stockManagement(Request $request)
    {
        $getProduct = $this->productService->getProductById($request->product_id);

        if ( !$getProduct ) {
            return $this->sendErrorResponse('Product not found...');
        }

        if (auth()->user()->id !== $getProduct->getProductUser->id) {
            return $this->sendErrorResponse('this product does not belong to you');
        }

        $product = $this->productService->manageStock($request, $getProduct);
        return $this->sendSuccessResponse('Stock updated successfully', $product);
    }

    // Delete product
    public function destroy($id)
    {
        $this->productService->deleteProduct($id);
        return $this->sendSuccessResponse('Deleted successfully');
    }
}

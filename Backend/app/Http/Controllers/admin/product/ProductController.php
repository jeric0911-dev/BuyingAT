<?php

namespace App\Http\Controllers\admin\product;

use App\Http\Controllers\BaseController;
use App\Models\Product;
use Illuminate\Http\Request;
use App\Services\product\ProductService;
use App\Services\product\ProductFilterService;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Log;

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
    public function index(Request $request)
    {
        $products = $this->productService->getAllProductsAdmin($request->query('limit'), $request->query('status'));
        return $this->sendPaginatedResponse('Product list retrieved successfully', $products);
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

        $product = $this->productService->unpublishProduct($getProduct);
        return $this->sendSuccessResponse('Unpublished successfully', $product);
    }

    // unpublish product
    public function approveOrReject(Request $request)
    {
        $getProduct = $this->productService->getProductById($request->product_id);

        if ( !$getProduct ) {
            return $this->sendErrorResponse('Product not found...');
        }

        $product = $this->productService->approveOrRejectProduct($getProduct, $request->status);
        return $this->sendSuccessResponse('Product status updated successfully', $product);
    }

    // Delete product
    public function destroy($id)
    {
        $this->productService->deleteProduct($id);
        return $this->sendSuccessResponse('Deleted successfully');
    }
}

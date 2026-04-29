<?php

namespace App\Http\Controllers;

use App\Models\Report;
use Illuminate\Http\Request;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class ReportController extends BaseController
{
    // Get all reports
    public function index(Request $request)
    {
        $limit = $request->query('limit', 10);
        $reports = Report::with([
            'product' => function ($query) {
                $query->select([
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
                ]);
            },
            'product.getGalleryImages' => function ($query) {
                $query->select(['img', 'product_id']);
            },
            'product.getCategory' => function ($query) {
                $query->select(['id', 'category_name']);
            },
            'product.getSubCategory' => function ($query) {
                $query->select(['id', 'sub_category_name']);
            },
            'product.getBrand' => function ($query) {
                $query->select(['id', 'brand_name']);
            },
            'product.colors' => function ($query) {
                $query->select(['id', 'color', 'color_name', 'stock', 'product_id']);
                $query->with(['images' => function ($subQuery) {
                    $subQuery->select(['id', 'color_image', 'product_color_id']);
                }]);
            },
            'product.sizes' => function ($query) {
                $query->select(['id', 'size', 'stock', 'product_id']);
            },
            'product.additionalInfo' => function ($query) {
                $query->select(['id', 'description', 'additional_info', 'specification', 'product_id']);
            },
            'product.variants' => function ($query) {
                $query->select(['id', 'variant_name', 'price', 'discounted_price', 'stock', 'product_id']);
            },
            'product.getAdvertInfo' => function ($query) {
                $query->select(['id', 'product_id']);
            },
            'product.getProductUser' => function ($query) {
                $query->select(['id', 'name', 'profile_img', 'user_type' ]);
            },
            'user' => function ($query) {
                $query->select(['id', 'name', 'profile_img', 'user_type']);
            }
        ])->orderBy('created_at', 'desc')->paginate($limit);
        return $this->sendPaginatedResponse('Reports retrieved successfully', $reports);
    }

    // Get single report
    public function show($id)
    {
        $report = Report::with(
            'product',
            'product.getTitleImage',
            'user'
        )->findOrFail($id);

        return $this->sendSuccessResponse('Report retrieved successfully', $report);
    }

    // Store report
    public function store(Request $request)
    {
        $data = $request->validate([
            'car_id' => 'required',
            'title' => 'required|string',
            'description' => 'required|string',
        ]);

        $data['user_id'] = auth()->user()->id;

        $report = Report::create($data);

        return $this->sendSuccessResponse('Report created successfully', $report, 201);
    }

    // Update report
    public function update(Request $request, $id)
    {
        $report = Report::findOrFail($id);

        $data = $request->validate([
            'car_id' => 'required|exists:cars,id',
            'title' => 'required|string',
            'description' => 'required|string',
        ]);

        $data['user_id'] = auth()->user()->id;

        $report->update($data);

        return $this->sendSuccessResponse('Report updated successfully', $report->fresh());
    }

    // Delete report
    public function destroy($id)
    {
        $report = Report::findOrFail($id);
        $report->delete();

        return $this->sendSuccessResponse('Report deleted successfully', $report);
    }
}

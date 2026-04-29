<?php

use App\Http\Controllers\admin\product\ProductController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'products'], function () {
    Route::get('/get-all', [ProductController::class, 'index'])->middleware('admin.permission:product-management.view');
    Route::get('/get-one/{id}', [ProductController::class, 'show'])->middleware('admin.permission:product-management.view');
    Route::post('/approve-or-reject', [ProductController::class, 'approveOrReject'])->middleware('admin.permission:product-management.edit');
});

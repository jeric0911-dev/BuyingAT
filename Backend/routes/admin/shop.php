<?php

use App\Http\Controllers\admin\shop\ShopController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'shops'], function () {
    Route::get('/get-all', [ShopController::class, 'index'])->middleware('admin.permission:shop-management.view');
    Route::get('/get-one/{id}', [ShopController::class, 'show'])->middleware('admin.permission:shop-management.view');
    Route::post('/add', [ShopController::class, 'store'])->middleware('admin.permission:shop-management.edit');
    Route::post('/approve-or-reject', [ShopController::class, 'approveOrReject'])->middleware('admin.permission:shop-management.edit');
    Route::post('/update/{id}', [ShopController::class, 'update'])->middleware('admin.permission:shop-management.edit');
    Route::delete('/delete/{id}', [ShopController::class, 'destroy'])->middleware('admin.permission:shop-management.delete');
});

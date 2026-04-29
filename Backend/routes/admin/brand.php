<?php

use App\Http\Controllers\admin\brand\BrandController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'brands'], function () {
    Route::get('/get-all', [BrandController::class, 'index'])->middleware('admin.permission:brand.view');
    Route::get('/search', [BrandController::class, 'search'])->middleware('admin.permission:brand.view');
    Route::get('/get-one/{id}', [BrandController::class, 'show'])->middleware('admin.permission:brand.view');
    Route::post('/add', [BrandController::class, 'store'])->middleware('admin.permission:brand.edit');
    Route::post('/update/{id}', [BrandController::class, 'update'])->middleware('admin.permission:brand.edit');
    Route::delete('/delete/{id}', [BrandController::class, 'destroy'])->middleware('admin.permission:brand.delete');
});

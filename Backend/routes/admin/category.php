<?php

use App\Http\Controllers\admin\category\CategoryController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'categories'], function () {
    Route::get('/get-all', [CategoryController::class, 'index'])->middleware('admin.permission:category.view');
    Route::get('/search', [CategoryController::class, 'search'])->middleware('admin.permission:category.view');
    Route::get('/get-one/{id}', [CategoryController::class, 'show'])->middleware('admin.permission:category.view');
    Route::post('/add', [CategoryController::class, 'store'])->middleware('admin.permission:category.edit');
    Route::post('/update/{id}', [CategoryController::class, 'update'])->middleware('admin.permission:category.edit');
    Route::delete('/delete/{id}', [CategoryController::class, 'destroy'])->middleware('admin.permission:category.delete');
});

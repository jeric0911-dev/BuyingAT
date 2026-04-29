<?php

use App\Http\Controllers\admin\blog\BlogCategoryController;
use App\Http\Controllers\admin\blog\BlogController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'blogs'], function () {
    Route::get('/category/get-all', [BlogCategoryController::class, 'index'])->middleware('admin.permission:blog-category.view');
    Route::post('/category/add', [BlogCategoryController::class, 'store'])->middleware('admin.permission:blog-category.edit');
    Route::get('/category/get-one/{id}', [BlogCategoryController::class, 'show'])->middleware('admin.permission:blog-category.view');
    Route::post('/category/update/{id}', [BlogCategoryController::class, 'update'])->middleware('admin.permission:blog-category.edit');
    Route::delete('/category/delete/{id}', [BlogCategoryController::class, 'destroy'])->middleware('admin.permission:blog-category.delete');

    //blogs routes
    Route::get('/get-all', [BlogController::class, 'index'])->middleware('admin.permission:blogs.view');
    Route::post('/add', [BlogController::class, 'store'])->middleware('admin.permission:blogs.edit');
    Route::get('/get-one/{id}', [BlogController::class, 'show'])->middleware('admin.permission:blogs.view');
    Route::post('/update/{id}', [BlogController::class, 'update'])->middleware('admin.permission:blogs.edit');
    Route::delete('/delete/{id}', [BlogController::class, 'destroy'])->middleware('admin.permission:blogs.delete');
});

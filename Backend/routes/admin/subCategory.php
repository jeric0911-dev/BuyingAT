<?php

use App\Http\Controllers\admin\subCategory\SubCategoryController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'sub-categories'], function () {
    Route::get('/get-all', [SubCategoryController::class, 'index'])->middleware('admin.permission:sub-category.view');
    Route::get('/search', [SubCategoryController::class, 'search'])->middleware('admin.permission:sub-category.view');
    Route::get('/get-one/{id}', [SubCategoryController::class, 'show'])->middleware('admin.permission:sub-category.view');
    Route::post('/add', [SubCategoryController::class, 'store'])->middleware('admin.permission:sub-category.edit');
    Route::post('/update/{id}', [SubCategoryController::class, 'update'])->middleware('admin.permission:sub-category.edit');
    Route::delete('/delete/{id}', [SubCategoryController::class, 'destroy'])->middleware('admin.permission:sub-category.delete');
});

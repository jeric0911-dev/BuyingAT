<?php

use App\Http\Controllers\admin\childCategory\ChildCategoryController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'child-categories'], function () {
    Route::get('/get-all', [ChildCategoryController::class, 'index'])->middleware('admin.permission:child-category.view');
    Route::get('/search', [ChildCategoryController::class, 'search'])->middleware('admin.permission:child-category.view');
    Route::get('/get-one/{id}', [ChildCategoryController::class, 'show'])->middleware('admin.permission:child-category.view');
    Route::post('/add', [ChildCategoryController::class, 'store'])->middleware('admin.permission:child-category.edit');
    Route::post('/update/{id}', [ChildCategoryController::class, 'update'])->middleware('admin.permission:child-category.edit');
    Route::delete('/delete/{id}', [ChildCategoryController::class, 'destroy'])->middleware('admin.permission:child-category.delete');
});

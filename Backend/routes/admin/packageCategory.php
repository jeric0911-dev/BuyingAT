<?php

use App\Http\Controllers\admin\packageCategory\PackageCategoryController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'package-category'], function () {
    Route::get('get-all', [PackageCategoryController::class, 'index']);
    Route::get('get-one/{slug}', [PackageCategoryController::class, 'show']);
    Route::post('add', [PackageCategoryController::class, 'store']);
    Route::post('update/{id}', [PackageCategoryController::class, 'update']);
    Route::delete('delete/{id}', [PackageCategoryController::class, 'destroy']);
});

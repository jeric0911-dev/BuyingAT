<?php

use App\Http\Controllers\admin\packageCategory\PackageController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'package'], function () {

    Route::get('get-all', [PackageController::class, 'index'])->middleware('admin.permission:package.view');
    Route::get('get-one/{id}', [PackageController::class, 'show'])->middleware('admin.permission:package.view');
    Route::post('add', [PackageController::class, 'store'])->middleware('admin.permission:package.edit');
    Route::post('status-update/{id}', [PackageController::class, 'updateStatus'])->middleware('admin.permission:package.edit');
    Route::get('best-selling-package', [PackageController::class, 'getBestSellingPackage'])->middleware('admin.permission:package.view');
    Route::post('update/{id}', [PackageController::class, 'update'])->middleware('admin.permission:package.edit');
    Route::delete('delete/{id}', [PackageController::class, 'destroy'])->middleware('admin.permission:package.delete');

});

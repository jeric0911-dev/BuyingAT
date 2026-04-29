<?php

use App\Http\Controllers\admin\morePage\MorePageController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'more-page'], function () {
    Route::get('get-all', [MorePageController::class, 'index'])->middleware('admin.permission:pages.view');
    Route::get('get-one/{slug}', [MorePageController::class, 'show'])->middleware('admin.permission:pages.view');
    Route::post('add', [MorePageController::class, 'store'])->middleware('admin.permission:pages.edit');
    Route::post('update/{id}', [MorePageController::class, 'update'])->middleware('admin.permission:pages.edit');
    Route::delete('delete/{id}', [MorePageController::class, 'destroy'])->middleware('admin.permission:pages.delete');
});

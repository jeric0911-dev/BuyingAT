<?php

use App\Http\Controllers\admin\adminType\AdminTypeControllerWithSpatie;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'admin-types-spatie'], function () {
    Route::get('/get-all', [AdminTypeControllerWithSpatie::class, 'index'])->middleware('admin.permission:role-permission.view');
    Route::get('/get-one/{id}', [AdminTypeControllerWithSpatie::class, 'show'])->middleware('admin.permission:role-permission.view');
    Route::post('/add', [AdminTypeControllerWithSpatie::class, 'store'])->middleware('admin.permission:role-permission.edit');
    Route::post('/update/{id}', [AdminTypeControllerWithSpatie::class, 'update'])->middleware('admin.permission:role-permission.edit');
    Route::delete('/delete/{id}', [AdminTypeControllerWithSpatie::class, 'destroy'])->middleware('admin.permission:role-permission.delete');
});

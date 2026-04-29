<?php

use App\Http\Controllers\admin\auth\AdminController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'admin'], function () {
    Route::get('/get-all', [AdminController::class, 'index'])->middleware('admin.permission:admins.view');
    Route::get('/get-one/{id}', [AdminController::class, 'show'])->middleware('admin.permission:admins.view');
    Route::post('/add', [AdminController::class, 'store'])->middleware('admin.permission:admins.edit');
    Route::post('/update/{id}', [AdminController::class, 'update'])->middleware('admin.permission:admins.edit');
    Route::delete('/delete/{id}', [AdminController::class, 'destroy'])->middleware('admin.permission:admins.delete');
    Route::post('/logout', [AdminController::class, 'logout']);

});

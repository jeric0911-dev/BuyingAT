<?php

use App\Http\Controllers\admin\adminType\AdminTypeController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'admin-types'], function () {
    Route::get('/get-all', [AdminTypeController::class, 'index']);
    Route::get('/get-one/{id}', [AdminTypeController::class, 'show']);
    Route::post('/add', [AdminTypeController::class, 'store']);
    Route::post('/update/{id}', [AdminTypeController::class, 'update']);
    Route::delete('/delete/{id}', [AdminTypeController::class, 'destroy']);
});

<?php

use App\Http\Controllers\admin\city\CityController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'city'], function () {
    Route::get('/get-all', [CityController::class, 'index'])->middleware('admin.permission:cities.view');
    Route::post('/add', [CityController::class, 'store'])->middleware('admin.permission:cities.edit');
    Route::post('/update/{id}', [CityController::class, 'update'])->middleware('admin.permission:cities.edit');
    Route::get('/get-one/{id}', [CityController::class, 'show'])->middleware('admin.permission:cities.view');
    Route::delete('/delete/{id}', [CityController::class, 'destroy'])->middleware('admin.permission:cities.delete');
});

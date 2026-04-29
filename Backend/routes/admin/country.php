<?php

use App\Http\Controllers\admin\country\CountryController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'country'], function () {
    Route::get('/get-all', [CountryController::class, 'index'])->middleware('admin.permission:countries.view');
    Route::post('/add', [CountryController::class, 'store'])->middleware('admin.permission:countries.edit');
    Route::get('/get-one/{id}', [CountryController::class, 'show'])->middleware('admin.permission:countries.view');
    Route::post('/update/{id}', [CountryController::class, 'update'])->middleware('admin.permission:countries.edit');
    Route::delete('/delete/{id}', [CountryController::class, 'destroy'])->middleware('admin.permission:countries.delete');
});

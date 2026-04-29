<?php

use App\Http\Controllers\admin\sliderAndAds\AdvertiseController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'advertise'], function () {
    Route::get('/get-all', [AdvertiseController::class, 'index'])->middleware('admin.permission:advertisement.view');
    Route::post('/add_or_update', [AdvertiseController::class, 'upsert'])->middleware('admin.permission:advertisement.edit');
    Route::delete('/delete/{id}', [AdvertiseController::class, 'destroy'])->middleware('admin.permission:advertisement.delete');
});

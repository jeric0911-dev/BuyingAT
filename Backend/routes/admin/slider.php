<?php

use App\Http\Controllers\admin\sliderAndAds\SliderController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'sliders'], function () {
    Route::get('/get-all', [SliderController::class, 'index'])->middleware('admin.permission:slider.view');
    Route::get('/get-one/{id}', [SliderController::class, 'show'])->middleware('admin.permission:slider.view');
    Route::post('/add', [SliderController::class, 'store'])->middleware('admin.permission:slider.edit');
    Route::post('/update/{id}', [SliderController::class, 'update'])->middleware('admin.permission:slider.edit');
    Route::delete('/delete/{id}', [SliderController::class, 'destroy'])->middleware('admin.permission:slider.delete');
});

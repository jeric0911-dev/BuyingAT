<?php

use App\Http\Controllers\admin\sliderAndAds\AdsController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'ads'], function () {
    Route::get('/get-all', [AdsController::class, 'index']);
    Route::get('/get-one/{id}', [AdsController::class, 'show']);
    Route::post('/add', [AdsController::class, 'store']);
    Route::post('/update/{id}', [AdsController::class, 'update']);
    Route::delete('/delete/{id}', [AdsController::class, 'destroy']);
});

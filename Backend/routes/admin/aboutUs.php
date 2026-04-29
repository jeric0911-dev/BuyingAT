<?php

use App\Http\Controllers\admin\aboutUs\AboutUsController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'about-us'], function () {
    Route::post('/add', [ AboutUsController::class, 'store']);
    Route::get('/get-one', [AboutUsController::class, 'getOne']);
    Route::post('/update', [ AboutUsController::class, 'update']);
});

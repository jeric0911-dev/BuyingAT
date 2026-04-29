<?php

use App\Http\Controllers\admin\testimonial\TestimonialController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'testimonial'], function () {
    Route::get('/get-all', [TestimonialController::class, 'index']);
    Route::get('/get-one/{id}', [TestimonialController::class, 'show']);
    Route::post('/add', [TestimonialController::class, 'store']);
    Route::post('/update/{id}', [TestimonialController::class, 'update']);
    Route::delete('/delete/{id}', [TestimonialController::class, 'destroy']);
});

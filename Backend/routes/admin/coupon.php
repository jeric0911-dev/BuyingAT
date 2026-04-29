<?php

use App\Http\Controllers\admin\coupon\CouponController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'coupons'], function () {
    Route::post('/get-all', [CouponController::class, 'index']);
    Route::post('/add', [CouponController::class, 'store']);
    Route::get('/get-one/{id}', [CouponController::class, 'show']);
    Route::post('/update/{id}', [CouponController::class, 'update']);
    Route::delete('/delete/{id}', [CouponController::class, 'destroy']);
});

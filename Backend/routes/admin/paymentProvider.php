<?php

use App\Http\Controllers\admin\paymentProvider\PaymentProviderController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'payment-provider'], function () {
    Route::get('/get-all', [PaymentProviderController::class, 'index']);
    Route::get('/get-one/{id}', [PaymentProviderController::class, 'show']);
    Route::post('/add', [PaymentProviderController::class, 'store']);
    Route::post('/update/{id}', [PaymentProviderController::class, 'update']);
    Route::delete('/delete/{id}', [PaymentProviderController::class, 'destroy']);
});

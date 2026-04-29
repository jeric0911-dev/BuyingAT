<?php

use App\Http\Controllers\admin\currency\CurrencyController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'currency'], function () {
    Route::get('/get-all', [CurrencyController::class, 'index']);
    Route::post('/add', [CurrencyController::class, 'store']);
    Route::get('/get-one/{id}', [CurrencyController::class, 'show']);
    Route::post('/update/{id}', [CurrencyController::class, 'update']);
    Route::delete('/delete/{id}', [CurrencyController::class, 'destroy']);
});

<?php

use App\Http\Controllers\admin\language\LanguageController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'language'], function () {
    Route::get('/get-all', [LanguageController::class, 'index']);
    Route::post('/add', [LanguageController::class, 'store']);
    Route::get('/get-one/{id}', [LanguageController::class, 'show']);
    Route::post('/update/{id}', [LanguageController::class, 'update']);
    Route::delete('/delete/{id}', [LanguageController::class, 'destroy']);
});

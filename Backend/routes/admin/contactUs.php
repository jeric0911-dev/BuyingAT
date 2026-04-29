<?php

use App\Http\Controllers\admin\contactUs\ContactUsController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'contact-us'], function () {
    Route::get('/get-all', [ContactUsController::class, 'index'])->middleware('admin.permission:client-query.view');
    Route::get('/get-one/{id}', [ContactUsController::class, 'show'])->middleware('admin.permission:client-query.view');
    Route::delete('/delete/{id}', [ContactUsController::class, 'destroy'])->middleware('admin.permission:client-query.delete');
});

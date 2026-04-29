<?php

use App\Http\Controllers\admin\social\SocialController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'socials'], function () {
    Route::get('/get-all', [SocialController::class, 'index'])->middleware('admin.permission:social.view');
    Route::get('/get-one/{id}', [SocialController::class, 'show'])->middleware('admin.permission:social.view');
    Route::post('/add', [SocialController::class, 'store'])->middleware('admin.permission:social.edit');
    Route::post('/update/{id}', [SocialController::class, 'update'])->middleware('admin.permission:social.edit');
    Route::delete('/delete/{id}', [SocialController::class, 'destroy'])->middleware('admin.permission:social.delete');
});

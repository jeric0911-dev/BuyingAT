<?php

use App\Http\Controllers\admin\user\UserController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'users'], function () {
    Route::get('/get-all', [UserController::class, 'getAllUsers'])->middleware('admin.permission:user-management.view');
    Route::get('/get-one/{id}', [UserController::class, 'getSingleUser'])->middleware('admin.permission:user-management.view');
    Route::post('/update-status', [UserController::class, 'updateUserStatus'])->middleware('admin.permission:user-management.edit');
});

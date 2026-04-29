<?php

use App\Http\Controllers\admin\state\StateController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'state'], function () {
    Route::get('/get-all', [StateController::class, 'index'])->middleware('admin.permission:states.view');
    Route::post('/add', [StateController::class, 'store'])->middleware('admin.permission:states.edit');
    Route::post('/update/{id}', [StateController::class, 'update'])->middleware('admin.permission:states.edit');
    Route::get('/get-one/{id}', [StateController::class, 'show'])->middleware('admin.permission:states.view');
    Route::delete('/delete/{id}', [StateController::class, 'destroy'])->middleware('admin.permission:states.delete');
});

<?php

use App\Http\Controllers\admin\faq\FaqController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'faq'], function () {
    Route::get('/get-all', [FaqController::class, 'index'])->middleware('admin.permission:faqs.view');
    Route::post('/add', [FaqController::class, 'store'])->middleware('admin.permission:faqs.edit');
    Route::get('/get-one/{id}', [FaqController::class, 'show'])->middleware('admin.permission:faqs.view');
    Route::post('/update/{id}', [FaqController::class, 'update'])->middleware('admin.permission:faqs.edit');
    Route::delete('/delete/{id}', [FaqController::class, 'destroy'])->middleware('admin.permission:faqs.delete');
});

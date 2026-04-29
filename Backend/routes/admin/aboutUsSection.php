<?php

use App\Http\Controllers\admin\aboutUsSection\AboutUsSectionController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'about_section'], function () {
    Route::get('/get', [AboutUsSectionController::class, 'show']);
    Route::post('/add', [AboutUsSectionController::class, 'store']);
    Route::post('/update', [AboutUsSectionController::class, 'update']);
});

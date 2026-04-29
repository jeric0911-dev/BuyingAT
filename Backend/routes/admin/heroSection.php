<?php

use App\Http\Controllers\admin\heroSection\HeroSectionController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'hero_section'], function () {
    Route::get('/get', [HeroSectionController::class, 'show'])->middleware('admin.permission:hero-section.view');
    Route::post('/create-or-update', [HeroSectionController::class, 'storeOrUpdate'])->middleware('admin.permission:hero-section.edit');
});

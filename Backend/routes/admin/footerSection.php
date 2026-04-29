<?php

use App\Http\Controllers\admin\footerSection\FooterSectionController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'footer_section'], function () {
    Route::get('/get', [FooterSectionController::class, 'show'])->middleware('admin.permission:footer.view');
    Route::post('/create-or-update', [FooterSectionController::class, 'storeOrUpdate'])->middleware('admin.permission:footer.edit');
});

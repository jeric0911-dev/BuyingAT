<?php
use App\Http\Controllers\admin\appSettings\AppSettingController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'app-settings'], function () {
    Route::get('/get-one', [AppSettingController::class, 'show'])->middleware('admin.permission:settings.view');
    Route::post('/update', [ AppSettingController::class, 'update'])->middleware('admin.permission:settings.edit');
});

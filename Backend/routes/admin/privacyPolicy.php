<?php

use App\Http\Controllers\admin\privacyPolicy\PrivacyPolicyController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'privacy-policy'], function () {
    Route::post('/add', [ PrivacyPolicyController::class, 'store']);
    Route::post('/update/{id}', [ PrivacyPolicyController::class, 'update']);
    Route::get('/get-one', [ PrivacyPolicyController::class, 'getOne']);
});

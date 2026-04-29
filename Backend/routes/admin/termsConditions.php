<?php

use App\Http\Controllers\admin\termsAndConditions\TermsAndConditionController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'terms-conditions'], function () {
    Route::post('/add', [ TermsAndConditionController::class, 'store']);
    Route::post('/update/{id}', [ TermsAndConditionController::class, 'update']);
    Route::get('/get-one', [ TermsAndConditionController::class, 'getOne']);
});

<?php

use App\Http\Controllers\admin\listingType\ListingTypeController;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'listing-types'], function () {
    Route::get('get-all', [ListingTypeController::class, 'index']);
    Route::get('get-one/{id}', [ListingTypeController::class, 'show']);
    Route::post('add', [ListingTypeController::class, 'store']);
    Route::post('update/{id}', [ListingTypeController::class, 'update']);
    Route::delete('delete/{id}', [ListingTypeController::class, 'destroy']);
});

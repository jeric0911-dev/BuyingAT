<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('advert_infos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('product_id')->constrained('products');
            $table->string('advert_date')->nullable();
            $table->string('advert_start_date')->nullable();
            $table->string('advert_end_date')->nullable();
            $table->integer('total_amount')->nullable();
            $table->string('duration')->nullable();
            $table->string('cost_till_now')->nullable();
            $table->integer('clicks')->default(0);
            $table->integer('calls')->default(0);
            $table->integer('messages')->default(0);
            $table->integer('favorites')->default(0);
            $table->integer('after_ads_clicks')->default(0);
            $table->integer('after_ads_calls')->default(0);
            $table->integer('after_ads_messages')->default(0);
            $table->integer('after_ads_favorites')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('advert_infos');
    }
};

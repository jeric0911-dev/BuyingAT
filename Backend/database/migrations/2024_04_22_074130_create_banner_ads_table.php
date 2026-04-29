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
        Schema::create('banner_ads', function (Blueprint $table) {
            $table->id();
            $table->string('link_1');
            $table->string('banner_1');
            $table->string('link_2');
            $table->string('banner_2');
            $table->string('link_3');
            $table->string('banner_3');
            $table->string('link_4');
            $table->string('banner_4');
            $table->string('link_5');
            $table->string('banner_5');
            $table->string('link_6');
            $table->string('banner_6');
            $table->string('link_7');
            $table->string('banner_7');
            $table->string('link_8');
            $table->string('banner_8');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('banner_ads');
    }
};

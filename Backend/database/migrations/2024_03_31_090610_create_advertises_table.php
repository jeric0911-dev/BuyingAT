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
        Schema::create('advertises', function (Blueprint $table) {
            $table->id();
            $table->string('img_1');
            $table->string('link_1');
            $table->string('img_2');
            $table->string('link_2');
            $table->string('img_3');
            $table->string('link_3');
            $table->string('img_4');
            $table->string('link_4');
            $table->string('img_5');
            $table->string('link_5');
            $table->string('img_6');
            $table->string('link_6');
            $table->string('img_7');
            $table->string('link_7');
            $table->string('img_8');
            $table->string('link_8');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('advertises');
    }
};

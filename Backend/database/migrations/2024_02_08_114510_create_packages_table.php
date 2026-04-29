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
        Schema::create('packages', function (Blueprint $table) {
            $table->id();
            $table->string('title')->nullable();
            $table->string('price')->nullable();
            $table->string('icon')->nullable();
            $table->decimal('one_month_price')->nullable();
            $table->decimal('six_month_price')->nullable();
            $table->decimal('one_year_price')->nullable();
            $table->string('duration');
            $table->string('product_count');
            $table->string('advert_count')->nullable();
            $table->boolean('status')->nullable()->default(1);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('packages');
    }
};

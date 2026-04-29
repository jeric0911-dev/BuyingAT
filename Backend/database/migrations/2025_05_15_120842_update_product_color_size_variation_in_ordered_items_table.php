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
        Schema::table('ordered_items', function (Blueprint $table) {
            // Drop old columns
            $table->dropColumn('product_size');
            $table->dropColumn('product_color');
            $table->dropColumn('product_variant');
        });

        Schema::table('ordered_items', function (Blueprint $table) {
            // Add new columns as strings
            $table->string('product_size')->nullable();
            $table->string('product_color')->nullable();
            $table->string('product_variant')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ordered_items', function (Blueprint $table) {
            $table->dropColumn('product_size');
            $table->dropColumn('product_color');
            $table->dropColumn('product_variant');
        });

        Schema::table('ordered_items', function (Blueprint $table) {
            $table->unsignedBigInteger('product_size')->nullable();
            $table->unsignedBigInteger('product_color')->nullable();
            $table->unsignedBigInteger('product_variant')->nullable();
        });
    }
};

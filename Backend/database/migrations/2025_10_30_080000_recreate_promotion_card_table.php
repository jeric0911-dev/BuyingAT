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
        // Drop existing table to ensure a clean slate
        Schema::dropIfExists('promotion_card');

        Schema::create('promotion_card', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('card_id');
            $table->decimal('promotion_price', 10, 2);
            $table->integer('promotion_duration')->nullable(); // in hours
            $table->integer('promotion_views')->default(0);
            $table->enum('promotion_type', ['time', 'impression'])->default('time');
            $table->integer('max_views')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            // indexes helpful for queries
            $table->index(['is_active']);
            $table->index(['promotion_type']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('promotion_card');
    }
};



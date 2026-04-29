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
        Schema::create('seller_inventory', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->string('card_title');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->string('grade')->nullable();
            $table->string('sport_type')->nullable();
            $table->json('images')->nullable();
            $table->decimal('weight', 8, 2)->nullable();
            $table->boolean('is_promoted')->default(false);
            $table->timestamp('promotion_expires_at')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index('user_id');
            $table->index('is_promoted');
            $table->index('promotion_expires_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('seller_inventory');
    }
};

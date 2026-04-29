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
        Schema::create('card_request', function (Blueprint $table) {
            $table->id();
            $table->foreignId('card_id')->constrained('seller_inventory')->onDelete('cascade');
            $table->enum('request_status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->timestamps();
            
            // Add indexes for better performance
            $table->index('card_id');
            $table->index('request_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('card_request');
    }
};

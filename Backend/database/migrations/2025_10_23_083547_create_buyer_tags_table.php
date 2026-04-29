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
        Schema::create('buyer_tags', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('buyer_profile_id');
            $table->string('tag_name');
            $table->string('tag_type')->nullable();
            $table->string('card_grade')->nullable();
            $table->integer('purchase_volume')->nullable();
            $table->string('budget_tier')->nullable();
            $table->timestamps();

            $table->foreign('buyer_profile_id')->references('id')->on('buyer_profiles')->onDelete('cascade');
            $table->index('buyer_profile_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('buyer_tags');
    }
};

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
        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('title');
            $table->text('description');
            $table->enum('type', ['percentage', 'fixed_amount'])->default('percentage');
            $table->integer( 'max_discount' )->nullable();
            $table->integer( 'coupon_limit_per_user' )->nullable();
            $table->decimal('value', 8, 2);
            $table->integer('max_uses')->nullable();
            $table->decimal('min_order_amount', 8, 2)->nullable();
            $table->boolean('is_active')->default(true);
            $table->dateTime( 'start_date' )->nullable();
            $table->dateTime( 'end_date' )->nullable();
            $table->unsignedBigInteger( 'created_by' )->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('coupons');
    }
};

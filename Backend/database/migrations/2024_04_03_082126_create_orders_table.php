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
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id')->constrained('users');
            $table->unsignedBigInteger('vendor_id')->constrained('users');
            $table->decimal( 'amount', 10, 2 );
            $table->decimal( 'tax_amount', 10, 2 )->nullable();
            $table->unsignedBigInteger('coupon_id')->nullable();
            $table->decimal( 'coupon_discount', 10, 2 )->nullable();
            $table->enum('payment_status',['pending', 'paid', 'cancelled'] )->default('pending');
            $table->enum('order_status',['pending', 'processing', 'completed', 'cancelled', 'refunded'] )->default( 'pending' );
            $table->unsignedBigInteger( 'payment_method_id' )->nullable();
            $table->string( 'transaction_reference' )->nullable();
            $table->text( 'delivery_address' );
            $table->date( 'estimated_delivery_date' )->nullable();
            $table->string( 'delivery_status' )->nullable();
            $table->decimal( 'delivery_charge', 10, 2 )->nullable();
            $table->text( 'order_note' )->nullable();
            $table->text( 'order_tracking' )->nullable();
            $table->integer('quantity')->default(0);
            $table->string('product_variation')->nullable();
            $table->string('product_size')->nullable();
            $table->string('product_color')->nullable();
            $table->unsignedBigInteger('delivery_man_id')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};

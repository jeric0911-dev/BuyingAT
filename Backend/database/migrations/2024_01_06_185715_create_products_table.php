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
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->text('product_title');
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('listing_type_id')->nullable()->constrained('listing_types');
            $table->foreignId('category_id')->constrained('categories');
            $table->foreignId('sub_category_id')->nullable()->constrained('sub_categories');
            $table->foreignId('child_category_id')->nullable()->constrained('child_categories');
            $table->foreignId('brand_id')->nullable()->constrained('brands');
            $table->text('product_description');
            $table->text('additional_info');
            $table->string('slug_url')->nullable();
            $table->string('stock')->nullable();
            $table->string('sku')->nullable();
            $table->decimal('price', 18, 0);
            $table->decimal('discounted_price', 18, 0)->nullable();
            $table->unsignedTinyInteger('discount_percent')->nullable();
            $table->string('shipping_class')->nullable();
            $table->string('delivery_time')->nullable();
            $table->string('tags')->nullable();
            $table->string('status')->nullable();
            $table->integer('is_favorite')->default(0);
            $table->integer('is_featured')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};

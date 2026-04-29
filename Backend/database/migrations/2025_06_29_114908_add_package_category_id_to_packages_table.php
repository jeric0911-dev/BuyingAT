<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('packages', function (Blueprint $table) {
            $table->unsignedBigInteger('package_category_id')->after('id')->nullable();

            $table->dropColumn(['one_month_price', 'six_month_price', 'one_year_price']);
        });
    }

    public function down(): void
    {
        Schema::table('packages', function (Blueprint $table) {
            $table->dropColumn('package_category_id');

            $table->decimal('one_month_price')->nullable();
            $table->decimal('six_month_price')->nullable();
            $table->decimal('one_year_price')->nullable();
        });
    }
};


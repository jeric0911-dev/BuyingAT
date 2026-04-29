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
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('status');
        });

        Schema::table('products', function (Blueprint $table) {
            $table->enum('status', ['Active', 'Unpublished', 'Pending', 'Disabled', 'Rejected'])
                  ->default('Pending')
                  ->after('tags');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('status');

            $table->string('status')->nullable()->after('tags');
        });
    }
};

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
        Schema::table('shops', function (Blueprint $table) {
            if (!Schema::hasColumn('shops', 'status')) {
                $table->enum('status', ['pending', 'active', 'rejected', 'disabled'])->default('pending')->after('id');
            }

            if (!Schema::hasColumn('shops', 'slug')) {
                $table->string('slug')->nullable()->after('name');
            }
        });

        // Add unique constraint separately, after handling NULLs
        DB::statement("UPDATE shops SET slug = UUID() WHERE slug IS NULL OR slug = ''");

        Schema::table('shops', function (Blueprint $table) {
            $table->unique('slug');
        });
    }

    public function down(): void
    {
        Schema::table('shops', function (Blueprint $table) {
            $table->dropUnique(['slug']);
            $table->dropColumn(['status', 'slug']);
        });
    }

};

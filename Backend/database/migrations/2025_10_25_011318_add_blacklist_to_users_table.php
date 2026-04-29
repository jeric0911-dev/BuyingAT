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
        Schema::table('users', function (Blueprint $table) {
            $table->json('blacklist')->nullable()->after('remember_token');
            $table->integer('violation_count')->default(0)->after('blacklist');
            $table->timestamp('last_violation_at')->nullable()->after('violation_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['blacklist', 'violation_count', 'last_violation_at']);
        });
    }
};

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
        Schema::table('conversation_threads', function (Blueprint $table) {
            // Add conversation_type field if it doesn't exist
            if (!Schema::hasColumn('conversation_threads', 'conversation_type')) {
                $table->string('conversation_type')->default('product')->after('buyer_profile_id');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('conversation_threads', function (Blueprint $table) {
            $table->dropColumn(['conversation_type']);
        });
    }
};

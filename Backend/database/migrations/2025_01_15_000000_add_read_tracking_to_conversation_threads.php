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
            $table->timestamp('sender_last_read_at')->nullable()->after('receiver_id');
            $table->timestamp('receiver_last_read_at')->nullable()->after('sender_last_read_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('conversation_threads', function (Blueprint $table) {
            $table->dropColumn(['sender_last_read_at', 'receiver_last_read_at']);
        });
    }
};


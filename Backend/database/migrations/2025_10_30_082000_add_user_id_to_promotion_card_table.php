<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('promotion_card', 'user_id')) {
            Schema::table('promotion_card', function (Blueprint $table) {
                $table->unsignedBigInteger('user_id')->after('id');
                $table->index('user_id');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('promotion_card', 'user_id')) {
            Schema::table('promotion_card', function (Blueprint $table) {
                $table->dropIndex(['user_id']);
                $table->dropColumn('user_id');
            });
        }
    }
};



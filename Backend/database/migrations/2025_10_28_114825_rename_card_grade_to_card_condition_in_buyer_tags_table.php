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
        Schema::table('buyer_tags', function (Blueprint $table) {
            $table->renameColumn('card_grade', 'card_condition');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('buyer_tags', function (Blueprint $table) {
            $table->renameColumn('card_condition', 'card_grade');
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Modify the ENUM column to add 'cancelled'
        DB::statement("ALTER TABLE order_statuses MODIFY status ENUM('placed', 'packaging', 'on_the_way', 'delivered', 'cancelled') NOT NULL");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert back to original ENUM (without 'cancelled')
        DB::statement("ALTER TABLE order_statuses MODIFY status ENUM('placed', 'packaging', 'on_the_way', 'delivered') NOT NULL");
    }
};

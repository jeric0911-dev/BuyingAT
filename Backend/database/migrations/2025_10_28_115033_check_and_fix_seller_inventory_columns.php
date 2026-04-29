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
        // Check if both grade and condition columns exist
        $columns = \DB::select('SHOW COLUMNS FROM seller_inventory');
        $columnNames = array_column($columns, 'Field');
        
        \Log::info('Current seller_inventory columns:', $columnNames);
        
        // If both grade and condition exist, drop grade and keep condition
        if (in_array('grade', $columnNames) && in_array('condition', $columnNames)) {
            \Log::info('Both grade and condition columns exist, dropping grade');
            Schema::table('seller_inventory', function (Blueprint $table) {
                $table->dropColumn('grade');
            });
        }
        
        // If only grade exists, rename it to condition
        if (in_array('grade', $columnNames) && !in_array('condition', $columnNames)) {
            \Log::info('Only grade column exists, renaming to condition');
            Schema::table('seller_inventory', function (Blueprint $table) {
                $table->renameColumn('grade', 'condition');
            });
        }
        
        // Now add the grade column properly
        if (!in_array('grade', $columnNames)) {
            \Log::info('Adding grade column');
            Schema::table('seller_inventory', function (Blueprint $table) {
                $table->enum('grade', ['Yes', 'No'])->nullable()->default('No')->after('condition');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // This migration is safe to rollback
        // It will just ensure the grade column exists
    }
};

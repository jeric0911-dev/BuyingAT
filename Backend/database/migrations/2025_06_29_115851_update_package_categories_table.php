<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('package_categories', function (Blueprint $table) {
            $table->integer('duration')->change(); // change column type from string to integer
            $table->integer('status')->default(1)->after('duration'); // add status column
        });
    }

    public function down(): void
    {
        Schema::table('package_categories', function (Blueprint $table) {
            $table->string('duration')->nullable()->change(); // revert back to string
            $table->dropColumn('status'); // remove status column
        });
    }
};


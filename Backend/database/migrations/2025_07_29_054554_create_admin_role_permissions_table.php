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
        Schema::create('admin_role_permissions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('admin_type_id')->constrained('admin_types')->onDelete('cascade');
            $table->string('name');
            $table->tinyInteger('view')->default(0);
            $table->tinyInteger('edit')->default(0);
            $table->tinyInteger('delete')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admin_role_permissions');
    }
};

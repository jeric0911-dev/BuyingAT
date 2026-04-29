<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('password_reset_otp')->nullable();
            $table->timestamp('password_reset_expires_at')->nullable();
            //$table->string('phone', 50)->change();
            //$table->dropColumn('middle_name');    // 👈 removes on migrate
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['password_reset_otp', 'password_reset_expires_at']);
        });
    }
};

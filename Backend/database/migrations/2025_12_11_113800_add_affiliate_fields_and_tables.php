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
        // Add affiliate-related fields to users table
        Schema::table('users', function (Blueprint $table) {
            $table->string('affiliate_code')->nullable()->unique()->after('user_name');
            $table->boolean('is_affiliate')->default(false)->after('affiliate_code');
            $table->decimal('commission_rate', 5, 4)->default(0)->after('is_affiliate');
        });

        // Referrals table: link referrer to referred user
        Schema::create('referrals', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('referrer_id');
            $table->unsignedBigInteger('referred_user_id');
            $table->timestamps();

            $table->foreign('referrer_id')
                ->references('id')->on('users')
                ->onDelete('cascade');

            $table->foreign('referred_user_id')
                ->references('id')->on('users')
                ->onDelete('cascade');

            $table->unique(['referrer_id', 'referred_user_id']);
        });

        // Affiliate commissions table: track earnings per order
        Schema::create('affiliate_commissions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('referrer_id');
            $table->unsignedBigInteger('referred_user_id')->nullable();
            $table->unsignedBigInteger('order_id')->nullable();
            $table->decimal('amount', 16, 8)->default(0);
            $table->enum('status', ['pending', 'paid', 'cancelled'])->default('pending');
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->foreign('referrer_id')
                ->references('id')->on('users')
                ->onDelete('cascade');

            $table->foreign('referred_user_id')
                ->references('id')->on('users')
                ->onDelete('set null');

            $table->foreign('order_id')
                ->references('id')->on('orders')
                ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('affiliate_commissions');
        Schema::dropIfExists('referrals');

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'affiliate_code')) {
                $table->dropUnique(['affiliate_code']);
                $table->dropColumn('affiliate_code');
            }
            if (Schema::hasColumn('users', 'is_affiliate')) {
                $table->dropColumn('is_affiliate');
            }
            if (Schema::hasColumn('users', 'commission_rate')) {
                $table->dropColumn('commission_rate');
            }
        });
    }
};



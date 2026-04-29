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
        Schema::table('app_settings', function (Blueprint $table) {
            $table->string('web_app_logo')->nullable()->after('back_end_base_url');
            $table->string('fav_icon')->nullable()->after('web_app_logo');
            $table->string('login_page_title')->nullable()->after('fav_icon');
            $table->string('header_title')->nullable()->after('login_page_title');
            $table->string('pixel_id')->nullable()->after('header_title');
            $table->string('google_analytics_id')->nullable()->after('pixel_id');
            $table->string('meta_title')->nullable()->after('google_analytics_id');
            $table->text('meta_description')->nullable()->after('meta_title');
            $table->string('app_base_url')->nullable()->after('meta_description');
            $table->string('frontend_url')->nullable()->after('app_base_url');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('app_settings', function (Blueprint $table) {
            $table->dropColumn([
                'web_app_logo',
                'fav_icon',
                'login_page_title',
                'header_title',
                'pixel_id',
                'google_analytics_id',
                'meta_title',
                'meta_description',
                'app_base_url',
                'frontend_url',
            ]);
        });
    }
};

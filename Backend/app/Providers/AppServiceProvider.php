<?php

namespace App\Providers;

use App\Models\AppSetting;
use Illuminate\Support\ServiceProvider;

use App\Models\MailConfig;
use App\Models\Gateway;
use App\Models\PusherConfig;
use Illuminate\Support\Facades\Config;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {


        //smtp mail config
        $mailSettings = MailConfig::first();

        if ($mailSettings) {
            \Log::info('📧 Applying mail configuration from database', [
                'mailer' => $mailSettings->mailer,
                'host' => $mailSettings->host,
                'port' => $mailSettings->port,
                'from_address' => $mailSettings->mail_from_address,
                'from_name' => $mailSettings->mail_from_name
            ]);

            Config::set('mail.default', $mailSettings->mailer);
            Config::set('mail.mailers.smtp.host', $mailSettings->host);
            Config::set('mail.mailers.smtp.port', $mailSettings->port);
            Config::set('mail.mailers.smtp.encryption', $mailSettings->encryption);
            Config::set('mail.mailers.smtp.username', $mailSettings->username);
            Config::set('mail.mailers.smtp.password', $mailSettings->password);
            Config::set('mail.from.address', $mailSettings->mail_from_address);
            Config::set('mail.from.name', $mailSettings->mail_from_name);

            \Log::info('✅ Mail configuration applied successfully', [
                'final_from_address' => config('mail.from.address'),
                'final_from_name' => config('mail.from.name')
            ]);
        } else {
            \Log::warning('⚠️ No mail configuration found in database');
        }

        //pusher config
        $pusherSettings = PusherConfig::first();

        if ($pusherSettings) {
            Config::set('broadcasting.connections.pusher.key', $pusherSettings->pusher_app_key);
            Config::set('broadcasting.connections.pusher.secret', $pusherSettings->pusher_app_secret);
            Config::set('broadcasting.connections.pusher.app_id', $pusherSettings->pusher_app_id);

            if (!empty($pusherSettings->pusher_app_cluster)) {
                Config::set('broadcasting.connections.pusher.options.cluster', $pusherSettings->pusher_app_cluster);
            }

            if (!empty($pusherSettings->pusher_host)) {
                Config::set('broadcasting.connections.pusher.options.host', $pusherSettings->pusher_host);
            }
            if (!empty($pusherSettings->pusher_port)) {
                Config::set('broadcasting.connections.pusher.options.port', $pusherSettings->pusher_port);
            }
            if (!empty($pusherSettings->pusher_scheme)) {
                Config::set('broadcasting.connections.pusher.options.scheme', $pusherSettings->pusher_scheme);
            }
        }


        //ssl commerz config
        $getSslCredentials = Gateway::where('alias', 'sslcommerz')->first();

        $getAppSetting = AppSetting::first();

        if($getSslCredentials){
            $getSslCredentials = json_decode($getSslCredentials->gateway_parameters, true);

            $apiDomain = $getSslCredentials['SSLCZ_TESTMODE'] ? "https://sandbox.sslcommerz.com" : "https://securepay.sslcommerz.com";

            Config::set('sslcommerz.apiCredentials.store_id', $getSslCredentials['SSL_STORE_ID']);
            Config::set('sslcommerz.apiCredentials.store_password', $getSslCredentials['SSL_STORE_PASSWORD']);
            Config::set('sslcommerz.apiDomain', $apiDomain);
            Config::set('sslcommerz.connect_from_localhost', $getSslCredentials['IS_LOCAL_HOST']);

            Config::set('sslcommerz.success_url', '/api/sslcommerz/success');
            Config::set('sslcommerz.failed_url', '/api/sslcommerz/fail');
            Config::set('sslcommerz.cancel_url', '/api/sslcommerz/cancel');
            Config::set('sslcommerz.ipn_url', '/api/sslcommerz/ipn');
        }

        //app url
        if ($getAppSetting && $getAppSetting->back_end_base_url) {
            Config::set('app.url', $getAppSetting->back_end_base_url);
        }

    }
}

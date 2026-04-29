<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ServeNetwork extends Command
{
    protected $signature = 'serve:network';
    protected $description = 'Serve the app accessible from local network';

    public function handle()
    {
        $this->info('Starting Laravel server on 0.0.0.0:8001...');

        passthru('php artisan serve --host=0.0.0.0 --port=8001');
    }
}

<?php

namespace App\Traits;

use App\Models\MailConfig;

trait MailConfigTrait
{
    protected function getMailConfig(): array
    {
        $mailConfig = MailConfig::first();

        return [
            'from_email' => $mailConfig?->mail_from_address ?? 'dbugsta.off@example.com',
            'from_name' => $mailConfig?->mail_from_name ?? 'Classified',
        ];
    }
}

<?php

namespace App\Utils;

use Illuminate\Support\Str;

class StringUtil
{
    // Generate a random 8-digit code
    public static function generate8DigitCode(): string
    {
        return str_pad(random_int(0, 99999999), 8, '0', STR_PAD_LEFT);
    }

    // Generate a random string
    public static function generateRandomString(int $length = 8): string
    {
        return substr(str_shuffle(str_repeat('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length / 62))), 0, $length);
    }

    // Format string with common transformations
    public static function formatString(string $value, string $format = 'snake'): string
    {
        return match ($format) {
            'snake' => Str::snake($value),
            'camel' => Str::camel($value),
            'studly' => Str::studly($value),
            'slug' => Str::slug($value),
            'title' => Str::title($value),
            'upper' => Str::upper($value),
            'lower' => Str::lower($value),
            default => $value,
        };
    }

    // Limit string to a given length
    public static function limit(string $value, int $limit = 100, string $end = '...'): string
    {
        return Str::limit($value, $limit, $end);
    }

    // Convert string to array
    public static function toArray(string $value, string $delimiter = ','): array
    {
        return explode($delimiter, $value);
    }

    // Convert array to string
    public static function toString(array $value, string $delimiter = ','): string
    {
        return implode($delimiter, $value);
    }

    // Convert string to JSON
    public static function toJson(string $value): array
    {
        return json_decode($value, true);
    }

    // Convert JSON to string
    public static function fromJson(array $value): string
    {
        return json_encode($value);
    }

    // Convert string to base64
    public static function toBase64(string $value): string
    {
        return base64_encode($value);
    }

    // Convert base64 to string
    public static function fromBase64(string $value): string
    {
        return base64_decode($value);
    }

    // Convert string to HTML entities
    public static function toHtmlEntities(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }

    // Convert HTML entities to string
    public static function fromHtmlEntities(string $value): string
    {
        return htmlspecialchars_decode($value, ENT_QUOTES);
    }

    // Convert string to URL
    public static function toUrl(string $value): string
    {
        return urlencode($value);
    }

    // Convert URL to string
    public static function fromUrl(string $value): string
    {
        return urldecode($value);
    }

    // Convert string to UUID
    public static function toUuid(string $value): string
    {
        return Str::uuid($value)->toString();
    }

    // Convert UUID to string
    public static function fromUuid(string $value): string
    {
        return Str::uuid($value)->toString();
    }
    
    // Convert string to slug with 3-character random suffix
    public static function toSlug(string $value): string
    {
        $slug = Str::slug($value);
        $suffix = substr(str_shuffle('abcdefghijklmnopqrstuvwxyz0123456789'), 0, 3);
        return $slug . '-' . $suffix;
    }

    // Convert slug to string
    public static function fromSlug(string $value): string
    {
        return str_replace('-', ' ', $value);
    }

}

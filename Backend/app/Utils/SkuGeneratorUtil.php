<?php
namespace App\Utils;

class SkuGeneratorUtil
{
    public static function generate($productId, $variantId = null, $colorId = null, $sizeId = null)
    {
        return 'SKU-' . $productId
            . ($variantId ? "-V$variantId" : '')
            . ($colorId ? "-C$colorId" : '')
            . ($sizeId ? "-S$sizeId" : '')
            . '-' . strtoupper(uniqid());
    }
}

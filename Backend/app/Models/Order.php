<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = ['order_id', 'product_size', 'product_variant', 'product_color', 'customer_id', 'vendor_id', 'amount', 'quantity', 'tax_amount', 'coupon_id', 'coupon_discount', 'payment_status', 'order_status', 'payment_method_id', 'transaction_reference', 'delivery_address', 'estimated_delivery_date', 'delivery_status', 'delivery_charge', 'order_note', 'order_tracking', 'delivery_man_id'];


    //get ordered items
    public function orderedItems()
    {
        return $this->hasMany(OrderedItem::class);
    }

    //get order status
    public function orderStatus()
    {
        return $this->hasMany(OrderStatus::class);
    }
}

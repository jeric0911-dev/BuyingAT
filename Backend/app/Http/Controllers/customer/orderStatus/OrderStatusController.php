<?php

namespace App\Http\Controllers\customer\orderStatus;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;

class OrderStatusController extends BaseController
{
    //update order status
    public function updateStatus(Request $request, $id)
    {
        $order = Order::findOrFail($id);
        $order->order_status = $request->status;
        $order->save();

        OrderStatusLog::create([
            'order_id' => $order->id,
            'status' => $request->status,
            'message' => $request->message,
        ]);

        return ResponseService::success('Status Updated');
    }

}

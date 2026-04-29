<?php

namespace App\Http\Controllers\gateway;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\Transaction;
use App\Models\Currency;
use App\Models\Wallet;
use App\Models\Gateway;
use Illuminate\Http\Request;
use Razorpay\Api\Api;
use Illuminate\Support\Str;

class RazorpayPaymentController extends Controller
{
    public function payment(Request $request)
    {
        $getCredentials = Gateway::where('alias', 'razorpay')->first();

        $getCredentials = json_decode($getCredentials->gateway_parameters, true);

        if (!$getCredentials) {
            return response()->json([
                'status' => 'error',
                'message' => 'credentials not found'
            ]);
        }

        try {
            $api = new Api($getCredentials['RAZORPAY_KEY'], $getCredentials['RAZORPAY_SECRET']);

            $order = $api->order->create([
                'receipt' => Str::random(16),
                'amount' => round($request->amount * 100),
                'currency' => $request->currency,
                'payment_capture' => 1
            ]);



            $currency = Currency::where('currency_code', $request->currency )->first();

            if(!$currency){
                return response()->json([
                    'status' => 'error',
                    'message' => 'currency not found'
                ]);
            }
            $transaction = Transaction::create([
                'transaction_id' => $order->id,
                'user_id' => auth()->user()->id,
                'initiated' => now(),
                'payment_method' => 'Razorpay',
                'amount' => $request->input('amount'),
                'status' => 'pending',
                'conversion' => '1 USD = '.$currency->value.' '.$currency->currency_code,
                'currency' => $request->currency
            ]);

            $order['key'] = $getCredentials['RAZORPAY_KEY'];

            return response()->json([
                'status' => 'success',
                'message' => 'Order Created successfully',
                'data' => $order->toArray()
            ]);
        } catch (\Throwable $th) {
            return response()->json([
                'status' => 'error',
                'message' => $th->getMessage()
            ]);
        }
    }

    //pay
    public function pay(Request $request)
    {
        try {

            $payment = Transaction::where('transaction_id', $request->order_id)->first();

                if (!$payment) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Transaction not found',
                    ]);
                }

                // Check if the payment has already been processed
                if ($payment->status === 'success') {
                    return response()->json(['status' => 'error', 'message' => 'Payment already processed']);
                }


                $currency = Currency::where('currency_code', $request->currency)->first();

                if(!$currency){
                    return response()->json([
                        'status' => 'error',
                        'message' => 'currency not found'
                    ]);
                }

                $payment->credits = round($request->amount / $currency->value, 2);
                $payment->status = 'success';
                $payment->save();

                $wallet = Wallet::where('user_id', auth()->user()->id )->first();

                if (!$wallet) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Wallet not found for the user',
                    ]);
                }

                //amount divided by conversion rate
                $wallet->balance += round($request->amount / $currency->value, 2);

                $wallet->last_recharge = round($request->amount / $currency->value, 2);

                $wallet->save();

                return response()->json(['status' => 'success', 'message' => 'Payment successful']);

            } catch (\Throwable $th) {
                return response()->json([
                    'status' => 'error',
                    'message' => $th->getMessage()
                ]);
            }
    }
}

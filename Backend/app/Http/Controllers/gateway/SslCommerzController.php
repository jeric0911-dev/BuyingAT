<?php

namespace App\Http\Controllers\gateway;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use DB;
use App\Library\SslCommerz\SslCommerzNotification;
use Illuminate\Support\Carbon;
use App\Models\Transaction;
use App\Models\Currency;
use App\Models\Wallet;
use App\Models\AppSetting;
use Illuminate\Support\Facades\Log;

class SslCommerzController extends Controller
{
    public function payViaAjax(Request $request)
    {
        $post_data = array();
        $post_data['total_amount'] = $request->amount;
        $post_data['currency'] = $request->currency;
        $post_data['tran_id'] = uniqid();

        # CUSTOMER INFORMATION
        $post_data['cus_name'] = $request->customer_name;
        $post_data['cus_email'] = $request->customer_email;
        $post_data['cus_phone'] = $request->customer_phone;

        $post_data['shipping_method'] = "NO";
        $post_data['product_name'] = "Computer";
        $post_data['product_category'] = "Goods";
        $post_data['product_profile'] = "physical-goods";


         $update_product = DB::table('transactions')
             ->where('transaction_id', $post_data['tran_id'])
             ->updateOrInsert([
                 'initiated' => Carbon::now(),
                 'user_id'=> auth()->user()->id,
                 'amount' => $post_data['total_amount'],
                 'status' => 'pending',
                 'transaction_id' => $post_data['tran_id'],
                 'payment_method' => 'SSL Commerz',
                 'currency' => $post_data['currency'],
                 'created_at' => Carbon::now(),
                 'updated_at' => Carbon::now(),
             ]);

        $sslc = new SslCommerzNotification();

        Log::info('SSL Commerz Payment Initiated', [
            'transaction_id' => $post_data['tran_id'],
            'amount' => $post_data['total_amount'],
            'currency' => $post_data['currency'],
            'customer_name' => $post_data['cus_name'],
            'customer_email' => $post_data['cus_email'],
            'customer_phone' => $post_data['cus_phone']
        ]);

        $payment_options = $sslc->makePayment($post_data, 'checkout', 'json');

        if (!is_array($payment_options)) {

            return json_decode($payment_options);
        }

    }

    //hit this route for successful payment
    public function success(Request $request)
    {
        $tran_id = $request->input('tran_id');
        $amount = $request->input('amount');
        $currency = $request->input('currency');

        $sslc = new SslCommerzNotification();

        $order_details = DB::table('transactions')
            ->where('transaction_id', $tran_id)
            ->select('transaction_id', 'status', 'currency', 'amount')->first();

        if ($order_details->status == 'pending') {
            $validation = $sslc->orderValidate($request->all(), $tran_id, $amount, $currency);

            if ($validation) {

                //get transaction
                $payment = Transaction::where('transaction_id', $tran_id)->first();

                if (!$payment) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Transaction not found',
                    ]);
                }

                $currency = Currency::where('currency_code', $currency)->first();

                if(!$currency){
                    return response()->json([
                        'status' => 'error',
                        'message' => 'currency not found'
                    ]);
                }

                $payment->credits = round($amount / $currency->value, 2);
                $payment->save();


                $wallet = Wallet::where('user_id', $payment->user_id )->first();

                if (!$wallet) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Wallet not found for the user',
                    ]);
                }

                //amount divided by conversion rate
                $wallet->balance += round($amount / $currency->value, 2);

                $wallet->last_recharge = round($amount / $currency->value, 2);

                $wallet->save();


                //update transaction status
                $update_product = DB::table('transactions')
                    ->where('transaction_id', $tran_id)
                    ->update(['status' => 'success', 'conversion' => '1 USD = '.$currency->value.' '.$currency->currency_code]);



                //get base url
                $appSetting = AppSetting::first();

                if(!$appSetting){
                    return response()->json([
                        'status' => 'error',
                        'message' => 'App Settings Base Url Not Found'

                    ]);
                }

                return redirect()->away($appSetting->front_end_base_url.'/wallet?status=success&message=Payment+successful');

                return response()->json([
                    'status' => 'success',
                    'message' => 'payment successfull'
                ]);

            }
        } else if ($order_details->status == 'success') {
            return redirect()->away($appSetting->front_end_base_url.'/wallet?status=success&message=Payment+is+already+successful+successful');
        } else {
            return response()->json([
                'status' => 'error',
                'message' => 'invalid transaction'
            ]);
        }


    }

    //for failed transaction
    public function fail(Request $request)
    {
        $tran_id = $request->input('tran_id');

        $order_details = DB::table('transactions')
            ->where('transaction_id', $tran_id)
            ->select('transaction_id', 'status', 'currency', 'amount')->first();

        if ($order_details->status == 'pending') {
            $update_product = DB::table('transactions')
                ->where('transaction_id', $tran_id)
                ->update(['status' => 'failed']);
                return response()->json([
                    'status' => 'error',
                    'message' => 'Transaction is failed'
                ]);
        } else if ($order_details->status == 'success') {
            return response()->json([
                'status' => 'success',
                'message' => 'Transaction is already successful'
            ]);
        } else {
            return response()->json([
                'status' => 'error',
                'message' => 'Transaction is invalid'
            ]);
        }

    }

    //for cancel
    public function cancel(Request $request)
    {
        $tran_id = $request->input('tran_id');

        $order_details = DB::table('transactions')
            ->where('transaction_id', $tran_id)
            ->select('transaction_id', 'status', 'currency', 'amount')->first();

        if ($order_details->status == 'pending') {
            $update_product = DB::table('transaction')
                ->where('transaction_id', $tran_id)
                ->update(['status' => 'canceled']);
                return response()->json([
                    'status' => 'error',
                    'message' => 'Transaction is cancel'
                ]);
        } else if ($order_details->status == 'success') {
            return response()->json([
                'status' => 'success',
                'message' => 'Transaction is already successful'
            ]);
        } else {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid transaction'
            ]);
        }


    }

    public function ipn(Request $request)
    {
        #Received all the payement information from the gateway
        if ($request->input('tran_id')) #Check transation id is posted or not.
        {

            $tran_id = $request->input('tran_id');

            #Check order status in order tabel against the transaction id or order id.
            $order_details = DB::table('orders')
                ->where('transaction_id', $tran_id)
                ->select('transaction_id', 'status', 'currency', 'amount')->first();

            if ($order_details->status == 'Pending') {
                $sslc = new SslCommerzNotification();
                $validation = $sslc->orderValidate($request->all(), $tran_id, $order_details->amount, $order_details->currency);
                if ($validation == TRUE) {

                    $update_product = DB::table('orders')
                        ->where('transaction_id', $tran_id)
                        ->update(['status' => 'Processing']);

                    echo "Transaction is successfully Completed";
                }
            } else if ($order_details->status == 'Processing' || $order_details->status == 'Complete') {

                echo "Transaction is already successfully Completed";
            } else {

                echo "Invalid Transaction";
            }
        } else {
            echo "Invalid Data";
        }
    }
}

<?php

namespace App\Http\Controllers\gateway;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use App\Models\Transaction;
use App\Models\Currency;
use App\Models\Wallet;
use App\Models\Gateway;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Omnipay\Omnipay;
use Illuminate\Support\Str;

class PaypalPaymentController extends Controller
{
    protected $gateway;

    public function __construct()
    {
        $getCredentials = Gateway::where('alias', 'paypal')->first();
        $getCredentials = json_decode($getCredentials->gateway_parameters, true);

        if (!$getCredentials) {
            abort(500, 'PayPal credentials not found');
        }

        $this->gateway = Omnipay::create('PayPal_Rest');
        $this->gateway->setClientId($getCredentials['PAYPAL_CLIENT_ID']);
        $this->gateway->setSecret($getCredentials['PAYPAL_CLIENT_SECRET']);
        $this->gateway->setTestMode($getCredentials['PAYPAL_MODE'] === 'sandbox');
    }

    // Initiate PayPal payment
    public function initiatePayment(Request $request)
    {
        try {
            $transactionId = Str::uuid()->toString();

            $transaction = Transaction::create([
                'transaction_id' => $transactionId,
                'user_id' => auth()->id(),
                'initiated' => Carbon::now(),
                'payment_method' => 'Paypal',
                'amount' => $request->amount,
                'currency' => $request->currency,
                'status' => 'pending',
                'conversion' => '1 USD = ' . $request->currency
            ]);

            $appSetting = AppSetting::first();
            if (!$appSetting) {
                return response()->json(['status' => 'error', 'message' => 'Base URL not found']);
            }

            $response = $this->gateway->purchase([
                'amount'        => $request->amount,
                'currency'      => $request->currency,
                'transactionId' => $transactionId,
                'invoiceNumber' => $transactionId,
                'returnUrl'     => $appSetting->back_end_base_url . '/api/paypal/success?transaction_id=' . $transactionId,
                'cancelUrl'     => $appSetting->back_end_base_url . '/api/paypal/cancel?transaction_id=' . $transactionId,
            ])->send();

            if ($response->isRedirect()) {
                return response()->json(['redirect_url' => $response->getRedirectUrl()]);
            } else {
                return response()->json(['status' => 'error', 'message' => $response->getMessage()]);
            }
        } catch (\Throwable $th) {
            Log::error('PayPal Initiate Error', ['error' => $th->getMessage()]);
            return response()->json(['status' => 'error', 'message' => $th->getMessage()]);
        }
    }

    // PayPal success callback
    public function success(Request $request)
    {
        try {
            $transactionId = $request->query('transaction_id');
            $appSetting = AppSetting::first();

            $response = $this->gateway->completePurchase([
                'payerId' => $request->query('PayerID'),
                'transactionReference' => $request->query('paymentId'),
            ])->send();

            if ($response->isSuccessful()) {
                $data = $response->getData();
                // Log::info('PayPal Success Data', $data);

                $payment = Transaction::where('transaction_id', $transactionId)->first();
                if (!$payment) {
                    return redirect($appSetting->front_end_base_url . '/wallet?error=TransactionNotFound');
                }

                if ($payment->status === 'success') {
                    return redirect($appSetting->front_end_base_url . '/wallet?info=AlreadyProcessed');
                }

                $amount = $data['transactions'][0]['amount']['total'];
                $currencyCode = $data['transactions'][0]['amount']['currency'];

                $currency = Currency::where('currency_code', $currencyCode)->first();
                if (!$currency) {
                    return redirect($appSetting->front_end_base_url . '/wallet?error=CurrencyNotFound');
                }

                $credits = round($amount / $currency->value, 2);

                $payment->update([
                    'credits' => $credits,
                    'status' => 'success'
                ]);

                $wallet = Wallet::firstOrCreate(
                    ['user_id' => $payment->user_id],
                    ['balance' => 0]
                );

                $wallet->balance += $credits;
                $wallet->last_recharge = $credits;
                $wallet->save();

                return redirect($appSetting->front_end_base_url . '/wallet?success=true');
            } else {
                return redirect($appSetting->front_end_base_url . '/wallet?error=' . urlencode($response->getMessage()));
            }
        } catch (\Throwable $th) {
            return response()->json(['status' => 'error', 'message' => $th->getMessage()]);
        }
    }

    // PayPal cancel callback
    public function cancel(Request $request)
    {
        try {
            $transactionId = $request->query('transaction_id');
            $appSetting = AppSetting::first();

            $transaction = Transaction::where('transaction_id', $transactionId)->first();

            if ($transaction && $transaction->status === 'pending') {
                $transaction->status = 'cancelled';
                $transaction->save();
            }

            return redirect($appSetting->front_end_base_url . '/wallet?cancelled=true');
        } catch (\Throwable $th) {
            return response()->json(['status' => 'error', 'message' => $th->getMessage()]);
        }
    }
}

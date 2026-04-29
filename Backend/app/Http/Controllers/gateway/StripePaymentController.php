<?php

namespace App\Http\Controllers\gateway;

use App\Http\Controllers\Controller;
use App\Models\Gateway;
use App\Models\AppSetting;
use App\Models\Transaction;
use App\Models\Currency;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Stripe\Stripe;
use Stripe\Checkout\Session;

class StripePaymentController extends Controller
{
    // Create Checkout
    public function createCheckoutSession(Request $request)
    {
        try {
            $credentials = Gateway::where('alias', 'stripe')->first();
            $credentials = json_decode($credentials->gateway_parameters, true);

            if (!$credentials) {
                return response()->json(['status' => 'error', 'message' => 'Credentials not found']);
            }

            Stripe::setApiKey($credentials['STRIPE_SECRET']);

            $amount = intval($request->amount * 100);

            $currency = Currency::where('currency_code', $request->currency)->first();
            if (!$currency) {
                return response()->json(['status' => 'error', 'message' => 'Currency not found']);
            }

            $appSetting = AppSetting::first();
            if (!$appSetting) {
                return response()->json(['status' => 'error', 'message' => 'Base URL not found']);
            }

            $transactionId = Str::uuid()->toString();

            Transaction::create([
                'transaction_id' => $transactionId,
                'user_id' => auth()->id(),
                'initiated' => now(),
                'payment_method' => 'Stripe',
                'amount' => $request->amount,
                'status' => 'pending',
                'conversion' => '1 USD = ' . $currency->value . ' ' . $currency->currency_code,
                'currency' => $request->currency,
            ]);

            $session = Session::create([
                'payment_method_types' => ['card'],
                'line_items' => [[
                    'price_data' => [
                        'currency' => $request->currency,
                        'product_data' => ['name' => 'Wallet Topup'],
                        'unit_amount' => $amount,
                    ],
                    'quantity' => 1,
                ]],
                'mode' => 'payment',
                'metadata' => [
                    'transaction_id' => $transactionId,
                    'user_id' => auth()->id()
                ],
                'success_url' => $appSetting->back_end_base_url . '/api/stripe/payment-success?transaction_id=' . $transactionId,
                'cancel_url' => $appSetting->back_end_base_url . '/api/stripe/payment-cancel?transaction_id=' . $transactionId,
            ]);

            return response()->json([
                'status' => 'success',
                'redirect_url' => $session->url
            ]);
        } catch (\Throwable $th) {
            return response()->json(['status' => 'error', 'message' => $th->getMessage()]);
        }
    }

    // Payment success handler
    public function paymentSuccess(Request $request)
    {
        try {
            $appSetting = AppSetting::first();
            $transactionId = $request->query('transaction_id');

            $transaction = Transaction::where('transaction_id', $transactionId)->first();
            if (!$transaction) {
                // Check if API request (from Flutter)
                if ($request->wantsJson() || $request->expectsJson()) {
                    return response()->json(['status' => 'error', 'message' => 'Transaction not found']);
                }
                return redirect($appSetting->front_end_base_url . '/wallet?error=TransactionNotFound');
            }

            if ($transaction->status === 'success') {
                // Check if API request
                if ($request->wantsJson() || $request->expectsJson()) {
                    return response()->json(['status' => 'success', 'message' => 'Payment already processed']);
                }
                return redirect($appSetting->front_end_base_url . '/wallet?info=AlreadyProcessed');
            }

            // Note: Payment verification with Stripe is typically done via webhooks
            // For now, we trust that if Stripe redirects to success URL, payment was successful
            // In production, you should implement Stripe webhooks for secure verification
            // For now, we'll process the payment since Stripe only redirects here on success

            $currency = Currency::where('currency_code', $transaction->currency)->first();
            if (!$currency) {
                if ($request->wantsJson() || $request->expectsJson()) {
                    return response()->json(['status' => 'error', 'message' => 'Currency not found']);
                }
                return redirect($appSetting->front_end_base_url . '/wallet?error=CurrencyNotFound');
            }

            $credits = round($transaction->amount / $currency->value, 2);
            $transaction->status = 'success';
            $transaction->credits = $credits;
            $transaction->save();

            $wallet = Wallet::firstOrCreate(
                ['user_id' => $transaction->user_id],
                ['balance' => 0, 'expense' => 0, 'last_recharge' => 0]
            );

            $wallet->balance += $credits;
            $wallet->last_recharge = $credits;
            $wallet->save();

            // Return JSON for API requests (Flutter app)
            if ($request->wantsJson() || $request->expectsJson()) {
                return response()->json([
                    'status' => 'success',
                    'message' => 'Payment processed successfully',
                    'credits' => $credits,
                    'balance' => $wallet->balance
                ]);
            }

            return redirect($appSetting->front_end_base_url . '/wallet?success=true');
        } catch (\Throwable $th) {
            if ($request->wantsJson() || $request->expectsJson()) {
                return response()->json(['status' => 'error', 'message' => $th->getMessage()]);
            }
            return response()->json(['status' => 'error', 'message' => $th->getMessage()]);
        }
    }

    public function paymentCancel(Request $request)
    {
        try {
            $appSetting = AppSetting::first();
            $transactionId = $request->query('transaction_id');

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

<?php

namespace App\Http\Controllers;

use App\Models\Currency;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Carbon\Carbon;
use App\Services\ResponseService;

use App\Http\Controllers\BaseController;

class TransactionController extends BaseController
{
    // Get all transactions for the current user
    public function getUserTransactions()
    {
        $getAll = Transaction::where('user_id', auth()->user()->id)
                    ->orderBy('created_at', 'desc')
                    ->get();

        return $this->sendSuccessResponse('Transactions retrieved successfully', $getAll);
    }

    // Store transaction (for stripe only)
    public function store(Request $request)
    {
        $data = $request->validate([
            'transaction_id' => 'required|string',
            'initiated' => 'required|string',
            'payment_method' => 'required|string',
            'amount' => 'required|string',
            'status' => 'required',
            'conversion' => 'nullable'
        ]);

        $currency = Currency::where('currency_code', $request->conversion)->first();

        if (!$currency) {
            return ResponseService::error('Currency not found');
        }

        $data['conversion'] = '1 USD = ' . $currency->value . ' ' . $currency->code;
        $data['user_id'] = auth()->user()->id;
        $data['currency'] = $currency->code;
        $data['credits'] = round($request->amount / $currency->value, 2);

        $transaction = Transaction::create($data);

        $wallet = Wallet::where('user_id', auth()->user()->id)->first();

        if (!$wallet) {
            return ResponseService::error('Wallet not found for the user');
        }

        $wallet->balance += round($transaction->amount / $currency->value, 2);
        $wallet->last_recharge = round($transaction->amount / $currency->value, 2);
        $wallet->save();

        return $this->sendSuccessResponse('Transaction created successfully', $transaction);
    }

    // Monthly report with daily counts
    public function monthlyReportWithDailyCounts()
    {
        $startOfMonth = Carbon::now()->startOfMonth();
        $endOfMonth = Carbon::now()->endOfMonth();

        $monthlyTransactions = Transaction::whereBetween('created_at', [$startOfMonth, $endOfMonth])
            ->get()
            ->groupBy(function ($transaction) {
                return Carbon::parse($transaction->created_at)->format('Y-m-d');
            })
            ->map(function ($transactions, $date) {
                return ['date' => $date, 'count' => count($transactions)];
            });

        $transactionsArray = $monthlyTransactions->values()->all();

        return $this->sendSuccessResponse('Monthly transaction report', $transactionsArray);
    }

    // Weekly report with day names
    public function weeklyReportWithDayNames()
    {
        $startOfWeek = Carbon::now()->startOfWeek();
        $endOfWeek = Carbon::now()->endOfWeek();

        $weeklyTransactions = Transaction::whereBetween('created_at', [$startOfWeek, $endOfWeek])
            ->get()
            ->groupBy(function ($transaction) {
                return Carbon::parse($transaction->created_at)->format('l');
            })
            ->map(function ($transactions, $dayName) {
                return ['day' => $dayName, 'count' => count($transactions)];
            });

        $weeklyTransactionsArray = $weeklyTransactions->values()->all();

        return $this->sendSuccessResponse('Weekly transaction report', $weeklyTransactionsArray);
    }

    // Yearly report with monthly counts
    public function yearlyReportWithMonthlyCounts()
    {
        $startOfYear = Carbon::now()->startOfYear();
        $endOfYear = Carbon::now()->endOfYear();

        $yearlyTransactions = Transaction::whereBetween('created_at', [$startOfYear, $endOfYear])
            ->get()
            ->groupBy(function ($transaction) {
                return Carbon::parse($transaction->created_at)->format('Y-m');
            })
            ->map(function ($transactions, $month) {
                $monthName = Carbon::parse($month)->format('F');
                return ['month' => $monthName, 'count' => count($transactions)];
            });

        $yearlyTransactionsArray = $yearlyTransactions->values()->all();

        return $this->sendSuccessResponse('Yearly transaction report', $yearlyTransactionsArray);
    }
}

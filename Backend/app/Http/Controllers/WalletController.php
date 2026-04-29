<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Wallet;
use App\Services\ResponseService;

class WalletController extends Controller
{
    // Get wallet
    public function getWallet()
    {
        try {
            $wallet = Wallet::where('user_id', auth()->user()->id)->first();

            if (!$wallet) {
                return ResponseService::error('No wallet associated with this user');
            }

            return ResponseService::success('Data retrieved successfully', $wallet);
        } catch (\Throwable $th) {
            return ResponseService::error('Failed to retrieve wallet', $th->getMessage());
        }
    }
}

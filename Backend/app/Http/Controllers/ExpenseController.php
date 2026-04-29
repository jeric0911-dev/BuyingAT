<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Expense;
use App\Services\ResponseService;
use App\Http\Controllers\BaseController;

class ExpenseController extends BaseController
{
    // Get all expenses for the authenticated user
    public function index()
    {
        $expenses = Expense::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->get();

        return $this->sendSuccessResponse('Expenses retrieved successfully', $expenses);
    }
}

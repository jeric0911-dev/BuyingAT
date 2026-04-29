<?php

namespace App\Http\Controllers;

use App\Http\Controllers\BaseController;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;
use App\Models\Cart;
use App\Models\CardsCart;
use App\Models\Order;
use App\Models\CardRequest;
use App\Models\SellerInventory;
use App\Models\ProductStock;
use App\Models\Wallet;
use App\Models\Referral;
use App\Models\AffiliateCommission;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use App\Models\Product;
use Illuminate\Support\Facades\Mail;
use App\Mail\OrderPlacedEmail;
use App\Mail\OrderConfirmedEmail;
use App\Mail\OrderDeliveredEmail;
use App\Mail\OrderCancelledEmail;
use App\Models\User;
use App\Traits\MailConfigTrait;


class OrderController extends BaseController
{
    use MailConfigTrait;

    //create order from cart
    public function createOrderFromCart(Request $request)
    {
        try {
            $request->validate([
                'delivery_address' => 'required|string',
                'order_note' => 'nullable|string',
            ]);

            // Get both product cart items and card cart items
            $cartItems = Cart::with('product')->where('customer_id', auth()->id())->get();
            $cardCartItems = CardsCart::with('card')->where('customer_id', auth()->id())->get();

            if ($cartItems->isEmpty() && $cardCartItems->isEmpty()) {
                return $this->sendErrorResponse('Cart is empty', 404);
            }

            $orders = [];
            $userId = auth()->id();
            $orderIdsForEmail = []; // Store order IDs to send emails AFTER response

            // Process product cart items
            if (!$cartItems->isEmpty()) {
                $vendors = $cartItems->pluck('product.user_id')->unique();

                foreach ($vendors as $vendorId) {
                    $orderItems = [];
                    $totalAmount = 0;

                    foreach ($cartItems as $item) {
                        if ($item->product->user_id === $vendorId) {
                            $subtotal = $item->product->discounted_price * $item->quantity;
                            $totalAmount += $subtotal;

                            $productStock = ProductStock::where('sku', $item->sku)->first();

                            if (!$productStock) {
                                $product = Product::where('sku', $item->sku)->first();
                            }

                            $orderItems[] = [
                                'product_id' => $item->product_id,
                                'quantity' => $item->quantity,
                                'price' => $item->product->discounted_price ?? $product->price,
                                'sku' => $item->sku,
                                'size_id' => $productStock->size_id ?? null,
                                'color_id' => $productStock->color_id ?? null,
                                'variant_id' => $productStock->variant_id ?? null,
                            ];
                        }
                    }

                    $order = Order::create([
                        'order_id' => strtoupper(Str::random(8)),
                        'customer_id' => auth()->id(),
                        'vendor_id' => $vendorId,
                        'amount' => $totalAmount,
                        'delivery_address' => $request->delivery_address,
                        'payment_method' => 'cash',
                        'order_note' => $request->order_note,
                        'quantity' => $item->quantity
                    ]);

                    $order->orderedItems()->createMany($orderItems);

                    $order->orderStatus()->create([
                        'status' => 'placed',
                        'message' => 'Order placed and pending confirmation',
                    ]);

                    // Apply affiliate commissions (if any) for this order
                    $this->applyAffiliateCommissions($order);

                    // Store order ID for email sending AFTER response is sent (non-blocking)
                    $orderIdsForEmail[] = $order->order_id;
                    $orders[] = $order;
                }

                // Clear product cart
                Cart::where('customer_id', $userId)->delete();
            }

            // Optional: client-sent accepted/override totals (used for card bundles)
            $overrideTotal = 0;
            $overrideFields = [
                'override_total',
                'final_total',
                'accepted_total',
                'deal_total',
                'deal_price',
            ];
            foreach ($overrideFields as $field) {
                $val = $request->input($field);
                if (is_numeric($val) && (float)$val > 0) {
                    $overrideTotal = (float)$val;
                    break;
                }
            }

            // Process card cart items
            if (!$cardCartItems->isEmpty()) {
                $cardVendors = $cardCartItems->pluck('card.user_id')->unique();

                foreach ($cardVendors as $vendorId) {
                    $orderItems = [];
                    $totalAmount = 0;

                    foreach ($cardCartItems as $item) {
                        if ($item->card->user_id === $vendorId) {
                            $subtotal = $item->card->price; // Cards have fixed price, no quantity in cards_cart
                            $totalAmount += $subtotal;

                            $orderItems[] = [
                                'product_id' => $item->card_id, // Use card_id as product_id for cards
                                'quantity' => 1, // Cards are always quantity 1
                                'price' => $item->card->price,
                                'sku' => 'CARD-' . $item->card_id, // Use card_id for SKU
                                'size_id' => null,
                                'color_id' => null,
                                'variant_id' => null,
                            ];
                        }
                    }

                    // If client provided an accepted/override total and this is the only card vendor,
                    // honor that as the order amount; otherwise, use the computed total.
                    $effectiveAmount = $totalAmount;
                    if ($overrideTotal > 0 && $cardVendors->count() === 1) {
                        $effectiveAmount = $overrideTotal;
                    }

                    $order = Order::create([
                        'order_id' => strtoupper(Str::random(8)),
                        'customer_id' => auth()->id(),
                        'vendor_id' => $vendorId,
                        'amount' => $effectiveAmount,
                        'delivery_address' => $request->delivery_address,
                        'payment_method' => 'cash',
                        'order_note' => $request->order_note,
                        'quantity' => 1
                    ]);

                    $order->orderedItems()->createMany($orderItems);

                    $order->orderStatus()->create([
                        'status' => 'placed',
                        'message' => 'Order placed and pending confirmation',
                    ]);

                    // Apply affiliate commissions (if any) for this order
                    $this->applyAffiliateCommissions($order);

                    // Store order ID for email sending AFTER response is sent (non-blocking)
                    $orderIdsForEmail[] = $order->order_id;
                    $orders[] = $order;
                }

                // Clear card cart
                CardsCart::where('customer_id', $userId)->delete();
            }

            // Prepare response BEFORE sending emails
            $response = $this->sendSuccessResponse('Order created successfully', [
                'orders' => $orders,
            ]);

            // Send emails AFTER response is prepared (use fastcgi_finish_request for immediate response)
            if (!empty($orderIdsForEmail)) {
                // Use fastcgi_finish_request if available to send response immediately
                if (function_exists('fastcgi_finish_request')) {
                    // Send response to client immediately
                    fastcgi_finish_request();
                    
                    // Now send emails (client already received response)
                    try {
                        $user = User::find($userId);
                        if ($user) {
                            try {
                                $mailData = $this->getMailConfig();
                                if ($mailData) {
                                    foreach ($orderIdsForEmail as $orderId) {
                                        try {
                                            Mail::to($user->email)
                                                ->send((new OrderPlacedEmail($user->name, $orderId))
                                                    ->from($mailData['from_email'], $mailData['from_name'])
                                                );
                                        } catch (\Exception $mailError) {
                                            Log::error('Failed to send order email for order ' . $orderId . ': ' . $mailError->getMessage());
                                        }
                                    }
                                }
                            } catch (\Exception $configError) {
                                Log::error('Failed to get mail config: ' . $configError->getMessage());
                            }
                        }
                    } catch (\Exception $e) {
                        Log::error('Failed to send order emails: ' . $e->getMessage());
                    }
                } else {
                    // For non-FastCGI environments, emails will be skipped or sent synchronously
                    // In production, consider using Laravel queues for background email sending
                    Log::info('fastcgi_finish_request not available - skipping email sending during order creation');
                }
            }

            return $response;
        } catch (\Throwable $th) {
            Log::error('Failed to create order from cart: ' . $th->getMessage(), [
                'user_id' => auth()->id(),
                'trace' => $th->getTraceAsString(),
                'request_data' => $request->all()
            ]);
            return $this->sendErrorResponse('Failed to create order', $th->getMessage(), 500);
        }
    }

    //create order
    public function createOrder(Request $request)
    {
        try {
            // Check if user is authenticated
            if (!auth()->check()) {
                return $this->sendErrorResponse('Authentication required. Please log in to create an order.', null, 401);
            }

            Log::info('Creating order with request data: ', $request->all());

            // Determine if this is a product or card order based on the data
            $isCardOrder = $request->has('card_id');
            $isProductOrder = $request->has('product_id');

            if ($isCardOrder) {
                // Handle card order
                return $this->handleCardOrder($request);
            } elseif ($isProductOrder) {
                // Handle product order
                return $this->handleProductOrder($request);
            } else {
                return $this->sendErrorResponse('Invalid order data. Please provide either product_id or card_id.', null, 400);
            }
        } catch (\Throwable $th) {
            Log::error('Order creation failed: ' . $th->getMessage(), [
                'user_id' => auth()->id(),
                'request_data' => $request->all(),
                'trace' => $th->getTraceAsString()
            ]);
            
            return $this->sendErrorResponse('Failed to create order. Please try again or contact support if the problem persists.', $th->getMessage(), 500);
        }
    }

    // Handle card order
    private function handleCardOrder(Request $request)
    {
        // Custom validation with specific error messages for cards
        $validator = Validator::make($request->all(), [
            'delivery_address' => 'required|string|min:10|max:500',
            'order_note' => 'nullable|string|max:1000',
            'card_id' => 'required|integer|exists:seller_inventory,id',
            'amount' => 'required|numeric|min:0.01|max:999999.99',
        ], [
            'delivery_address.required' => 'Delivery address is required',
            'delivery_address.string' => 'Delivery address must be a valid text',
            'delivery_address.min' => 'Delivery address must be at least 10 characters long',
            'delivery_address.max' => 'Delivery address cannot exceed 500 characters',
            'order_note.string' => 'Order note must be a valid text',
            'order_note.max' => 'Order note cannot exceed 1000 characters',
            'card_id.required' => 'Card ID is required',
            'card_id.integer' => 'Card ID must be a valid number',
            'card_id.exists' => 'The selected card does not exist or is not available',
            'amount.required' => 'Amount is required',
            'amount.numeric' => 'Amount must be a valid number',
            'amount.min' => 'Amount must be at least $0.01',
            'amount.max' => 'Amount cannot exceed $999,999.99',
        ]);

        if ($validator->fails()) {
            return $this->sendValidationErrorResponse($validator);
        }

        $data = $validator->validated();
        Log::info('Creating card order with request data: ', $request->all());

        // Get the card from seller_inventory
        $card = SellerInventory::with('user')->find($data['card_id']);

        if (!$card) {
            return $this->sendErrorResponse('Card not found. The selected card may have been removed or does not exist.', 404);
        }

        // Check if user is trying to order their own card
        if (auth()->user()->id === $card->user_id) {
            return $this->sendErrorResponse('You cannot order your own card. Please select a different card.', 403);
        }

        // Check if card is approved
        $cardRequest = CardRequest::where('card_id', $card->id)
            ->where('request_status', 'approved')
            ->first();

        if (!$cardRequest) {
            return $this->sendErrorResponse('This card is not approved for sale yet. Please select an approved card.', 403);
        }

        // Additional validation: Check if amount matches card price (optional)
        if (abs($data['amount'] - $card->price) > 0.01) {
            return $this->sendErrorResponse('The amount does not match the card price. Please verify the correct amount.', 422);
        }

        // Create the order
        $order = Order::create([
            'order_id' => strtoupper(Str::random(8)),
            'customer_id' => auth()->id(),
            'vendor_id' => $card->user_id,
            'amount' => $data['amount'],
            'delivery_address' => $data['delivery_address'],
            'order_note' => $data['order_note'],
            'quantity' => 1, // Cards are always quantity 1
            'order_status' => 'pending',
            'payment_status' => 'pending',
        ]);

        // Create ordered item for the card
        $order->orderedItems()->create([
            'product_id' => $card->id, // Use card_id as product_id for cards
            'quantity' => 1,
            'price' => $data['amount'],
            'variant_id' => null,
            'color_id' => null,
            'size_id' => null,
            'sku' => $card->card_id ?? 'CARD-' . $card->id,
        ]);

        // Note: This is a direct order, not adding to cart

        $user = User::find(auth()->id());

        if (!$user) {
            return $this->sendErrorResponse('User account not found. Please log in again.', 404);
        }

        $mailData = $this->getMailConfig();

        Mail::to($user->email)
            ->send((new OrderPlacedEmail($user->name, $order->order_id))
                ->from($mailData['from_email'], $mailData['from_name'])
            );

        $order->orderStatus()->create([
            'status' => 'placed',
            'message' => 'Order placed and pending confirmation',
        ]);

        // Apply affiliate commissions (if any) for this order
        $this->applyAffiliateCommissions($order);

        return $this->sendSuccessResponse('Order created successfully', [
            'order' => $order,
        ]);
    }

    // Handle product order
    private function handleProductOrder(Request $request)
    {
        Log::info('Processing product order request:', $request->all());
        
        // Pre-validation check for amount and try to calculate if missing
        if (!$request->has('amount') || $request->amount === null || $request->amount === '') {
            // Try to calculate amount from product data
            $product = Product::find($request->product_id);
            if ($product) {
                $quantity = $request->quantity ?? 1;
                $calculatedAmount = $quantity * ($product->discounted_price ?? $product->price ?? 0);
                $request->merge(['amount' => $calculatedAmount]);
                Log::info('Calculated missing amount:', ['amount' => $calculatedAmount, 'quantity' => $quantity, 'price' => $product->discounted_price ?? $product->price]);
            } else {
                return $this->sendErrorResponse('Amount is required and cannot be calculated. Please provide a valid amount.', null, 422);
            }
        }
        
        // Custom validation with specific error messages for products
        $validator = Validator::make($request->all(), [
            'delivery_address' => 'required|string|min:10|max:500',
            'order_note' => 'nullable|string|max:1000',
            'product_id' => 'required|integer|exists:products,id',
            'vendor_id' => 'required|integer|exists:users,id',
            'sku' => 'required|string',
            'quantity' => 'required|integer|min:1|max:100',
            'amount' => 'required|numeric|min:0.01|max:999999.99',
        ], [
            'delivery_address.required' => 'Delivery address is required',
            'delivery_address.string' => 'Delivery address must be a valid text',
            'delivery_address.min' => 'Delivery address must be at least 10 characters long',
            'delivery_address.max' => 'Delivery address cannot exceed 500 characters',
            'order_note.string' => 'Order note must be a valid text',
            'order_note.max' => 'Order note cannot exceed 1000 characters',
            'product_id.required' => 'Product ID is required',
            'product_id.integer' => 'Product ID must be a valid number',
            'product_id.exists' => 'The selected product does not exist or is not available',
            'vendor_id.required' => 'Vendor ID is required',
            'vendor_id.integer' => 'Vendor ID must be a valid number',
            'vendor_id.exists' => 'The vendor does not exist',
            'sku.required' => 'SKU is required',
            'sku.string' => 'SKU must be a valid text',
            'quantity.required' => 'Quantity is required',
            'quantity.integer' => 'Quantity must be a valid number',
            'quantity.min' => 'Quantity must be at least 1',
            'quantity.max' => 'Quantity cannot exceed 100',
            'amount.required' => 'Amount is required',
            'amount.numeric' => 'Amount must be a valid number',
            'amount.min' => 'Amount must be at least $0.01',
            'amount.max' => 'Amount cannot exceed $999,999.99',
        ]);

        if ($validator->fails()) {
            Log::error('Product order validation failed:', [
                'errors' => $validator->errors()->toArray(),
                'request_data' => $request->all()
            ]);
            return $this->sendValidationErrorResponse($validator);
        }

        $data = $validator->validated();
        Log::info('Creating product order with request data: ', $request->all());

        // Get the product
        $product = Product::with('user')->find($data['product_id']);

        if (!$product) {
            Log::error('Product not found for order:', [
                'requested_product_id' => $data['product_id'],
                'available_products' => Product::pluck('id')->toArray()
            ]);
            return $this->sendErrorResponse('Product not found. The selected product may have been removed or does not exist. Please refresh the page and try again.', 404);
        }

        // Check if user is trying to order their own product
        if (auth()->user()->id === $product->user_id) {
            return $this->sendErrorResponse('You cannot order your own product. Please select a different product.', 403);
        }

        // Check if vendor_id matches product owner
        if ($data['vendor_id'] !== $product->user_id) {
            return $this->sendErrorResponse('Invalid vendor for this product.', 403);
        }

        // Create the order
        $order = Order::create([
            'order_id' => strtoupper(Str::random(8)),
            'customer_id' => auth()->id(),
            'vendor_id' => $data['vendor_id'],
            'amount' => $data['amount'],
            'delivery_address' => $data['delivery_address'],
            'order_note' => $data['order_note'],
            'quantity' => $data['quantity'],
            'order_status' => 'pending',
            'payment_status' => 'pending',
        ]);

        // Create ordered item for the product
        $order->orderedItems()->create([
            'product_id' => $data['product_id'],
            'quantity' => $data['quantity'],
            'price' => $data['amount'],
            'variant_id' => null,
            'color_id' => null,
            'size_id' => null,
            'sku' => $data['sku'],
        ]);

        $user = User::find(auth()->id());

        if (!$user) {
            return $this->sendErrorResponse('User account not found. Please log in again.', 404);
        }

        $mailData = $this->getMailConfig();

        Mail::to($user->email)
            ->send((new OrderPlacedEmail($user->name, $order->order_id))
                ->from($mailData['from_email'], $mailData['from_name'])
            );

        $order->orderStatus()->create([
            'status' => 'placed',
            'message' => 'Order placed and pending confirmation',
        ]);

        // Apply affiliate commissions (if any) for this order
        $this->applyAffiliateCommissions($order);

        return $this->sendSuccessResponse('Order created successfully', [
            'order' => $order,
        ]);
    }

    //get order list
    public function getVendorOrUserOrderList(Request $request)
    {
        $limit = $request->query('limit', 10);
        $orders = Order::with(['orderedItems.product.getGalleryImages'])
            ->where('vendor_id', auth()->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate($limit);

        if ($orders->isEmpty()) {
            return $this->sendErrorResponse('No orders found', 404);
        }

        return $this->sendPaginatedResponse('Order list retrieved successfully', $orders);
    }

    //get order list
    public function getUsersOwnOrderList(Request $request)
    {
        $limit = $request->query('limit', 10);
        $orders = Order::with(['orderedItems.product.getGalleryImages'])
            ->where('customer_id', auth()->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate($limit);

        if ($orders->isEmpty()) {
            return $this->sendErrorResponse('No orders found', 404);
        }

        return $this->sendPaginatedResponse('Order list retrieved successfully', $orders);
    }

    //get order list
    public function getUsersOwnOrderData(Request $request)
    {
        $totalOrders = Order::where('customer_id', auth()->user()->id)->count();
        $completedOrders = Order::where('customer_id', auth()->user()->id)
            ->where('order_status', 'completed')
            ->count();

        $pendingOrders = Order::where('customer_id', auth()->user()->id)
            ->where('order_status', 'pending')
            ->count();
        return $this->sendSuccessResponse('Order list retrieved successfully', [
            'total_orders' => $totalOrders,
            'completed_orders' => $completedOrders,
            'pending_orders' => $pendingOrders,
        ]);
    }

    //get order details
    public function getOrderDetails($orderId)
    {
        $order = Order::with(['orderedItems.product.getGalleryImages', 'orderedItems.color',
        'orderedItems.size',
        'orderedItems.variant', 'orderStatus'])
            ->where('id', $orderId)
            ->first();

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        $orderArray = $order->toArray();

        // Attach card details for ordered items that reference seller_inventory (card orders)
        if (isset($orderArray['ordered_items']) && is_array($orderArray['ordered_items'])) {
            foreach ($orderArray['ordered_items'] as $idx => $orderedItem) {
                $hasProduct = isset($orderedItem['product']) && !empty($orderedItem['product']);
                $isCardSku = isset($orderedItem['sku']) && is_string($orderedItem['sku']) && str_starts_with($orderedItem['sku'], 'CARD-');
                // For safety, attach card data if either there's no product OR the SKU indicates a card order
                if ((!$hasProduct || $isCardSku) && isset($orderedItem['product_id'])) {
                    $card = SellerInventory::find($orderedItem['product_id']);
                    if ($card) {
                        $orderArray['ordered_items'][$idx]['card'] = [
                            'id' => $card->id,
                            'card_title' => $card->card_title,
                            'price' => $card->price,
                            'images' => $card->images,
                            'grade' => $card->grade,
                            'condition' => $card->condition,
                            'sport_type' => $card->sport_type,
                        ];
                        // Optional: prevent frontend from accidentally using a product with the same ID
                        if ($isCardSku) {
                            $orderArray['ordered_items'][$idx]['product'] = null;
                        }
                    }
                }
            }
        }

        if (isset($orderArray['order_status']) && is_array($orderArray['order_status'])) {
            $orderArray['order_status_detail'] = $orderArray['order_status'];
            $orderArray['order_status'] = $order->getAttributes()['order_status'] ?? null;
        }

        return $this->sendSuccessResponse('Order details', $orderArray);
    }

    //cancel order
    public function cancelOrder($orderId)
    {
        $order = Order::with('orderedItems')->where('customer_id', auth()->user()->id)
            ->where('id', $orderId)
            ->first();

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        // Restore stock
        foreach ($order->orderedItems as $item) {
            $productStock = ProductStock::where('product_id', $item->product_id)
                ->where('variant_value', $item->product_variant)
                ->where('color_value', $item->product_color)
                ->where('size_value', $item->product_size)
                ->first();

            if ($productStock) {
                $productStock->increment('stock', $item->quantity);
            }
        }

        $order->update(['order_status' => 'cancelled']);

        return $this->sendSuccessResponse('Order cancelled successfully', $order);
    }

    //return order
    public function returnOrder($orderId)
    {
        $order = Order::with('orderedItems')->where('customer_id', auth()->user()->id)
            ->where('id', $orderId)
            ->first();

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        // Restore stock
        foreach ($order->orderedItems as $item) {
            $productStock = ProductStock::where('product_id', $item->product_id)
                ->where('variant_value', $item->product_variant)
                ->where('color_value', $item->product_color)
                ->where('size_value', $item->product_size)
                ->first();

            if ($productStock) {
                $productStock->increment('stock', $item->quantity);
            }
        }

        $order->update(['order_status' => 'returned']);

        return $this->sendSuccessResponse('Order returned successfully', $order);
    }

    //get order status
    public function getOrderStatus($orderId)
    {
        $order = Order::with(['orderedItems.product.images'])
            ->where('customer_id', auth()->user()->id)
            ->where('id', $orderId)
            ->first();

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        return $this->sendSuccessResponse('Order status', [
            'order_status' => $order->orderStatus,
        ]);
    }


    //update order status
    public function updateOrderStatus(Request $request, $orderId)
    {
        $request->validate([
            'order_status' => 'required|string'
        ]);

        $order = Order::find($orderId);

        $user = User::find($order->customer_id);

        if (!$user) {
            return $this->sendErrorResponse('Customer not found', 404);
        }

        // Mail config (fail-safe)
        $mailData = null;
        $fromEmail = null;
        $fromName = null;
        try {
            $mailData = $this->getMailConfig();
            if ($mailData) {
                $fromEmail = $mailData['from_email'] ?? null;
                $fromName = $mailData['from_name'] ?? null;
            }
        } catch (\Throwable $t) {
            \Log::warning('Mail config not available for order status update: '.$t->getMessage());
        }

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        $authUserId = auth()->user()->id;
        $isVendor = (int)$order->vendor_id === (int)$authUserId;
        $isCustomer = (int)$order->customer_id === (int)$authUserId;

        if (!$isVendor && !$isCustomer) {
            return $this->sendErrorResponse('Unauthorized action', 403);
        }

        $currentStatus = $order->order_status;
        $newStatus = $request->order_status;

        if (in_array($currentStatus, ['completed', 'cancelled', 'returned'])) {
            return $this->sendErrorResponse("Order is already {$currentStatus}. Status cannot be changed.", 400);
        }

        // Allowed transitions depend on who is performing the action
        if ($isVendor) {
            $allowedTransitions = [
                'pending' => ['processing', 'cancelled'],
                'processing' => ['completed'], // allow vendor to complete if needed
            ];
        } else { // customer (buyer)
            $allowedTransitions = [
                // Allow the buyer to start processing (move to On The Road) and then complete
                'pending' => ['processing'],
                'processing' => ['completed'],
            ];
        }

        if (!isset($allowedTransitions[$currentStatus]) || !in_array($newStatus, $allowedTransitions[$currentStatus])) {
            return $this->sendErrorResponse("Invalid status transition from {$currentStatus} to {$newStatus}.", 400);
        }

        if ($newStatus === 'processing') {

            foreach ($order->orderedItems as $item) {
                // Skip stock checks for card orders (SKU pattern: CARD-<id>)
                if (is_string($item->sku) && str_starts_with($item->sku, 'CARD-')) {
                    continue;
                }

                $stock = ProductStock::where('sku', $item->sku)->first();

                if ($stock) {
                    if ($stock->stock < $item->quantity) {
                        return $this->sendErrorResponse("Not enough stock in variant for SKU '{$item->sku}'.", 400);
                    }

                    $stock->stock -= $item->quantity;
                    $stock->save();
                } else {
                    $product = Product::where('sku', $item->sku)->first();

                    if (!$product) {
                        return $this->sendErrorResponse("Product not found for SKU '{$item->sku}'.", 404);
                    }

                    if ($product->stock < $item->quantity) {
                        return $this->sendErrorResponse("Not enough product stock for '{$product->product_title}'.", 400);
                    }

                    $product->stock -= $item->quantity;
                    $product->save();
                }
            }


            // Try sending confirmation email, but don't block status update
            try {
                if ($fromEmail && $fromName) {
                    Mail::to($user->email)
                        ->send((new OrderConfirmedEmail($user->name, $order->order_id))
                            ->from($fromEmail, $fromName)
                        );
                }
            } catch (\Throwable $t) {
                \Log::error('Failed to send order confirmed email: '.$t->getMessage());
            }


            if (!$order->orderStatus()->where('status', 'packaging')->exists()) {
                $order->orderStatus()->create([
                    'status' => 'packaging',
                    'message' => 'Order is being packaged',
                ]);
            }

            if (!$order->orderStatus()->where('status', 'on_the_way')->exists()) {
                $order->orderStatus()->create([
                    'status' => 'on_the_way',
                    'message' => 'Order is on the way',
                ]);
            }
        }

        if ($newStatus === 'completed') {

            try {
                if ($fromEmail && $fromName) {
                    Mail::to($user->email)
                    ->send((new OrderDeliveredEmail($user->name, $order->order_id))
                        ->from($fromEmail, $fromName)
                    );
                }
            } catch (\Throwable $t) {
                \Log::error('Failed to send order delivered email: '.$t->getMessage());
            }

            if (!$order->orderStatus()->where('status', 'delivered')->exists()) {
                $order->orderStatus()->create([
                    'status' => 'delivered',
                    'message' => 'Order has been delivered',
                ]);
            }
        }

        if ($newStatus === 'cancelled') {

            try {
                if ($fromEmail && $fromName) {
                    Mail::to($user->email)
                    ->send((new OrderCancelledEmail($user->name, $order->order_id))
                        ->from($fromEmail, $fromName)
                    );
                }
            } catch (\Throwable $t) {
                \Log::error('Failed to send order cancelled email: '.$t->getMessage());
            }
            $order->orderStatus()->create([
                'status' => 'cancelled',
                'message' => 'Order has been cancelled',
            ]);
        }

        $order->update(['order_status' => $newStatus]);

        return $this->sendSuccessResponse('Order status updated successfully.', $order);
    }


    //get order tracking
    public function getOrderTracking($orderId)
    {
        $order = Order::with(['orderedItems.product.getGalleryImages'])
            ->where('customer_id', auth()->user()->id)
            ->where('id', $orderId)
            ->first();

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        return $this->sendSuccessResponse('Order tracking', $order->orderStatus());
    }

    //update order tracking status
    public function updateOrderTracking(Request $request, $orderId)
    {
        $request->validate([
            'status' => 'required|string',
            'message' => 'nullable|string',
        ]);

        $order = Order::findOrFail($orderId);

        $order->orderStatus()->update([
            'status' => $request->status,
            'message' => $request->message ?? '',
        ]);

        return $this->sendSuccessResponse('Order tracking status updated successfully.', $order->orderStatus);
    }

    // Pay order using user's wallet
    public function payWithWallet($orderId)
    {
        try {
            $order = Order::find($orderId);
            if (!$order) {
                return $this->sendErrorResponse('Order not found', 404);
            }

            // Only the customer can pay
            if ((int)$order->customer_id !== (int)auth()->id()) {
                return $this->sendErrorResponse('Unauthorized action', 403);
            }

            if ($order->payment_status === 'paid') {
                return $this->sendSuccessResponse('Order already paid', $order);
            }

            $wallet = Wallet::where('user_id', auth()->id())->first();
            if (!$wallet) {
                return $this->sendErrorResponse('Your balance is not enough. Please recharge it.');
            }

            $amount = (float)$order->amount;
            if ((float)$wallet->balance < $amount) {
                return $this->sendErrorResponse('Insufficient wallet balance');
            }

            // Deduct and mark paid
            $wallet->balance = (float)$wallet->balance - $amount;
            $wallet->expense = (float)$wallet->expense + $amount;
            $wallet->save();

            $order->payment_status = 'paid';
            // Record a simple reference for auditing
            $order->transaction_reference = 'wallet:'.now()->timestamp;
            // Auto-advance order status on successful payment
            if ($order->order_status === 'pending') {
                $order->order_status = 'processing';
            }
            $order->save();

            // Note: affiliate commissions are attached at order creation time.
            // If you prefer to only award commissions after payment, you could
            // move the commission calculation logic here instead.

            // Add tracking milestones similar to processing transition (non-blocking)
            try {
                if (!$order->orderStatus()->where('status', 'packaging')->exists()) {
                    $order->orderStatus()->create([
                        'status' => 'packaging',
                        'message' => 'Order is being packaged',
                    ]);
                }
                if (!$order->orderStatus()->where('status', 'on_the_way')->exists()) {
                    $order->orderStatus()->create([
                        'status' => 'on_the_way',
                        'message' => 'Order is on the way',
                    ]);
                }
            } catch (\Throwable $t) {
                \Log::warning('Failed to append tracking after wallet payment: '.$t->getMessage());
            }

            return $this->sendSuccessResponse('Payment successful', $order);
        } catch (\Throwable $th) {
            return $this->sendErrorResponse('Failed to pay with wallet', $th->getMessage(), 500);
        }
    }

    /**
     * Apply affiliate commissions for a given order based on referral relationships.
     *
     * Rules:
     * - If the customer was referred by an affiliate, that referrer earns commission on this order.
     * - If the vendor was referred by an affiliate, that referrer also earns commission on this order.
     * - Commission rate is taken from the referrer's `commission_rate` field (e.g. 0.01 for 1%).
     */
    private function applyAffiliateCommissions(Order $order): void
    {
        try {
            $amount = (float) $order->amount;
            if ($amount <= 0) {
                return;
            }

            $participants = [];

            // Check if customer has a referrer
            if (!empty($order->customer_id)) {
                $customerReferral = Referral::with('referrer')
                    ->where('referred_user_id', $order->customer_id)
                    ->first();

                if ($customerReferral && $customerReferral->referrer) {
                    $participants[] = [
                        'referrer' => $customerReferral->referrer,
                        'referred_user_id' => $order->customer_id,
                    ];
                }
            }

            // Check if vendor has a referrer
            if (!empty($order->vendor_id)) {
                $vendorReferral = Referral::with('referrer')
                    ->where('referred_user_id', $order->vendor_id)
                    ->first();

                if ($vendorReferral && $vendorReferral->referrer) {
                    $participants[] = [
                        'referrer' => $vendorReferral->referrer,
                        'referred_user_id' => $order->vendor_id,
                    ];
                }
            }

            foreach ($participants as $participant) {
                $referrer = $participant['referrer'];
                $referredUserId = $participant['referred_user_id'];

                // Only apply commission if referrer is enabled as affiliate and has a positive rate
                $isAffiliate = (bool)($referrer->is_affiliate ?? false);
                $rate = (float)($referrer->commission_rate ?? 0);

                if (!$isAffiliate || $rate <= 0) {
                    continue;
                }

                $commissionAmount = $amount * $rate;
                if ($commissionAmount <= 0) {
                    continue;
                }

                AffiliateCommission::create([
                    'referrer_id' => $referrer->id,
                    'referred_user_id' => $referredUserId,
                    'order_id' => $order->id,
                    'amount' => $commissionAmount,
                    'status' => 'pending',
                ]);
            }
        } catch (\Throwable $e) {
            Log::warning('Failed to apply affiliate commissions: ' . $e->getMessage(), [
                'order_id' => $order->id ?? null,
            ]);
        }
    }

    //get order delivery status
    public function getOrderDeliveryStatus($orderId)
    {
        $order = Order::with(['orderedItems.product.images'])
            ->where('customer_id', auth()->user()->id)
            ->where('id', $orderId)
            ->first();

        if (!$order) {
            return $this->sendErrorResponse('Order not found', 404);
        }

        return $this->sendSuccessResponse('Order delivery status', [
            'delivery_status' => $order->deliveryStatus,
        ]);
    }

    //ORDER LIST
    public function upcomingOrderList()
    {

        $orders = Order::with(['orderedItems.product.images'])
            ->where('customer_id', auth()->user()->id)
            ->get();

        return $this->sendSuccessResponse('Order list', $orders);
    }

    //order history
    public function orderHistory(Request $request)
    {
        // require page number
        $validator = Validator::make($request->all(), [
            'page' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->sendValidationErrorResponse($validator);
        }

        $limit = 10;

        $offset = ($request->page - 1) * $limit;

        $orders = Order::with(['orderedItems.product.images'])
            ->where('customer_id', auth()->user()->id)
            ->offset($offset)
            ->limit($limit)
            ->get();

        return $this->sendSuccessResponse('Order list', [
            'orders' => $orders,
        ]);
    }
}

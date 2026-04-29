<?php

namespace App\Http\Controllers;

use App\Http\Controllers\BaseController;
use App\Models\Cart;
use App\Models\Product;
use App\Models\ProductStock;
use App\Models\CardsCart;
use App\Models\SellerInventory;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class CartController extends BaseController
{
    public function addProductToCart(Request $request)
    {
        try {
            $data = $request->validate([
                'product_id' => 'required',
                'quantity' => 'required|integer|min:1',
                'vendor_id' => 'required|exists:users,id',
                'sku' => 'nullable|string',
                'is_card' => 'nullable|boolean',
            ]);

            $user = Auth::user();
            $isCard = $request->has('is_card') ? $request->is_card : false;

            // Check if it's a card or product by checking which table the ID exists in
            if (!$isCard) {
                // Check if product_id exists in products table
                $product = Product::find($data['product_id']);
                if ($product) {
                    // It's a product - use regular Cart table
                    $existingCartItem = Cart::where('customer_id', $user->id)
                ->where('product_id', $data['product_id'])
                ->where('vendor_id', $data['vendor_id'])
                ->first();

            if ($existingCartItem) {
                $existingCartItem->quantity += $data['quantity'];
                $existingCartItem->save();
            } else {
                Cart::create([
                            'customer_id' => $user->id,
                    'product_id' => $data['product_id'],
                    'vendor_id' => $data['vendor_id'],
                    'quantity' => $data['quantity'],
                    'sku' => $data['sku'] ?? $product->sku,
                ]);
            }

            return ResponseService::success('Product added to cart successfully');
                }
            }

            // If not found in products, or is_card flag is set, check if it's a card
            $card = SellerInventory::find($data['product_id']);
            if ($card) {
                // It's a card - use CardsCart table
                // Check if card already exists in cart
                $existingCardCartItem = CardsCart::where('customer_id', $user->id)
                    ->where('card_id', $data['product_id'])
                    ->first();

                if ($existingCardCartItem) {
                    // Card already in cart, return error to prevent duplicate
                    return ResponseService::error('This card is already in your cart', null, 400);
                } else {
                    CardsCart::create([
                        'customer_id' => $user->id,
                        'card_id' => $data['product_id'],
                    ]);

                    return ResponseService::success('Card added to cart successfully');
                }
            }

            // If neither product nor card found
            return ResponseService::error('Product or card not found', null, 404);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to add product to cart', $e->getMessage());
        }
    }

    public function cartItems()
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return ResponseService::error('User not authenticated', null, 401);
            }

            $cartItems = Cart::with('product.getGalleryImages')
                ->where('customer_id', $user->id)
                ->get();
            
            // Also get card cart items with seller_inventory relationship
            $cardCartItems = CardsCart::with('card')
                ->where('customer_id', $user->id)
                ->get();

            // Combine products and cards into a single array for frontend
            $allItems = [];
            
            // Add products with itemType flag
            foreach ($cartItems as $item) {
                $allItems[] = array_merge($item->toArray(), [
                    'itemType' => 'product'
                ]);
            }
            
            // Add cards with itemType flag and formatted data
            foreach ($cardCartItems as $item) {
                $card = $item->card; // This is the SellerInventory model
                $allItems[] = [
                    'id' => $item->id,
                    'card_id' => $item->card_id,
                    'card' => $card ? [
                        'id' => $card->id,
                        'card_title' => $card->card_title,
                        'price' => $card->price,
                        'images' => $card->images,
                        'grade' => $card->grade,
                        'condition' => $card->condition,
                        'sport_type' => $card->sport_type,
                    ] : null,
                    'itemType' => 'card',
                    'quantity' => 1, // Cards always have quantity 1
                ];
            }

            return ResponseService::success('Cart items retrieved successfully', [
                'products' => $cartItems->toArray(),
                'cards' => $cardCartItems->toArray(),
                'items' => $allItems, // Combined array for frontend
                'total_count' => $cartItems->count() + $cardCartItems->count()
            ]);
        } catch (\Exception $e) {
            \Log::error('Cart items error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            return ResponseService::error('Failed to retrieve cart items', $e->getMessage(), 500);
        }
    }

    public function removeCartItem(Request $request)
    {
        try {
            $data = $request->validate([
                'cart_item_id' => 'required',
                'item_type' => 'nullable|in:product,card',
            ]);

            $user = Auth::user();
            $itemType = $request->input('item_type', 'product');
            
            if ($itemType === 'card') {
                // Remove card from CardsCart
                $cardCartItem = CardsCart::where('id', $data['cart_item_id'])
                    ->where('customer_id', $user->id)
                    ->first();

                if (!$cardCartItem) {
                    return ResponseService::error('Card cart item not found', null, 404);
                }

                $cardCartItem->delete();
            } else {
                // Remove product from Cart
            $cartItem = Cart::where('id', $data['cart_item_id'])
                    ->where('customer_id', $user->id)
                ->first();

            if (!$cartItem) {
                return ResponseService::error('Cart item not found', null, 404);
            }

            $cartItem->delete();
            }

            return ResponseService::success('Cart item removed successfully');
        } catch (\Exception $e) {
            return ResponseService::error('Failed to remove cart item', $e->getMessage());
        }
    }

    public function clearCart()
    {
        try {
            $user = Auth::user();
            Cart::where('customer_id', $user->id)->delete();
            // Also clear card cart items
            CardsCart::where('customer_id', $user->id)->delete();

            return ResponseService::success('Cart cleared successfully');
        } catch (\Exception $e) {
            return ResponseService::error('Failed to clear cart', $e->getMessage());
        }
    }

    public function getCartDetails()
    {
        try {
            $user = Auth::user();
            $cartItems = Cart::with('product')
                ->where('customer_id', $user->id)
                ->get();
            
            // Also get card cart items
            $cardCartItems = CardsCart::with('card')
                ->where('customer_id', $user->id)
                ->get();

            // Calculate subtotal for products
            $productSubTotal = $cartItems->sum(function ($item) {
                return $item->quantity * ($item->product->price ?? 0);
            });

            // Calculate subtotal for cards (cards are always quantity 1)
            $cardSubTotal = $cardCartItems->sum(function ($item) {
                return $item->card->price ?? 0;
            });
            
            $subTotal = $productSubTotal + $cardSubTotal;

            $platformFee = $subTotal * 0.04; // 4% platform fee for buyer
            $tax = $subTotal * 0.1; // 10% tax
            $totalPrice = $subTotal + $platformFee + $tax;

            $cartDetails = [
                'sub_total' => $subTotal,
                'platform_fee' => $platformFee,
                'tax' => $tax,
                'total_price' => $totalPrice,
            ];

            return ResponseService::success('Cart details retrieved successfully', $cartDetails);
        } catch (\Exception $e) {
            return ResponseService::error('Failed to retrieve cart details', $e->getMessage());
        }
    }

    public function increaseCartItemQuantity(Request $request)
    {
        try {
            $data = $request->validate([
                'cart_item_id' => 'required|exists:carts,id',
            ]);

            $user = Auth::user();
            $cartItem = Cart::where('id', $data['cart_item_id'])
                ->where('customer_id', $user->id)
                ->first();

            if (!$cartItem) {
                return ResponseService::error('Cart item not found', null, 404);
            }

            $cartItem->quantity += 1;
            $cartItem->save();

            return ResponseService::success('Cart item quantity increased successfully');
        } catch (\Exception $e) {
            return ResponseService::error('Failed to increase cart item quantity', $e->getMessage());
        }
    }

    public function decreaseCartItemQuantity(Request $request)
    {
        try {
            $data = $request->validate([
                'cart_item_id' => 'required|exists:carts,id',
            ]);

            $user = Auth::user();
            $cartItem = Cart::where('id', $data['cart_item_id'])
                ->where('customer_id', $user->id)
                ->first();

            if (!$cartItem) {
                return ResponseService::error('Cart item not found', null, 404);
            }

            if ($cartItem->quantity > 1) {
                $cartItem->quantity -= 1;
                $cartItem->save();
            } else {
                $cartItem->delete();
            }

            return ResponseService::success('Cart item quantity decreased successfully');
        } catch (\Exception $e) {
            return ResponseService::error('Failed to decrease cart item quantity', $e->getMessage());
        }
    }

    public function applyCoupon(Request $request)
    {
        try {
            $data = $request->validate([
                'coupon_code' => 'required|string',
            ]);

            // Implement coupon logic here
            return ResponseService::success('Coupon applied successfully');
        } catch (\Exception $e) {
            return ResponseService::error('Failed to apply coupon', $e->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SellerInventory;
use App\Models\CardRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class SellerInventoryController extends Controller
{
    /**
     * Store a newly created inventory item.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'card_title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'price_type' => 'required|in:FIRM,OBO',
            'condition' => 'nullable|string|max:50',
            'grade' => 'nullable|in:Yes,No',
            'sport_type' => 'nullable|string|max:50',
            'weight' => 'nullable|numeric|min:0',
            'images' => 'nullable|array|max:6',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $user = Auth::user();
            
            // Handle image uploads
            $imagePaths = [];
            if ($request->hasFile('images')) {
                foreach ($request->file('images') as $image) {
                    $path = $image->store('seller_inventory', 'public');
                    $imagePaths[] = $path;
                }
            }

            // Create inventory item (CardRequest will be created automatically via Eloquent event)
            $inventoryItem = SellerInventory::create([
                'user_id' => $user->id,
                'card_title' => $request->card_title,
                'description' => $request->description,
                'price' => $request->price,
                'price_type' => $request->price_type,
                'condition' => $request->condition,
                'grade' => $request->grade,
                'sport_type' => $request->sport_type,
                'weight' => $request->weight,
                'images' => $imagePaths,
                'is_promoted' => false
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Card added successfully and request created',
                'data' => [
                    'inventory_item' => $inventoryItem
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to add card',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get inventory items for authenticated user.
     */
    public function index(Request $request)
    {
        try {
            $user = Auth::user();
            $query = SellerInventory::where('user_id', $user->id)
                ->with('cardRequests')
                ->orderBy('created_at', 'desc');

            // Apply status filter if provided (skip if status is 'all')
            if ($request->has('status') && $request->input('status') !== 'all') {
                $status = $request->input('status');
                $query->whereHas('cardRequests', function ($q) use ($status) {
                    $q->where('request_status', $status);
                });
            }

            // Apply search filter if provided
            if ($request->has('search')) {
                $search = $request->input('search');
                $query->where('card_title', 'like', '%' . $search . '%');
            }

            $inventoryItems = $query->get();

            // Add request status to each inventory item
            $inventoryItems->each(function ($item) {
                $latestRequest = $item->cardRequests->sortByDesc('created_at')->first();
                $item->request_status = $latestRequest ? $latestRequest->request_status : 'pending';
                $item->request_id = $latestRequest ? $latestRequest->id : null;
            });

            return response()->json([
                'status' => 'success',
                'data' => $inventoryItems
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch inventory items',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get a specific inventory item.
     */
    public function show($id)
    {
        try {
            $user = Auth::user();
            $inventoryItem = SellerInventory::where('user_id', $user->id)
                ->where('id', $id)
                ->first();

            if (!$inventoryItem) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Inventory item not found'
                ], 404);
            }

            return response()->json([
                'status' => 'success',
                'data' => $inventoryItem
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch inventory item',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update an inventory item.
     */
    public function update(Request $request, $id)
    {
        \Log::info('Update method called for ID: ' . $id);
        
        // Debug: Log what we're receiving
        \Log::info('Update request data:', [
            'all_data' => $request->all(),
            'card_title' => $request->card_title,
            'description' => $request->description,
            'price' => $request->price,
            'condition' => $request->condition,
            'grade' => $request->grade,
            'sport_type' => $request->sport_type,
            'weight' => $request->weight,
            'has_images' => $request->hasFile('images'),
            'images_count' => $request->hasFile('images') ? count($request->file('images')) : 0,
            'method' => $request->method(),
            'content_type' => $request->header('Content-Type'),
            'is_json' => $request->isJson(),
            'is_form_data' => $request->hasFile('images')
        ]);

        $validator = Validator::make($request->all(), [
            'card_title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'price_type' => 'required|in:FIRM,OBO',
            'condition' => 'nullable|string|max:50',
            'grade' => 'nullable|in:Yes,No',
            'sport_type' => 'nullable|string|max:50',
            'weight' => 'nullable|numeric|min:0',
            'images' => 'nullable|array|max:6',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        \Log::info('Validation passed successfully for update method');

        try {
            $user = Auth::user();
            $inventoryItem = SellerInventory::where('user_id', $user->id)
                ->where('id', $id)
                ->first();

            if (!$inventoryItem) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Inventory item not found'
                ], 404);
            }

            // Handle image uploads
            $imagePaths = $inventoryItem->images ?? [];
            \Log::info('Current images count: ' . count($imagePaths));
            
            if ($request->hasFile('images') && count($request->file('images')) > 0) {
                \Log::info('New images count: ' . count($request->file('images')));
                
                // Upload new images and append to existing ones
                foreach ($request->file('images') as $image) {
                    $path = $image->store('seller_inventory', 'public');
                    $imagePaths[] = $path;
                }
                
                \Log::info('Total images after upload: ' . count($imagePaths));
                
                // Check if total images exceed limit (max 6)
                if (count($imagePaths) > 6) {
                    \Log::info('Exceeding image limit, removing oldest images');
                    // Remove oldest images if we exceed the limit
                    $excessCount = count($imagePaths) - 6;
                    for ($i = 0; $i < $excessCount; $i++) {
                        $oldImage = array_shift($imagePaths);
                        Storage::disk('public')->delete($oldImage);
                    }
                    \Log::info('Final images count: ' . count($imagePaths));
                }
            }

            // Debug: Log values before update
            \Log::info('Values being updated:', [
                'grade' => $request->grade,
                'grade_type' => gettype($request->grade),
                'grade_empty' => empty($request->grade),
                'grade_null' => is_null($request->grade)
            ]);

            // Update inventory item
            $updateData = [
                'card_title' => $request->card_title,
                'description' => $request->description,
                'price' => $request->price,
                'price_type' => $request->price_type,
                'condition' => $request->condition,
                'grade' => $request->grade,
                'sport_type' => $request->sport_type,
                'weight' => $request->weight,
                'images' => $imagePaths
            ];
            
            $inventoryItem->update($updateData);

            return response()->json([
                'status' => 'success',
                'message' => 'Card updated successfully',
                'data' => $inventoryItem
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update card',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete an inventory item.
     */
    public function destroy($id)
    {
        try {
            $user = Auth::user();
            $inventoryItem = SellerInventory::where('user_id', $user->id)
                ->where('id', $id)
                ->first();

            if (!$inventoryItem) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Inventory item not found'
                ], 404);
            }

            // Delete associated images
            if ($inventoryItem->images) {
                foreach ($inventoryItem->images as $image) {
                    Storage::disk('public')->delete($image);
                }
            }

            $inventoryItem->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Card deleted successfully'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to delete card',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

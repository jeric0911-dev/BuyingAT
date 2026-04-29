<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BuyerProfile;
use App\Models\BuyerTag;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class BuyerProfileController extends Controller
{
    /**
     * Store a newly created buyer profile.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'categories' => 'array',
            'preferences' => 'string|nullable',
            'budget_min' => 'numeric|nullable|min:0',
            'budget_max' => 'numeric|nullable|min:0|gte:budget_min',
            'profile_link' => 'url|nullable',
            'tags' => 'array',
            'tags.*.tag_name' => 'required|string',
            'tags.*.tag_type' => 'string|nullable',
            'tags.*.card_condition' => 'string|nullable',
            'tags.*.purchase_volume' => 'integer|nullable|min:0',
            'tags.*.budget_tier' => 'string|nullable'
        ]);

        if ($validator->fails()) {
            \Log::error('Buyer Profile Validation Failed:', [
                'errors' => $validator->errors()->toArray(),
                'request_data' => $request->all()
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $user = Auth::user();
            
            // Debug: Log the incoming request data
            \Log::info('Buyer Profile Creation Request:', [
                'user_id' => $user->id,
                'request_data' => $request->all(),
                'tags_data' => $request->tags
            ]);
            
            // Check if user already has a buyer profile
            $existingProfile = BuyerProfile::where('user_id', $user->id)->first();
            
            if ($existingProfile) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Buyer profile already exists for this user'
                ], 409);
            }

            // Create buyer profile
            $buyerProfile = BuyerProfile::create([
                'user_id' => $user->id,
                'categories' => $request->categories ?? [],
                'preferences' => $request->preferences,
                'budget_min' => $request->budget_min,
                'budget_max' => $request->budget_max,
                'profile_link' => $request->profile_link,
                'is_verified_buyer' => false,
                'is_exempt' => false
            ]);

            // Create buyer tags if provided
            if ($request->has('tags') && is_array($request->tags)) {
                \Log::info('Creating buyer tags:', [
                    'tags_count' => count($request->tags),
                    'tags_data' => $request->tags
                ]);
                
                foreach ($request->tags as $tagData) {
                    try {
                        $tag = BuyerTag::create([
                            'buyer_profile_id' => $buyerProfile->id,
                            'tag_name' => $tagData['tag_name'],
                            'tag_type' => $tagData['tag_type'] ?? null,
                            'card_condition' => $tagData['card_condition'] ?? null,
                            'purchase_volume' => $tagData['purchase_volume'] ?? null,
                            'budget_tier' => $tagData['budget_tier'] ?? null
                        ]);
                        
                        \Log::info('Created buyer tag:', $tag->toArray());
                    } catch (\Exception $e) {
                        \Log::error('Failed to create buyer tag:', [
                            'error' => $e->getMessage(),
                            'tag_data' => $tagData,
                            'buyer_profile_id' => $buyerProfile->id
                        ]);
                    }
                }
            } else {
                \Log::info('No tags provided or tags is not an array:', [
                    'has_tags' => $request->has('tags'),
                    'tags_is_array' => is_array($request->tags),
                    'tags_value' => $request->tags
                ]);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Buyer profile created successfully',
                'data' => $buyerProfile->load('buyerTags')
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create buyer profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get buyer profile for authenticated user.
     */
    public function show()
    {
        try {
            $user = Auth::user();
            $buyerProfile = BuyerProfile::with('buyerTags')->where('user_id', $user->id)->first();

            if (!$buyerProfile) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Buyer profile not found'
                ], 404);
            }

            return response()->json([
                'status' => 'success',
                'data' => $buyerProfile
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch buyer profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update buyer profile for authenticated user.
     */
    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'categories' => 'array',
            'preferences' => 'string|nullable',
            'budget_min' => 'numeric|nullable|min:0',
            'budget_max' => 'numeric|nullable|min:0|gte:budget_min',
            'profile_link' => 'url|nullable',
            'tags' => 'array',
            'tags.*.tag_name' => 'required|string',
            'tags.*.tag_type' => 'string|nullable',
            'tags.*.card_condition' => 'string|nullable',
            'tags.*.purchase_volume' => 'integer|nullable|min:0',
            'tags.*.budget_tier' => 'string|nullable'
        ]);

        if ($validator->fails()) {
            \Log::error('Buyer Profile Validation Failed:', [
                'errors' => $validator->errors()->toArray(),
                'request_data' => $request->all()
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $user = Auth::user();
            $buyerProfile = BuyerProfile::where('user_id', $user->id)->first();

            if (!$buyerProfile) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Buyer profile not found'
                ], 404);
            }

            // Update buyer profile
            $buyerProfile->update([
                'categories' => $request->categories ?? $buyerProfile->categories,
                'preferences' => $request->preferences ?? $buyerProfile->preferences,
                'budget_min' => $request->budget_min ?? $buyerProfile->budget_min,
                'budget_max' => $request->budget_max ?? $buyerProfile->budget_max,
                'profile_link' => $request->profile_link ?? $buyerProfile->profile_link
            ]);

            // Update buyer tags if provided
            if ($request->has('tags') && is_array($request->tags)) {
                // Delete existing tags
                $buyerProfile->buyerTags()->delete();
                
                // Create new tags
                foreach ($request->tags as $tagData) {
                    BuyerTag::create([
                        'buyer_profile_id' => $buyerProfile->id,
                        'tag_name' => $tagData['tag_name'],
                        'tag_type' => $tagData['tag_type'] ?? null,
                        'card_grade' => $tagData['card_grade'] ?? null,
                        'purchase_volume' => $tagData['purchase_volume'] ?? null,
                        'budget_tier' => $tagData['budget_tier'] ?? null
                    ]);
                }
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Buyer profile updated successfully',
                'data' => $buyerProfile->load('buyerTags')
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update buyer profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all buyer profiles for public viewing.
     */
    public function index()
    {
        try {
            // Debug: Log all buyer profiles first
            $allBuyerProfiles = BuyerProfile::with(['user.profile', 'buyerTags'])->get();
            \Log::info('All buyer profiles in database:', [
                'count' => $allBuyerProfiles->count(),
                'profiles' => $allBuyerProfiles->toArray()
            ]);

            $buyerProfiles = BuyerProfile::with(['user.profile', 'buyerTags'])
                ->orderBy('created_at', 'desc')
                ->get();

            \Log::info('Buyer profiles to return:', [
                'count' => $buyerProfiles->count(),
                'profiles' => $buyerProfiles->toArray()
            ]);

            return response()->json([
                'status' => 'success',
                'data' => $buyerProfiles
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch buyer profiles',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get a specific buyer profile by ID for public viewing.
     */
    public function showById($id)
    {
        try {
            \Log::info('Fetching buyer profile by ID:', ['id' => $id]);
            
            $buyerProfile = BuyerProfile::with(['user.profile', 'buyerTags'])
                ->where('id', $id)
                ->first();

            \Log::info('Buyer profile found:', [
                'exists' => $buyerProfile ? true : false,
                'profile_data' => $buyerProfile ? $buyerProfile->toArray() : null
            ]);

            if (!$buyerProfile) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Buyer profile not found'
                ], 404);
            }

            return response()->json([
                'status' => 'success',
                'data' => $buyerProfile
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch buyer profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get buyer's interested cards for deal building
     */
    public function getBuyerInterests($buyerId, Request $request)
    {
        try {
            $search = $request->get('search', '');
            
            // Get buyer profile with tags
            $buyerProfile = BuyerProfile::with('buyerTags')
                ->where('user_id', $buyerId)
                ->first();

            if (!$buyerProfile) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Buyer profile not found',
                    'data' => []
                ], 404);
            }

            // Get interested card types from buyer tags
            $interestedTypes = $buyerProfile->buyerTags->pluck('tag_name')->toArray();
            
            if (empty($interestedTypes)) {
                return response()->json([
                    'status' => 'success',
                    'data' => []
                ], 200);
            }

            // Search for cards that match buyer interests
            $query = \App\Models\CardRequest::with('sellerInventory.user')
                ->where('request_status', 'approved')
                ->whereHas('sellerInventory', function ($q) use ($interestedTypes, $search) {
                    $q->where(function ($subQuery) use ($interestedTypes) {
                        foreach ($interestedTypes as $type) {
                            $subQuery->orWhere('card_title', 'like', '%' . $type . '%')
                                   ->orWhere('sport_type', 'like', '%' . $type . '%');
                        }
                    });
                    
                    if ($search) {
                        $subQuery->where(function ($searchQuery) use ($search) {
                            $searchQuery->where('card_title', 'like', '%' . $search . '%')
                                      ->orWhere('description', 'like', '%' . $search . '%');
                        });
                    }
                });

            $cards = $query->limit(50)->get();

            // Transform the data for frontend
            $transformedData = $cards->map(function ($request) {
                $inventory = $request->sellerInventory;
                return [
                    'id' => $request->id,
                    'title' => $inventory->card_title,
                    'price' => $inventory->price,
                    'image' => $inventory->images && count($inventory->images) > 0 
                        ? env('APP_URL') . '/storage/' . $inventory->images[0] 
                        : null,
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $transformedData
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch buyer interests',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}

<?php

namespace App\Http\Controllers;

use App\Http\Controllers\BaseController;
use App\Models\UserProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use App\Traits\ImageTrait;

class UserProfileController extends BaseController
{
    use ImageTrait;

    /**
     * Get user profile
     */
    public function show()
    {
        try {
            Log::info('🔍 UserProfileController: Getting user profile', [
                'user_id' => Auth::id(),
                'timestamp' => now()
            ]);

            $user = Auth::user();
            if (!$user) {
                Log::warning('❌ UserProfileController: No authenticated user found');
                return $this->sendErrorResponse('User not authenticated', 401);
            }

            $profile = UserProfile::where('user_id', $user->id)->first();
            
            Log::info('📊 UserProfileController: Profile query result', [
                'user_id' => $user->id,
                'profile_exists' => $profile ? true : false,
                'profile_id' => $profile?->id,
                'username' => $profile?->username
            ]);

            if (!$profile) {
                Log::info('ℹ️ UserProfileController: No profile found, returning empty data');
                return $this->sendSuccessResponse('No profile found', null);
            }

            Log::info('✅ UserProfileController: Profile retrieved successfully', [
                'profile_id' => $profile->id,
                'username' => $profile->username,
                'has_avatar' => !empty($profile->avatar),
                'has_bio' => !empty($profile->bio)
            ]);

            return $this->sendSuccessResponse('Profile retrieved successfully', $profile);
        } catch (\Exception $e) {
            Log::error('💥 UserProfileController: Error getting profile', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return $this->sendErrorResponse('Failed to get profile', 500);
        }
    }

    /**
     * Create or update user profile
     */
    public function storeOrUpdate(Request $request)
    {
        try {
            Log::info('🔄 UserProfileController: Starting profile create/update', [
                'user_id' => Auth::id(),
                'request_data' => [
                    'username' => $request->input('username'),
                    'bio' => $request->input('bio'),
                    'has_avatar' => $request->hasFile('avatar'),
                    'avatar_size' => $request->hasFile('avatar') ? $request->file('avatar')->getSize() : null
                ],
                'timestamp' => now()
            ]);

            $user = Auth::user();
            if (!$user) {
                Log::warning('❌ UserProfileController: No authenticated user for profile update');
                return $this->sendErrorResponse('User not authenticated', 401);
            }

            // Check if profile exists first
            $existingProfile = UserProfile::where('user_id', $user->id)->first();
            
            // Validate request with conditional unique rule
            $validationRules = [
                'username' => 'required|string|max:255',
                'bio' => 'nullable|string|max:1000',
                'avatar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048'
            ];
            
            // Add unique rule based on whether profile exists
            if ($existingProfile) {
                $validationRules['username'] .= '|unique:user_profiles,username,' . $existingProfile->id;
            } else {
                $validationRules['username'] .= '|unique:user_profiles,username';
            }
            
            $validatedData = $request->validate($validationRules);

            Log::info('✅ UserProfileController: Validation passed', [
                'validated_data' => [
                    'username' => $validatedData['username'],
                    'bio_length' => strlen($validatedData['bio'] ?? ''),
                    'has_avatar' => $request->hasFile('avatar')
                ]
            ]);

            // Use the existing profile check
            $profile = $existingProfile;
            $isUpdate = $profile ? true : false;

            Log::info('🔍 UserProfileController: Profile existence check', [
                'profile_exists' => $isUpdate,
                'profile_id' => $profile?->id
            ]);

            // Handle avatar upload
            if ($request->hasFile('avatar')) {
                Log::info('📸 UserProfileController: Processing avatar upload', [
                    'file_name' => $request->file('avatar')->getClientOriginalName(),
                    'file_size' => $request->file('avatar')->getSize(),
                    'file_type' => $request->file('avatar')->getMimeType()
                ]);

                // Delete old avatar if exists
                if ($profile && $profile->avatar) {
                    Log::info('🗑️ UserProfileController: Deleting old avatar', [
                        'old_avatar_path' => $profile->avatar
                    ]);
                    Storage::disk('public')->delete($profile->avatar);
                }

                // Upload new avatar
                $avatarPath = $this->compressAndUploadImage($request->file('avatar'), 'user_avatars');
                
                if ($avatarPath) {
                    $validatedData['avatar'] = $avatarPath;
                    Log::info('✅ UserProfileController: Avatar uploaded successfully', [
                        'avatar_path' => $avatarPath
                    ]);
                } else {
                    Log::warning('⚠️ UserProfileController: Avatar upload failed, continuing without avatar');
                }
            }

            // Create or update profile
            if ($isUpdate) {
                Log::info('🔄 UserProfileController: Updating existing profile', [
                    'profile_id' => $profile->id,
                    'old_username' => $profile->username
                ]);

                $profile->update($validatedData);
                $message = 'Profile updated successfully';
                
                Log::info('✅ UserProfileController: Profile updated successfully', [
                    'profile_id' => $profile->id,
                    'new_username' => $profile->username
                ]);
            } else {
                Log::info('🆕 UserProfileController: Creating new profile', [
                    'user_id' => $user->id,
                    'username' => $validatedData['username']
                ]);

                $validatedData['user_id'] = $user->id;
                $profile = UserProfile::create($validatedData);
                $message = 'Profile created successfully';
                
                // Create buyer profile request for admin approval
                $user->buyerProfileRequests()->create([
                    'request_status' => 'pending',
                    'requested_at' => now()
                ]);
                
                Log::info('✅ UserProfileController: Profile created successfully', [
                    'profile_id' => $profile->id,
                    'username' => $profile->username
                ]);
                
                Log::info('📝 UserProfileController: Buyer profile request created', [
                    'user_id' => $user->id,
                    'username' => $profile->username
                ]);
            }

            // Load the updated profile with user relationship
            $profile->load('user');

            Log::info('🎉 UserProfileController: Profile operation completed successfully', [
                'profile_id' => $profile->id,
                'username' => $profile->username,
                'has_avatar' => !empty($profile->avatar),
                'operation' => $isUpdate ? 'update' : 'create'
            ]);

            return $this->sendSuccessResponse($message, $profile);
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::warning('⚠️ UserProfileController: Validation failed', [
                'errors' => $e->errors(),
                'user_id' => Auth::id()
            ]);
            return $this->sendErrorResponse('Validation failed', 422, $e->errors());
        } catch (\Exception $e) {
            Log::error('💥 UserProfileController: Error in profile operation', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => Auth::id()
            ]);
            return $this->sendErrorResponse('Failed to process profile', 500);
        }
    }

    /**
     * Delete user profile
     */
    public function destroy()
    {
        try {
            Log::info('🗑️ UserProfileController: Starting profile deletion', [
                'user_id' => Auth::id(),
                'timestamp' => now()
            ]);

            $user = Auth::user();
            if (!$user) {
                Log::warning('❌ UserProfileController: No authenticated user for profile deletion');
                return $this->sendErrorResponse('User not authenticated', 401);
            }

            $profile = UserProfile::where('user_id', $user->id)->first();
            
            if (!$profile) {
                Log::info('ℹ️ UserProfileController: No profile found to delete');
                return $this->sendSuccessResponse('No profile found to delete', null);
            }

            // Delete avatar file if exists
            if ($profile->avatar) {
                Log::info('🗑️ UserProfileController: Deleting avatar file', [
                    'avatar_path' => $profile->avatar
                ]);
                Storage::disk('public')->delete($profile->avatar);
            }

            $profileId = $profile->id;
            $profile->delete();

            Log::info('✅ UserProfileController: Profile deleted successfully', [
                'deleted_profile_id' => $profileId,
                'user_id' => $user->id
            ]);

            return $this->sendSuccessResponse('Profile deleted successfully', null);
        } catch (\Exception $e) {
            Log::error('💥 UserProfileController: Error deleting profile', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'user_id' => Auth::id()
            ]);
            return $this->sendErrorResponse('Failed to delete profile', 500);
        }
    }
}
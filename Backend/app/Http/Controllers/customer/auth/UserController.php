<?php

namespace App\Http\Controllers\customer\auth;
use App\Http\Controllers\Controller;

use Illuminate\Support\Facades\DB;

use App\Models\Package;
use App\Models\Referral;
use Twilio\Rest\Client;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserStatus;
use App\Services\ResponseService;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Support\Carbon;
use App\Mail\PasswordResetEmail;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    //login user
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return ResponseService::error('Invalid Credentials', null, 404);
        }

        $token = $user->createToken('user_token')->plainTextToken;

        // Mark user as online when they login
        try {
            \Log::info("User {$user->id} is logging in, marking as online");
            UserStatus::markOnline($user->id);
        } catch (\Exception $e) {
            \Log::error('Failed to mark user online: ' . $e->getMessage());
        }

        return ResponseService::success('Login successful', ['user' => $user->makeHidden([
            'password',
            'remember_token',
            'created_at',
            'updated_at',
            'location_lat',
            'location_long'
        ]), 'token' => $token]);
    }

    //signup user
    public function signup(Request $request)
    {
        try {
            \Log::info('🚀 UserController: Starting user signup process', [
                'email' => $request->email,
                'name' => $request->name,
                'timestamp' => now()
            ]);

            DB::beginTransaction();
            \Log::info('📝 UserController: Database transaction started');

            $data = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email,',
                'password' => 'required|string|min:8',
            ]);

            \Log::info('✅ UserController: Input validation passed', [
                'name' => $data['name'],
                'email' => $data['email'],
                'password_length' => strlen($data['password'])
            ]);

            if ($data['password'] != $request->input('password_confirm')) {
                \Log::warning('❌ UserController: Password confirmation mismatch', [
                    'email' => $data['email']
                ]);
                return ResponseService::error('Password and Confirm Password must be same', 'Password and Confirm Password must be same');
            }

            \Log::info('✅ UserController: Password confirmation verified');

            $data['password'] = Hash::make($data['password']);
            \Log::info('🔐 UserController: Password hashed successfully');

            $user = User::create($data);
            \Log::info('👤 UserController: User created successfully', [
                'user_id' => $user->id,
                'email' => $user->email,
                'name' => $user->name
            ]);

            // Ensure the user has a unique affiliate code
            if (empty($user->affiliate_code)) {
                // Simple deterministic code based on user ID (e.g., REF000123)
                $affiliateCode = 'REF' . str_pad($user->id, 6, '0', STR_PAD_LEFT);
                $user->affiliate_code = $affiliateCode;
                $user->save();
                \Log::info('🏷 UserController: Affiliate code generated for user', [
                    'user_id' => $user->id,
                    'affiliate_code' => $affiliateCode,
                ]);
            }

            // Assign default "Seller" role to new user
            $userRole = $user->userRoles()->create([
                'role' => 'seller'
            ]);
            \Log::info('🎭 UserController: Default seller role assigned', [
                'user_id' => $user->id,
                'role_id' => $userRole->id,
                'role' => 'seller'
            ]);

            $token = $user->createToken('user_token')->plainTextToken;
            \Log::info('🔑 UserController: Authentication token created', [
                'user_id' => $user->id,
                'token_length' => strlen($token)
            ]);

            $package = Package::where('title', 'free')->first();
            \Log::info('📦 UserController: Fetching free package', [
                'package_found' => $package ? true : false,
                'package_id' => $package?->id
            ]);

            if(!$package){
                \Log::error('❌ UserController: Free package not found');
                return response()->json([
                    'status' => 'error',
                    'message' => 'package not found'
                ]);
            }

            $userPackage = $user->userPackage()->create([
                'user_id' => $user->id,
                'package_id' => $package->id,
                'duration' => $package->packageCategory->duration,
                'product_count' => $package->product_count,
                'package_name' => $package->title
            ]);
            \Log::info('📋 UserController: User package created', [
                'user_id' => $user->id,
                'package_id' => $package->id,
                'package_name' => $package->title,
                'duration' => $package->packageCategory->duration,
                'product_count' => $package->product_count
            ]);

            $wallet = $user->wallet()->create([
                'balance' => 0,
                'expense' => 0,
                'last_recharge' => 0,
                'user_id' => $user->id
            ]);
            \Log::info('💰 UserController: User wallet created', [
                'user_id' => $user->id,
                'wallet_id' => $wallet->id,
                'initial_balance' => 0
            ]);

            // Handle referral relationship if a referral code was provided
            // Accept multiple possible keys to be flexible with frontend implementation
            $refCode = $request->input('ref_code')
                ?? $request->input('ref')
                ?? $request->input('affiliate_code');

            if (!empty($refCode)) {
                $referrer = User::where('affiliate_code', $refCode)->first();

                if ($referrer && $referrer->id !== $user->id) {
                    Referral::firstOrCreate(
                        [
                            'referrer_id' => $referrer->id,
                            'referred_user_id' => $user->id,
                        ],
                        []
                    );

                    \Log::info('🤝 UserController: Referral relationship created', [
                        'referrer_id' => $referrer->id,
                        'referred_user_id' => $user->id,
                        'ref_code_used' => $refCode,
                    ]);
                } else {
                    \Log::warning('⚠️ UserController: Invalid or self referral code ignored', [
                        'user_id' => $user->id,
                        'ref_code_used' => $refCode,
                    ]);
                }
            }

            DB::commit();
            \Log::info('✅ UserController: Database transaction committed successfully', [
                'user_id' => $user->id
            ]);

            \Log::info('🎉 UserController: User signup completed successfully', [
                'user_id' => $user->id,
                'email' => $user->email,
                'name' => $user->name,
                'role' => 'seller',
                'package' => $package->title,
                'wallet_created' => true
            ]);

            return ResponseService::success('Login successful', ['user' => $user, 'token' => $token]);

        } catch (\Throwable $th) {
            DB::rollback();
            \Log::error('💥 UserController: User signup failed', [
                'error' => $th->getMessage(),
                'trace' => $th->getTraceAsString(),
                'email' => $request->email ?? 'unknown'
            ]);
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }

    //update user profile infos
    public function updateMe(Request $request)
    {
        try {
            $user = User::findOrFail($request->user()->id);

            $data = $request->validate([
                'name' => 'nullable|string|max:255',
                'user_name' => 'nullable|string|max:255',
                'email' => 'nullable|email|unique:users,email,' . $user->id,
                'secondery_email' => 'nullable|email',
                'phone' => 'nullable|string|unique:users,phone,' . $user->id,
                'country_id' => 'nullable|exists:countries,id',
                'city_id' => 'nullable|exists:cities,id',
                'state_id' => 'nullable|exists:states,id',
                'zip_code' => 'nullable',
                'profile_img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
                'facebook_id' => 'nullable|string|max:255',
                'google_id' => 'nullable|string|max:255',
                'location_lat' => 'nullable|string|max:255',
                'location_long' => 'nullable|string|max:255',
            ]);

            $data = array_filter($data, fn($value) => !is_null($value));

            if ($request->hasFile('profile_img')) {
                if ($user->user_img) {
                    Storage::disk('public')->delete($user->user_img);
                }
                $imagePath = $request->file('profile_img')->store('user_images', 'public');
                $data['profile_img'] = $imagePath;
            }

            $user->update($data);

            return ResponseService::success('User updated successfully', $user);
        } catch (\Throwable $th) {
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }

    //send password reset OTP
    public function sendResetOtp(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email'
            ]);

            $user = User::where('email', $request->email)->first();
            Log::info($user);

            if (!$user) {
                return ResponseService::error('User not found', null, 404);
            }

            $otp = rand(1000, 9999);
            Log::info($otp);
            Mail::to($user->email)->send(new PasswordResetEmail($otp));
            Log::info('Email sent');
            $user->password_reset_otp = Hash::make($otp);
            $user->password_reset_expires_at = Carbon::now()->addMinutes(10);
            $user->save();

            return ResponseService::success('OTP sent to your email');
        } catch (\Throwable $th) {
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }

    //rest password with OTP
    public function verifyOtp(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email',
                'otp' => 'required|string',
            ]);

            $user = User::where('email', $request->email)->first();

            if (!$user) {
                return ResponseService::error('User not found', null, 404);
            }

            if (!$user->password_reset_otp) {
                return ResponseService::error('No OTP request found', null, 400);
            }

            if (Carbon::now()->gt($user->password_reset_expires_at)) {
                return ResponseService::error('OTP has expired. Please request a new one.', null, 400);
            }

            if (!Hash::check($request->otp, $user->password_reset_otp)) {
                return ResponseService::error('Invalid OTP', null, 400);
            }

            return ResponseService::success('OTP Verified Successfully', null, 200);
        } catch (\Throwable $th) {
           return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }

    //rest password with OTP
    public function resetPasswordWithOtp(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email',
                'otp' => 'required|string',
                'password' => 'required|string|min:8',
                'password_confirm' => 'required|string|same:password'
            ]);

            $user = User::where('email', $request->email)->first();

            if (!$user) {
                return ResponseService::error('User not found', null, 404);
            }

            if (!$user->password_reset_otp) {
                return ResponseService::error('No OTP request found', null, 400);
            }

            if (Carbon::now()->gt($user->password_reset_expires_at)) {
                return ResponseService::error('OTP has expired. Please request a new one.', null, 400);
            }

            if (!Hash::check($request->otp, $user->password_reset_otp)) {
                return ResponseService::error('Invalid OTP', null, 400);
            }

            // Reset password
            $user->password = Hash::make($request->password);
            $user->password_reset_otp = null;
            $user->password_reset_expires_at = null;
            $user->save();

            $token = $user->createToken('user_token')->plainTextToken;

            return ResponseService::success('Password reset successful', ['user' => $user, 'token' => $token]);
        } catch (\Throwable $th) {
           return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }

    //change password
    public function changePassword(Request $request)
    {
        try {
            $data = $request->validate([
                'password' => 'required|string|min:8'
            ]);

            if ($data['password'] != $request->input('password_confirm')) {
                return ResponseService::error('Password and Confirm Password must be same');
            }

            $user = User::where('id', $request->user()->id)->first();

            if (!$user || !Hash::check($request->input('current_password'), $user->password)) {
                return ResponseService::error('Your Current Password is Wrong', null, 400);
            }

            $data['password'] = Hash::make($data['password']);

            $user->update($data);

            $token = $user->createToken('user_token')->plainTextToken;

            return ResponseService::success('Login successful', ['user' => $user, 'token' => $token]);
        } catch (\Throwable $th) {
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }

    //get me
    public function getMe( Request $request)
    {
        try {
            $user = User::select([
                'id',
                'name',
                'email',
                'phone',
                'zip_code',
                'profile_img',
                'user_type',
                'country_id',
                'state_id',
                'city_id',
                // Affiliate fields for referral links
                'affiliate_code',
                'is_affiliate',
                'commission_rate',
                ])->with(['shop', 'userPackage', 'wallet', 'userRoles'])->findOrFail($request->user()->id);

            // Ensure legacy users also have an affiliate_code generated once
            if (empty($user->affiliate_code)) {
                $affiliateCode = 'REF' . str_pad($user->id, 6, '0', STR_PAD_LEFT);
                $user->affiliate_code = $affiliateCode;
                // Do not modify is_affiliate or commission_rate here – admin controls those
                $user->save();
            }

            $user->address = ($user->country->country_name ?? '') . ', ' . ($user->state->state_name ?? '') . '-' . ($user->zip_code ?? '');
            $user->makeHidden(['country', 'state', 'city']);
            
            // Add role information
            $user->role = $user->userRoles->first()?->role ?? 'seller';
            
            Log::info('🔍 UserController getMe: User role information', [
                'user_id' => $user->id,
                'user_roles_count' => $user->userRoles->count(),
                'user_roles' => $user->userRoles->pluck('role'),
                'final_role' => $user->role
            ]);
            
            return ResponseService::success('User information retrived successfully', $user);
        } catch (\Throwable $th) {
            return ResponseService::error('No user found', $th->getMessage());
        }

    }

    //logout user
    public function logout(Request $request)
    {
        try {
            $user = $request->user();
            
            // Mark user as offline when they logout
            try {
                \Log::info("User {$user->id} is logging out, marking as offline");
                UserStatus::markOffline($user->id);
            } catch (\Exception $e) {
                \Log::error('Failed to mark user offline: ' . $e->getMessage());
            }
            
            //$request->user()->tokens()->delete();
            $request->user()->currentAccessToken()->delete();

            return ResponseService::success('Logged out successfully');
        } catch (\Throwable $th) {
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }


    //Verify phone number
    public function verifyPhoneNumber(Request $request)
    {
        try {
            $data = $request->validate([
                'phone_number' => ['required', 'string'],
                'verification_code' => ['required', 'numeric'],
            ]);

            $twilio_sid = env('TWILIO_SID');
            $twilio_token = env('TWILIO_AUTH_TOKEN');
            $twilio_verify_sid = env('TWILIO_VERIFY_SID');

            $twilio = new Client($twilio_sid, $twilio_token);

            // Verify the OTP
            $verificationCheck = $twilio->verify->v2->services($twilio_verify_sid)
                ->verificationChecks
                ->create($data['verification_code'], ['to' => $data['phone_number']]);

            if ($verificationCheck->status === 'approved') {
                User::where('phone', $data['phone_number'])->update(['is_number_verified' => true]);

                return ResponseService::success('Phone number verified successfully');
            }

            return ResponseService::error('Invalid verification code');
        } catch (\Throwable $th) {
            return ResponseService::error('Something went wrong', $th->getMessage());
        }
    }
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Facades\Hash;
use App\Models\UserPackage;
use App\Models\Wallet;
use App\Models\Package;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Log;



class GoogleLoginController extends Controller
{
    // Redirect to Google
    public function redirectToGoogle()
    {
        return Socialite::driver('google')->redirect();
    }

    // Handle Google callback
    public function redirect(Request $request)
    {
        try {
            $user = Socialite::driver('google')->stateless()->user();

            $googleId = $user->getId();
            $email = $user->getEmail();
            $fullName = $user->getName();
            $picture = $user->getAvatar();

            $isUser = User::where('email', $email)->first();

            if (!$isUser) {
                $saveUser = User::updateOrCreate(
                    ['google_id' => $googleId],
                    [
                        'name' => $fullName,
                        'email' => $email,
                        'password' => Hash::make($fullName . '@' . $googleId),
                        'user_type_id' => 1,
                        'country_id' => 0,
                        'city_id' => 0,
                        'language_id' => 0,
                        'user_img' => $picture,
                        'status' => 1
                    ]
                );
            } else {
                $isUser->update(['google_id' => $googleId]);
                $saveUser = User::with(['userType', 'country', 'city', 'language', 'favoriteProduct'])->where('email', $email)->first();
            }

            Auth::loginUsingId($saveUser->id);
            $token = $saveUser->createToken('user_token')->plainTextToken;

            $package = Package::where('title', 'free')->first();
            if (!$package) return ResponseService::error('Free package not found.');

            UserPackage::create([
                'user_id' => $saveUser->id,
                'package_id' => $package->id,
                'duration' => $package->duration,
                'product_count' => $package->product_count,
                'package_name' => $package->title
            ]);

            Wallet::create([
                'balance' => 0,
                'expense' => 0,
                'last_recharge' => 0,
                'user_id' => $saveUser->id
            ]);

            return ResponseService::success('Login successful', [
                'user' => $saveUser,
                'token' => $token,
            ]);
        } catch (\Throwable $th) {
            return ResponseService::error('Login failed', $th->getMessage(), 500);
        }
    }

    public function createUser(Request $request)
    {
        try {
            $data = $request->validate([
                'name' => 'required|string|max:255',
                'user_name' => 'nullable|string|max:255',
                'email' => 'required|email',
                'phone' => 'nullable|string|unique:users,phone|max:255',
                'password' => 'nullable|string',
                'user_type_id' => 'nullable|exists:user_types,id',
                'country_id' => 'nullable|exists:countries,id',
                'city_id' => 'nullable|exists:cities,id',
                'zip_code' => 'nullable|exists:languages,id',
                'is_number_verified' => 'nullable|boolean',
                'is_email_verified' => 'nullable|boolean',
                'user_img' => 'nullable|string',
                'facebook_id' => 'nullable|string|max:255',
                'google_id' => 'nullable|string|max:255',
                'location_lat' => 'nullable|string|max:255',
                'location_long' => 'nullable|string|max:255',
            ]);

            $isUser = User::where('email', $data['email'])->first();

            if ($isUser) {
                // User exists
                if ($isUser->google_id === $data['google_id']) {
                    // Google ID matches - just log in
                } elseif (empty($isUser->google_id)) {
                    // Update google_id if not set yet
                    $isUser->update(['google_id' => $data['google_id']]);
                } else {
                    // Email exists but google_id mismatched
                    return ResponseService::error('Google ID does not match the registered email.', [], 409);
                }

                $saveUser = $isUser;
            } else {
                // New user
                $data['password'] = Hash::make($data['name'] . '@' . $data['google_id']);
                $saveUser = User::create($data);

                // Optional: assign default package & wallet
                $package = Package::where('title', 'free')->first();
                if (!$package) return ResponseService::error('Free package not found.');

                UserPackage::create([
                    'user_id' => $saveUser->id,
                    'package_id' => $package->id,
                    'duration' => $package->packageCategory->duration,
                    'product_count' => $package->product_count ?? 0,
                    'package_name' => $package->title
                ]);

                Wallet::create([
                    'balance' => 0,
                    'expense' => 0,
                    'last_recharge' => 0,
                    'user_id' => $saveUser->id
                ]);
            }

            // Auth::loginUsingId($saveUser->id);
            $token = $saveUser->createToken('user_token')->plainTextToken;

            return ResponseService::success('Login successful', [
                'user' => $saveUser->load(['userType', 'country', 'city', 'language', 'favoriteProduct']),
                'token' => $token
            ]);
        } catch (\Throwable $th) {
            \Log::error("Google Login Error: " . $th->getMessage());
            return ResponseService::error('Login failed', $th->getMessage(), 500);
        }
    }


    // Login with email + google ID
    public function login(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $isUser = User::where('email', $request->email)->first();

        if (!$isUser) {
            return ResponseService::error('User not found');
        }

        $isUser->update(['google_id' => $request->google_id]);

        $saveUser = User::with(['userType', 'country', 'city', 'language', 'favoriteProduct'])->where('email', $request->email)->first();
        Auth::loginUsingId($saveUser->id);
        $token = $saveUser->createToken('user_token')->plainTextToken;

        return ResponseService::success('Login successful', [
            'user' => $saveUser,
            'token' => $token
        ]);
    }

    // Logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return ResponseService::success('Logged out successfully');
    }
}

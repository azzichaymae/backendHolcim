<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Les identifiants sont incorrects.'],
            ]);
        }

        // Revoke previous tokens (single session)
        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => [
                'id'    => $user->id,
                'nom'   => $user->nom,
                'email' => $user->email,
                'role'  => $user->role,
            ],
        ], 200);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie.'
        ], 200);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('service.departement');
    
        return response()->json([
            'id'          => $user->id,
            'nom'         => $user->nom,
            'email'       => $user->email,
            'role'        => $user->role,
            'service'     => $user->service?->nom,
            'departement' => $user->service?->departement?->nom,
            'service_id'  => $user->service_id,
        ], 200);
    }
    public function changePassword(Request $request): JsonResponse
{
    $request->validate([
        'current_password' => 'required',
        'password'         => 'required|min:8|confirmed',
    ]);

    if (!Hash::check($request->current_password, $request->user()->password)) {
        return response()->json([
            'message' => 'Le mot de passe actuel est incorrect.'
        ], 422);
    }

    $request->user()->update([
        'password' => Hash::make($request->password),
    ]);

    return response()->json(['message' => 'Mot de passe modifié avec succès.']);
}
}
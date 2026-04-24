<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Mail;
class AuthController extends Controller
{
   // In AuthController login method
public function login(Request $request): JsonResponse
{
    $credentials = $request->validate([
        'email'    => 'required|email',
        'password' => 'required',
    ]);

    if (!auth()->attempt($credentials)) {
        return response()->json(['message' => 'Identifiants incorrects.'], 401);
    }

    $user  = auth()->user(); // ← user is authenticated here
    $token = $user->createToken('auth_token')->plainTextToken;

    // ← Log AFTER authentication succeeds
    \Log::info('auth.login', [
        'user_id' => $user->id,
        'role'    => $user->role,
        'ip'      => $request->ip(),
    ]);

    return response()->json([
        'token' => $token,
        'user'  => $user,
    ]);
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
            'id' => $user->id,
            'nom' => $user->nom,
            'prenom' => $user->prenom,
            'email' => $user->email,
            'role' => $user->role,
            'service' => $user->service?->nom,
            'departement' => $user->service?->departement?->nom,
            'service_id' => $user->service_id,
        ], 200);
    }
    public function changePassword(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required',
            'password' => 'required|min:8|confirmed',
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

    public function requestReset(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();
        if (!$user) {
            return response()->json(['message' => 'Email non trouvé'], 404);
        }

        // Send email to RRH only
        $rrh = User::where('role', 'RRH')->first();

        Mail::send('emails.rrh-reset-request', ['user' => $user], function ($mail) use ($rrh) {
            $mail->to($rrh->email)->subject('Demande de réinitialisation mot de passe');
        });

        return response()->json(['message' => 'Demande envoyée au RRH']);
    }

public function rrhResetPassword(Request $request, $userId)
{
    $request->validate([
        'new_password' => 'required|min:8' // RRH sends the new password from frontend
    ]);
    
    $user = User::findOrFail($userId);
    
    // Update password with what RRH sent
    $user->password = Hash::make($request->new_password);
    $user->save();
    
    // Send email to user with the NEW password (what RRH just set)
    Mail::send('emails.user-new-password', [
        'user' => $user, 
        'password' => $request->new_password // The password RRH entered
    ], function($mail) use ($user) {
        $mail->to($user->email)->subject('Votre mot de passe a été modifié');
    });
    
    return response()->json([
        'message' => 'Mot de passe modifié et notification envoyée'
    ]);
}
}
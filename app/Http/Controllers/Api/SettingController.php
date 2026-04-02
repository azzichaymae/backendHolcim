<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SettingController extends Controller
{
    // GET /api/settings
    public function index(): JsonResponse
    {
        $settings = Setting::getInstance();
        return response()->json($settings, 200);
    }

    // PUT /api/settings
    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'directeur_usine'       => 'required|string|max:150',
            'titre_directeur'       => 'required|string|max:150',
            'email_directeur'       => 'nullable|string|max:150',
            'site'                  => 'required|string|max:150',
            'societe'               => 'required|string|max:150',
            'resp_sante_securite'   => 'required|string|max:150',
            'email_resp_sante_securite' => 'nullable|string|max:150',
            'medecin'               => 'required|string|max:150',
        ]);

        $settings = Setting::getInstance();
        $settings->update($validated);

        return response()->json($settings, 200);
    }
}
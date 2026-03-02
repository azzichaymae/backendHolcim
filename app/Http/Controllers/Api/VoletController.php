<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Volet;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class VoletController extends Controller
{
    // GET /api/volets
    public function index(): JsonResponse
    {
        $volets = Volet::withCount('habilitations')
            ->with('habilitationStandard')
            ->orderBy('nom')
            ->get();

        return response()->json($volets, 200);
    }

    // GET /api/volets/{id}
    public function show(Volet $volet): JsonResponse
    {
        $volet->load('habilitations')
              ->loadCount('habilitations');

        return response()->json($volet, 200);
    }

    // POST /api/volets
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nom'         => 'required|string|max:100|unique:volets,nom',
            'description' => 'nullable|string',
        ]);

        $volet = Volet::create($validated);

        return response()->json($volet, 201);
    }

    // PUT /api/volets/{id}
    public function update(Request $request, Volet $volet): JsonResponse
    {
        $validated = $request->validate([
            'nom'         => 'required|string|max:100|unique:volets,nom,' . $volet->id,
            'description' => 'nullable|string',
        ]);

        $volet->update($validated);

        return response()->json($volet, 200);
    }

    // DELETE /api/volets/{id}
    public function destroy(Volet $volet): JsonResponse
    {
        if ($volet->habilitations()->exists()) {
            return response()->json([
                'message'               => 'Impossible de supprimer ce volet : des habilitations y sont rattachées.',
                'nombre_habilitations'  => $volet->habilitations()->count(),
            ], 409);
        }

        $volet->delete();

        return response()->json([
            'message' => 'Volet supprimé avec succès.'
        ], 200);
    }
}
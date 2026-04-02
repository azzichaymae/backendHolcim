<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Habilitation;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class HabilitationController extends Controller
{
    // GET /api/habilitations
    public function index(Request $request): JsonResponse
    {
        $query = Habilitation::with('volet');

        // Filter by volet
        if ($request->has('volet_id')) {
            $query->where('volet_id', $request->volet_id);
        }
        $habilitations = $query->orderBy('nom')->get();
        $habilitations = Habilitation::with('volet')
    ->withCount('employeeHabilitations as employee_count')
    ->get();

        return response()->json($habilitations, 200);
    }

    // GET /api/habilitations/volet/{volet_id}
    public function getByVolet($volet_id): JsonResponse
    {
        $habilitations = Habilitation::with('volet')
            ->where('volet_id', $volet_id)
            ->orderBy('nom')
            ->get();

        return response()->json($habilitations, 200);
    }

    // GET /api/habilitations/{id}
    public function show(Habilitation $habilitation): JsonResponse
    {
        $habilitation->load('volet');

        return response()->json($habilitation, 200);
    }

    // POST /api/habilitations
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nom'                             => 'required|string|max:150',
            'detail_formation'                => 'nullable|string',
            'duree_formation_initiale'         => 'required|numeric|min:0.5',
            'duree_formation_initiale_unite'   => 'required|in:heures,jours',
            'duree_formation_recyclage'        => 'required|numeric|min:0.5',
            'duree_formation_recyclage_unite'  => 'required|in:heures,jours',
            'duree_de_validite'                => 'required|integer|min:1',
            'volet_id'                         => 'required|exists:volets,id',
            'texte_autorisation'               => 'required|string|max:255',
        ]);

       
        $habilitation = Habilitation::create($validated);
        $habilitation->load('volet');

        return response()->json($habilitation, 201);
    }

    // PUT /api/habilitations/{id}
    public function update(Request $request, Habilitation $habilitation): JsonResponse
    {
        $validated = $request->validate([
            'nom'                             => 'required|string|max:150',
            'detail_formation'                => 'nullable|string',
            'duree_formation_initiale'         => 'required|numeric|min:0.5',
            'duree_formation_initiale_unite'   => 'required|in:heures,jours',
            'duree_formation_recyclage'        => 'required|numeric|min:0.5',
            'duree_formation_recyclage_unite'  => 'required|in:heures,jours',
            'duree_de_validite'                => 'required|integer|min:1',
            'volet_id'                         => 'required|exists:volets,id',
            'texte_autorisation'               => 'required|string|max:255',
        ]);

        

        $habilitation->update($validated);
        $habilitation->load('volet');

        return response()->json($habilitation, 200);
    }

    // DELETE /api/habilitations/{id}
    public function destroy(Habilitation $habilitation): JsonResponse
    {
        if ($habilitation->employeeHabilitations()->exists()) {
            return response()->json([
                'message' => 'Impossible de supprimer cette habilitation : elle est déjà attribuée à des employés.',
                'nombre_attributions' => $habilitation->employeeHabilitations()->count(),
            ], 409);
        }

        $habilitation->delete();

        return response()->json([
            'message' => 'Habilitation supprimée avec succès.'
        ], 200);
    }
}
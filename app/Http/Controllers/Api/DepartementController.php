<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Departement;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class DepartementController extends Controller
{
    // GET /api/departements
    public function index(): JsonResponse
    {
        $departements = Departement::withCount('employees')
            ->orderBy('nom')
            ->get();

        return response()->json($departements, 200);
    }

    // GET /api/departements/{id}
    public function show(Departement $departement): JsonResponse
    {
        $departement->loadCount('employees');

        return response()->json($departement, 200);
    }

    // POST /api/departements
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:100|unique:departements,nom',
        ]);

        $departement = Departement::create($validated);

        return response()->json($departement, 201);
    }

    // PUT /api/departements/{id}
    public function update(Request $request, Departement $departement): JsonResponse
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:100|unique:departements,nom,' . $departement->id,
        ]);

        $departement->update($validated);

        return response()->json($departement, 200);
    }

    // DELETE /api/departements/{id}
    public function destroy(Departement $departement): JsonResponse
    {
        if ($departement->employees()->exists()) {
            return response()->json([
                'message' => 'Impossible de supprimer ce département : des employés y sont rattachés.',
                'nombre_employes' => $departement->employees()->count(),
            ], 409);
        }

        $departement->delete();

        return response()->json([
            'message' => 'Département supprimé avec succès.'
        ], 200);
    }
}
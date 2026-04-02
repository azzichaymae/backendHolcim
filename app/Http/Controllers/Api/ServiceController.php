<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Service;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ServiceController extends Controller
{
    // GET /api/services
    public function index(Request $request): JsonResponse
    {
        $query = Service::with(['departement'])
                        ->withCount('employees');

        if ($request->has('departement_id')) {
            $query->where('departement_id', $request->departement_id);
        }

        return response()->json($query->orderBy('nom')->get(), 200);
    }
 
    // GET /api/services/{id}
    public function show(Service $service): JsonResponse
    {
        $service->load(['departement', 'employees']);
        $service->loadCount('employees');

        return response()->json($service, 200);
    }

    // POST /api/services
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nom'             => 'required|string|max:100',
            'departement_id'  => 'required|exists:departements,id',
            'responsable'  => 'nullable|string|max:150',
            'responsable_email' => 'nullable|string|max:150',
        ]);
       

        $service = Service::create($validated);
        $service->load(['departement']);

        return response()->json($service, 201);
    }

    // PUT /api/services/{id}
    public function update(Request $request, Service $service): JsonResponse
    {
        $validated = $request->validate([
            'nom'            => 'required|string|max:100',
            'departement_id' => 'required|exists:departements,id',
            'responsable' => 'nullable|string|max:150',
            'responsable_email' => 'nullable|string|max:150',
        ]);

        $service->update($validated);
        $service->load(['departement']);

        return response()->json($service, 200);
    }

    // DELETE /api/services/{id}
    public function destroy(Service $service): JsonResponse
    {
        if ($service->employees()->exists()) {
            return response()->json([
                'message'         => 'Impossible de supprimer ce service : des employés y sont rattachés.',
                'nombre_employes' => $service->employees()->count(),
            ], 409);
        }

        $service->delete();

        return response()->json([
            'message' => 'Service supprimé avec succès.'
        ], 200);
    }
}
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AlertController extends Controller
{
    // GET /api/alerts
    public function index(Request $request): JsonResponse
{
    $query = Alert::with([
        'employeeHabilitation.employee.service.departement',
        'employeeHabilitation.habilitation.volet',
    ]);

    // Auto-restrict Manager to their own service
    if (auth()->check() && auth()->user()->role === 'Manager') {
        $managerServiceId = auth()->user()->service_id;
        $query->whereHas('employeeHabilitation.employee', function ($q) use ($managerServiceId) {
            $q->where('service_id', $managerServiceId);
        });
    } else {
        if ($request->filled('service_id')) {
            $query->whereHas('employeeHabilitation.employee', function ($q) use ($request) {
                $q->where('service_id', $request->service_id);
            });
        }
        if ($request->filled('departement_id')) {
            $query->whereHas('employeeHabilitation.employee.service', function ($q) use ($request) {
                $q->where('departement_id', $request->departement_id);
            });
        }
        if ($request->filled('employee_id')) {
            $query->whereHas('employeeHabilitation', function ($q) use ($request) {
                $q->where('employee_id', $request->employee_id);
            });
        }
    }

    if ($request->filled('statut')) {
        $query->where('statut', $request->statut);
    }
    if ($request->filled('alert_type')) {
        $query->where('alert_type', $request->alert_type);
    }
    if ($request->boolean('urgent')) {
        $query->urgentes();
    }
    if ($request->boolean('only_active')) {
        $query->actives();
    }

    $alerts = $query
        ->orderBy('alert_date', 'asc')
        ->orderBy('jours_avant_expiration', 'asc')
        ->get();

    // ── Group by employee_habilitation_id ──────────────────────────────
    // Keep one row per attribution. The alert with the smallest
    // jours_avant_expiration drives urgence. All sibling IDs are
    // bundled so the frontend can mark all of them as seen at once.
    $grouped = $alerts
        ->groupBy('employee_habilitation_id')
        ->map(function ($group) {
            // Most urgent = smallest jours_avant_expiration
            $primary = $group->sortBy('jours_avant_expiration')->first();

            // statut = 'active' if ANY sibling is still active
            $anyActive = $group->contains(fn($a) => $a->statut === 'active');

            $primary->statut        = $anyActive ? 'active' : 'vue';
            $primary->sibling_ids   = $group->pluck('id')->values();
            $primary->alert_tiers   = $group
                ->sortBy('jours_avant_expiration')
                ->map(fn($a) => [
                    'id'                    => $a->id,
                    'jours_avant_expiration'=> $a->jours_avant_expiration,
                    'statut'                => $a->statut,
                    'alert_date'            => $a->alert_date,
                ])
                ->values();

            return $primary;
        })
        ->values();

    return response()->json($grouped, 200);
}

    // GET /api/alerts/{id}
    public function show(Alert $alert): JsonResponse
    {
        $alert->load([
            'employeeHabilitation.employee.service.departement',
            'employeeHabilitation.habilitation.volet',
        ]);

        return response()->json($alert, 200);
    }

    // PATCH /api/alerts/{id}/mark-as-viewed
    public function markAsViewed(Alert $alert): JsonResponse
    {
        $alert->marquerVue();

        $alert->load([
            'employeeHabilitation.employee.service.departement',
            'employeeHabilitation.habilitation.volet',
        ]);

        return response()->json($alert, 200);
    }

    // POST /api/alerts/mark-as-viewed-bulk
    public function markManyAsViewed(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ids'   => 'required|array',
            'ids.*' => 'integer|exists:alerts,id',
        ]);

        $updatedCount = Alert::whereIn('id', $validated['ids'])
            ->where('statut', '!=', 'vu')
            ->update(['statut' => 'vu']);

        return response()->json([
            'message' => 'Alertes marquées comme vues avec succès.',
            'count'   => $updatedCount,
        ], 200);
    }

    // DELETE /api/alerts/{id}
    public function destroy(Alert $alert): JsonResponse
    {
        $alert->delete();

        return response()->json([
            'message' => 'Alerte supprimée avec succès.',
        ], 200);
    }
     // GET /api/alerts/count
    public function count(): JsonResponse
    {
        $user = auth()->user();

        $query = Alert::actives();

        if ($user->role === 'Manager') {
            $query->whereHas('employeeHabilitation.employee', function ($q) use ($user) {
                $q->where('departement_id', $user->departement_id);
            });
        }

        $total    = (clone $query)->count();
        $urgentes = (clone $query)->urgentes()->count();
        $trente   = (clone $query)->where('jours_avant_expiration', 30)->count();
        $sept     = (clone $query)->where('jours_avant_expiration', 7)->count();

        return response()->json([
            'total'    => $total,
            'urgentes' => $urgentes,
            'a_30j'    => $trente,
            'a_7j'     => $sept,
        ], 200);
    }
}


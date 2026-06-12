<?php

namespace App\Http\Controllers\Api;
use Carbon\Carbon;
use App\Http\Controllers\Controller;
use App\Models\Alert;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AlertController extends Controller
{


// GET /api/alerts/{periode}
public function periode(Request $request, int $periode): JsonResponse
{
    $query = Alert::with([
        'employeeHabilitation.employee.service.departement',
        'employeeHabilitation.habilitation.volet',
    ])->actives();

    if (auth()->check() && auth()->user()->role === 'Manager') {
        $managerServiceId = auth()->user()->service_id;
        $query->whereHas('employeeHabilitation.employee', function ($q) use ($managerServiceId) {
            $q->where('service_id', $managerServiceId);
        });
    }

     if ($periode === 30) {
        $query->whereBetween('jours_avant_expiration', [8, 30]);
    } elseif ($periode === 7) {
        $query->whereBetween('jours_avant_expiration', [1, 8]);
    } elseif ($periode === 0) {
        $query->where('jours_avant_expiration', 0);
    }

    $alerts = $query
    ->orderBy('alert_date', 'asc')
    ->orderBy('jours_avant_expiration', 'asc')
    ->get()
    ->map(function ($alert) {
        $expiration = Carbon::parse($alert->employeeHabilitation->date_expiration);
        $today = Carbon::today();

        $joursRestants = $today->diffInDays($expiration, false); 

        $alert->jours_restants = $joursRestants;
        $alert->jours_restants_display = $joursRestants > 0 ? $joursRestants : null;

        return $alert;
    });

    return response()->json($alerts, 200);
}

    // GET /api/alerts
    public function index(Request $request): JsonResponse
    {
        $query = Alert::with([
            'employeeHabilitation.employee.service.departement',
            'employeeHabilitation.habilitation.volet',
        ]);

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

 
        $grouped = $alerts
            ->groupBy('employee_habilitation_id')
            ->map(function ($group) {
                 $primary = $group->sortBy('jours_avant_expiration')->first();

                 $anyActive = $group->contains(fn($a) => $a->statut === 'active');

                $primary->statut = $anyActive ? 'active' : 'vue';
                $primary->sibling_ids = $group->pluck('id')->values();
                $primary->alert_tiers = $group
                    ->sortBy('jours_avant_expiration')
                    ->map(fn($a) => [
                        'id' => $a->id,
                        'jours_avant_expiration' => $a->jours_avant_expiration,
                        'statut' => $a->statut,
                        'alert_date' => $a->alert_date,
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

        $counts = (clone $query)->pourAujourdhui()->first();

        return response()->json([
            'total' => (int) ($counts->total ?? 0),
            'a_30j' => (int) ($counts->a_30j ?? 0),
            'a_7j' => (int) ($counts->a_7j ?? 0),
            'urgentes' => (int) ($counts->urgentes ?? 0),
        ], 200);
    }
}



<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\Habilitation;
use App\Models\EmployeeHabilitation;
use App\Models\Alert;
use App\Models\Service;
use App\Models\Volet;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    // GET /api/dashboard
    public function index(): JsonResponse
    {
        $user = auth()->user();

        if ($user->role === 'Manager') {
            return $this->managerStats($user);
        }

        return $this->globalStats();
    }

    // ── Private : Global Stats (RRH / RH) ─────────────────

    private function globalStats(): JsonResponse
    {
        // ── Employees ──────────────────────────────────────
        $totalEmployees = Employee::count();

        // ── Habilitations ──────────────────────────────────
        $habQuery = EmployeeHabilitation::query()
            ->whereHas('employee', function ($q) {
                $q->whereNull('deleted_at');  
            });
        $habilitationsValides = (clone $habQuery)->valides()->count();
        $habilitationsExpirees = (clone $habQuery)->expirees()->count();
        $habilitationsExpirant30j = (clone $habQuery)->expirantDans(30)->count();
        $habilitationsExpirant7j = (clone $habQuery)->expirantDans(7)->count();
        $habilitationsExpAujourdhui = (clone $habQuery)->expirantDans(0)->count();

        // ── Alerts ─────────────────────────────────────────
        $alertsActives = Alert::actives()->count();
        $alertsUrgentes = Alert::urgentes()->count();
        $alerts30j = Alert::actives()->where('jours_avant_expiration', 30)->count();
        $alerts7j = Alert::actives()->where('jours_avant_expiration', 7)->count();

        // ── Chart 1 : Statut breakdown (pie chart) ─────────
        $statutChart = [
            ['label' => 'Valides', 'value' => $habilitationsValides, 'color' => '#22c55e'],
            ['label' => 'Expirées', 'value' => $habilitationsExpirees, 'color' => '#ef4444'],
            ['label' => 'Expirant bientôt', 'value' => $habilitationsExpirant30j, 'color' => '#f59e0b'],
        ];

        // ── Chart 2 : Habilitations par volet (bar chart) ──
        $parVolet = Volet::withCount([
            'habilitations as total_attributions' => function ($q) {
                $q->join('employee_habilitations', 'habilitations.id', '=', 'employee_habilitations.habilitation_id');
            },
            'habilitations as attributions_valides' => function ($q) {
                $q->join('employee_habilitations', 'habilitations.id', '=', 'employee_habilitations.habilitation_id')
                    ->where('employee_habilitations.statut', 'valide');
            },
            'habilitations as attributions_expirees' => function ($q) {
                $q->join('employee_habilitations', 'habilitations.id', '=', 'employee_habilitations.habilitation_id')
                    ->where('employee_habilitations.statut', 'expirée');
            },
            'habilitations as attributions_expirent_bientot' => function ($q) {
                $q->join('employee_habilitations', 'habilitations.id', '=', 'employee_habilitations.habilitation_id')
                    ->where('employee_habilitations.statut', 'valide')
                    ->whereDate('employee_habilitations.date_expiration', '<=', now()->addDays(30))
                    ->whereDate('employee_habilitations.date_expiration', '>=', now());
            },
        ])->get()->map(function ($volet) {
            return [
                'volet' => $volet->nom,
                'total' => $volet->total_attributions,
                'valides' => $volet->attributions_valides,
                'expirees' => $volet->attributions_expirees,
                'expirant_bientot' => $volet->attributions_expirent_bientot,
            ];
        });

        // ── Chart 3 : Alertes par seuil (bar chart) ────────
        $alertesChart = [
            ['label' => '30 jours', 'value' => $alerts30j, 'color' => '#f59e0b'],
            ['label' => '7 jours', 'value' => $alerts7j, 'color' => '#f97316'],
            ['label' => "Aujourd'hui", 'value' => $alertsUrgentes, 'color' => '#ef4444'],
        ];

        // ── Chart 4 : Salariés par service (bar chart) ─────
        $parService = Service::withCount('employees')
            ->with('departement')
            ->get()
            ->map(function ($service) {
                return [
                    'service' => $service->nom,
                    'departement' => $service->departement->nom,
                    'total' => $service->employees_count,
                ];
            });
        // ── Expiring soon list ──────────────────────────────
        $expirantBientot = EmployeeHabilitation::with([
            'employee',
            'habilitation.volet',
        ])
            ->expirantDans(30)
            ->orderBy('date_expiration')
            ->get()
            ->map(function ($eh) {
                return [
                    'employee_habilitation_id' => $eh->id,
                    'employe' => $eh->employee->prenom . ' ' . $eh->employee->nom,
                    'matricule' => $eh->employee->matricule,
                    'habilitation' => $eh->habilitation->nom,        // ← string not object
                    'volet' => $eh->habilitation->volet->nom, // ← string not object
                    'date_expiration' => $eh->date_expiration->format('d/m/Y'),
                    'jours_restants' => (int) now()->diffInDays($eh->date_expiration, false),
                ];
            });
        return response()->json([
            'stats' => [
                'employees' => [
                    'total' => $totalEmployees,
                ],
                'habilitations' => [
                    'valides' => $habilitationsValides,
                    'expirees' => $habilitationsExpirees,
                    'expirant_30j' => $habilitationsExpirant30j,
                    'expirant_7j' => $habilitationsExpirant7j,
                    'expirant_aujourdhui' => $habilitationsExpAujourdhui,
                ],
                'alerts' => [
                    'actives' => $alertsActives,
                    'urgentes' => $alertsUrgentes,
                ],
            ],
            'charts' => [
                'statut_breakdown' => $statutChart,
                'par_volet' => $parVolet,
                'alertes_par_seuil' => $alertesChart,
                'employes_par_service' => $parService,
            ],
            'expiring_soon' => $expirantBientot,
        ], 200);
    }

    // ── Private : Manager Stats ────────────────────────────

    private function managerStats($user): JsonResponse
    {
        $serviceId = $user->service_id;

        // ── Employees ──────────────────────────────────────
        $totalEmployees = Employee::where('service_id', $serviceId)->count();

        // ── Habilitations ──────────────────────────────────
        $habQuery = EmployeeHabilitation::whereHas('employee', function ($q) use ($serviceId) {
            $q->where('service_id', $serviceId);
        });

        $habilitationsValides = (clone $habQuery)->valides()->count();
        $habilitationsExpirees = (clone $habQuery)->expirees()->count();
        $habilitationsExpirant30j = (clone $habQuery)->expirantDans(30)->count();
        $habilitationsExpirant7j = (clone $habQuery)->expirantDans(7)->count();
        $habilitationsExpAujourdhui = (clone $habQuery)->expirantDans(0)->count();

        // ── Alerts ─────────────────────────────────────────
        $alertQuery = Alert::whereHas('employeeHabilitation.employee', function ($q) use ($serviceId) {
            $q->where('service_id', $serviceId);
        });

        $alertsActives = (clone $alertQuery)->actives()->count();
        $alertsUrgentes = (clone $alertQuery)->urgentes()->count();
        $alerts30j = (clone $alertQuery)->actives()->where('jours_avant_expiration', 30)->count();
        $alerts7j = (clone $alertQuery)->actives()->where('jours_avant_expiration', 7)->count();

        // ── Chart 1 : Statut breakdown (pie chart) ─────────
        $statutChart = [
            ['label' => 'Valides', 'value' => $habilitationsValides, 'color' => '#22c55e'],
            ['label' => 'Expirées', 'value' => $habilitationsExpirees, 'color' => '#ef4444'],
            ['label' => 'Expirant bientôt', 'value' => $habilitationsExpirant30j, 'color' => '#f59e0b'],
        ];

        // ── Chart 2 : Alertes par seuil ────────────────────
        $alertesChart = [
            ['label' => '30 jours', 'value' => $alerts30j, 'color' => '#f59e0b'],
            ['label' => '7 jours', 'value' => $alerts7j, 'color' => '#f97316'],
            ['label' => "Aujourd'hui", 'value' => $alertsUrgentes, 'color' => '#ef4444'],
        ];

        // ── Expiring soon list ──────────────────────────────
        $expirantBientot = EmployeeHabilitation::with([
            'employee',
            'habilitation.volet',
        ])
            ->whereHas('employee', function ($q) use ($serviceId) {
                $q->where('service_id', $serviceId);
            })
            ->expirantDans(30)
            ->orderBy('date_expiration')
            ->get()
            ->map(function ($eh) {
                return [
                    'employe' => $eh->employee->nom_complet,
                    'matricule' => $eh->employee->matricule,
                    'habilitation' => $eh->habilitation->nom,
                    'volet' => $eh->habilitation->volet->nom,
                    'date_expiration' => $eh->date_expiration,
                    'jours_restants' => $eh->jours_restants,
                ];
            });

        return response()->json([
            'service' => [
                'nom' => $user->service?->nom,
            ],
            'stats' => [
                'employees' => [
                    'total' => $totalEmployees,
                ],
                'habilitations' => [
                    'valides' => $habilitationsValides,
                    'expirees' => $habilitationsExpirees,
                    'expirant_30j' => $habilitationsExpirant30j,
                    'expirant_7j' => $habilitationsExpirant7j,
                    'expirant_aujourdhui' => $habilitationsExpAujourdhui,
                ],
                'alerts' => [
                    'actives' => $alertsActives,
                    'urgentes' => $alertsUrgentes,
                ],
            ],
            'charts' => [
                'statut_breakdown' => $statutChart,
                'alertes_par_seuil' => $alertesChart,
            ],
            'expiring_soon' => $expirantBientot,
        ], 200);
    }
}
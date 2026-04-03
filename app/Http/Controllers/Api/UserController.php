<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use App\Models\Employee;
use App\Models\EmployeeHabilitation;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::with('service')->orderBy('nom')->get();
        return response()->json($users);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:100',
            'prenom' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email',
            'role' => 'required|in:RRH,RH,Manager',
            'service_id' => 'nullable|exists:services,id',
            'password' => 'required|min:8|confirmed',
        ]);

        $user = User::create([
            ...$validated,
            'password' => Hash::make($validated['password']),
        ]);

        return response()->json($user->load('service'), 201);
    }

    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'nom' => 'required|string|max:100',
            'prenom' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'role' => 'required|in:RRH,RH,Manager',
            'service_id' => 'nullable|exists:services,id',
            'password' => 'nullable|min:8|confirmed',
        ]);

        if (!empty($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        } else {
            unset($validated['password']);
        }

        $user->update($validated);
        return response()->json($user->load('service'));
    }

    public function destroy(User $user): JsonResponse
    {
        if ($user->id === auth()->id()) {
            return response()->json([
                'message' => 'Vous ne pouvez pas supprimer votre propre compte.'
            ], 403);
        }
        $user->delete();
        return response()->json(null, 204);
    }

    // GET /api/manager/mon-equipe
    public function monEquipe(): JsonResponse
    {
        $user = auth()->user();
        $employees = Employee::where('service_id', $user->service_id)
            ->with([
                'service.departement',
                'employeeHabilitations.habilitation.volet',
                'employeeHabilitations.documents',
                'employeeHabilitations.alerts',
            ])
            ->whereNull('deleted_at')
            ->get();

        return response()->json($employees);
    }

    // GET /api/manager/recherche-habilitation?q=sauveteur
    public function rechercheHabilitation(Request $request): JsonResponse
{
    $q    = $request->query('q');
    $habId = $request->query('habilitation_id');

    $query = EmployeeHabilitation::whereHas('employee')
        ->with([
            'employee:id,nom,prenom,matricule,service_id',
            'employee.service:id,nom',
            'habilitation:id,nom',
        ]);

    if ($habId) {
        $query->where('habilitation_id', $habId);
    } elseif ($q) {
        $query->whereHas('habilitation', fn($q2) => $q2->where('nom', 'like', "%{$q}%"));
    } else {
        return response()->json([]);
    }

    $results = $query->get()
        ->groupBy('habilitation_id')
        ->map(function ($group) {
            return [
                'habilitation' => $group->first()->habilitation->nom,
                'employes'     => $group->map(fn($eh) => [
                    'nom_complet' => $eh->employee->prenom . ' ' . $eh->employee->nom,
                    'matricule'   => $eh->employee->matricule,
                    'service'     => $eh->employee->service->nom,
                    'statut'      => $eh->statut,
                ])->values(),
            ];
        })->values();

    return response()->json($results);
}

}
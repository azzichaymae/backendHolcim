<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class EmployeeController extends Controller
{
    // GET /api/employees
    public function index(Request $request): JsonResponse
    {
        $query = Employee::with('service.departement');

        // Auto-restrict Manager to their own service
        if (auth()->user()->role === 'Manager') {
            $query->where('service_id', auth()->user()->service_id);
        } else {
            // RRH / RH filters
            if ($request->has('service_id')) {
                $query->where('service_id', $request->service_id);
            }

            if ($request->has('departement_id')) {
                $query->whereHas('service', function ($q) use ($request) {
                    $q->where('departement_id', $request->departement_id);
                });
            }
        }

        // Search available for all roles
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nom', 'like', "%{$search}%")
                    ->orWhere('prenom', 'like', "%{$search}%")
                    ->orWhere('matricule', 'like', "%{$search}%")
                    ->orWhere('email_pro', 'like', "%{$search}%");
            });
        }

        $employees = $query->orderBy('nom')->get();

        return response()->json($employees, 200);
    }

    // GET /api/employees/{id}
    public function show(Employee $employee): JsonResponse
    {
        $employee->load([
            'service.departement',
            'service.responsable',
            'habilitations.habilitation.volet',
            'habilitations.documents',
            'habilitations.alerts',
        ]);

        return response()->json($employee, 200);
    }

    // POST /api/employees
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'matricule' => 'nullable|integer|unique:employees,matricule',
            'nom' => 'required|string|max:100',
            'prenom' => 'required|string|max:100',
            'email_pro' => 'required|email',
            'position' => 'required|string|max:150',
            'type' => 'required|in:propre,sous-traitant',
            'societe' => 'required_if:type,sous-traitant|nullable|string|max:150',
            'service_id' => 'required|exists:services,id',
        ]);
        $employee = Employee::create($validated);
        $employee->load('service.departement');

        return response()->json($employee, 201);
    }

    // PUT /api/employees/{id}
    public function update(Request $request, Employee $employee): JsonResponse
    {
        $validated = $request->validate([
            'matricule' => 'nullable|integer|unique:employees,matricule,' . $employee->id,
            'nom' => 'required|string|max:100',
            'prenom' => 'required|string|max:100',
            'email_pro' => 'required|email',
            'position' => 'required|string|max:150',
            'type' => 'required|in:propre,sous-traitant',
            'societe' => 'required_if:type,sous-traitant|nullable|string|max:150',
            'service_id' => 'required|exists:services,id',
        ]);

        $employee->update($validated);
        $employee->load('service.departement');

        return response()->json($employee, 200);
    }

    // DELETE /api/employees/{id}
    public function destroy(Employee $employee): JsonResponse
    {
        if ($employee->habilitations()->exists()) {
            return response()->json([
                'message' => 'Impossible de supprimer cet employé : des habilitations lui sont attribuées.',
                'nombre_habilitations' => $employee->habilitations()->count(),
            ], 409);
        }

        $employee->delete();

        return response()->json([
            'message' => 'Salarié supprimé avec succès.'
        ], 200);
    }
    
    // GET /api/employees/archived
    public function archived(): JsonResponse
    {
        $employees = Employee::onlyTrashed()
            ->with('service.departement')
            ->get();
        return response()->json($employees);
    }

    // PATCH /api/employees/{id}/restore
    public function restore($id): JsonResponse
    {
        $employee = Employee::onlyTrashed()->findOrFail($id);
        $employee->restore();
        return response()->json(['message' => 'Employé restauré.']);
    }

    // DELETE /api/employees/{id}/force — permanent delete if needed
    public function forceDelete($id): JsonResponse
    {
        $employee = Employee::onlyTrashed()->findOrFail($id);
        $employee->forceDelete();
        return response()->json(['message' => 'Employé supprimé définitivement.']);
    }

    public function import(Request $request): JsonResponse
    {
        $request->validate(['file' => 'required|file|mimes:xlsx,xls,csv|max:5120']);

        $import = new \App\Imports\EmployeesImport();
        $import->import($request->file('file'));

        return response()->json([
            'imported' => $import->imported,
            'updated' => $import->updated,
            'errors' => $import->errors,
        ]);
    }
}
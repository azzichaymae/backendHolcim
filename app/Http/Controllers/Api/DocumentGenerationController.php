<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EmployeeHabilitation;
use App\Models\Habilitation;
use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
class DocumentGenerationController extends Controller
{     
     Carbon::setLocale('fr');

    // GET /api/documents/employees-par-habilitation/{habilitation}
    public function employeesParHabilitation(Habilitation $habilitation): JsonResponse
    {

        $employees = EmployeeHabilitation::with('employee.service')
            ->where('habilitation_id', $habilitation->id)
            ->where('statut', 'valide')
            ->orderBy('date_expiration')
            ->get()
            ->map(function ($eh) {
                return [
                    'employee_habilitation_id' => $eh->id,
                    'matricule'                => $eh->employee->matricule,
                    'nom_complet'              => $eh->employee->prenom . ' ' . $eh->employee->nom,
                    'position'                 => $eh->employee->position,
                    'service'                  => $eh->employee->service->nom,
                    'date_obtention'           => $eh->date_obtention->format('d/m/Y'),
                    'date_expiration'          => $eh->date_expiration->format('d/m/Y'),
                    'statut'                   => $eh->statut,
                ];
            });

        return response()->json([
            'habilitation' => $habilitation->nom,
            'total'        => $employees->count(),
            'employees'    => $employees,
        ], 200);
    }

    // POST /api/documents/generate/individuelle
    public function generateIndividuelle(Request $request)
    {
        $request->validate([
            'employee_habilitation_id' => 'required|exists:employee_habilitations,id',
        ]);

        $eh = EmployeeHabilitation::with([
            'employee.service.departement',
            'habilitation',
        ])->findOrFail($request->employee_habilitation_id);

        $settings = Setting::getInstance();

        $filename = 'habilitation_'
            . $eh->employee->matricule . '_'
            . str_replace(' ', '_', $eh->habilitation->nom) . '_'
            . now()->format('Ymd')
            . '.pdf';

        $pdf = Pdf::loadView('pdf.habilitation_individuelle', [
            'eh'       => $eh,
            'settings' => $settings,
        ])->setPaper('a4', 'portrait');

        return $pdf->download($filename);
    }

    // POST /api/documents/generate/note
    public function generateNote(Request $request)
    {
        $request->validate([
            'habilitation_id' => 'required|exists:habilitations,id',
        ]);

        $habilitation = Habilitation::findOrFail($request->habilitation_id);

        $employeeHabilitations = EmployeeHabilitation::with([
            'employee.service',
        ])
        ->where('habilitation_id', $habilitation->id)
        ->where('statut', 'valide')
        ->orderBy('date_expiration')
        ->get();

        $settings = Setting::getInstance();

        $filename = 'note_habilitation_'
            . str_replace(' ', '_', $habilitation->nom) . '_'
            . now()->format('Ymd')
            . '.pdf';

        $pdf = Pdf::loadView('pdf.note_habilitation', [
            'habilitation'          => $habilitation,
            'employeeHabilitations' => $employeeHabilitations,
            'settings'              => $settings,
        ])->setPaper('a4', 'portrait');

        return $pdf->download($filename);
    }
}
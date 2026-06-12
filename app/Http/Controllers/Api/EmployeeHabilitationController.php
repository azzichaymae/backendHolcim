<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EmployeeHabilitation;
use App\Models\Alert;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Carbon\Carbon;
use App\Models\Habilitation;
use App\Models\Setting;
use App\Models\Document;
use Barryvdh\DomPDF\Facade\Pdf;

class EmployeeHabilitationController extends Controller
{
     // GET /api/employee-habilitations
     public function index(Request $request): JsonResponse
     {
          $query = EmployeeHabilitation::with([
               'employee.service.departement',
               'habilitation.volet',
               'documents',
               'alerts',
          ]);

           if (auth()->user()->role === 'Manager') {
               $managerServiceId = auth()->user()->service_id;
               $query->whereHas('employee', function ($q) use ($managerServiceId) {
                    $q->where('service_id', $managerServiceId);
               });
          } else {
               if ($request->has('service_id')) {
                    $query->whereHas('employee', function ($q) use ($request) {
                         $q->where('service_id', $request->service_id);
                    });
               }

               if ($request->has('departement_id')) {
                    $query->whereHas('employee.service', function ($q) use ($request) {
                         $q->where('departement_id', $request->departement_id);
                    });
               }

               if ($request->has('employee_id')) {
                    $query->where('employee_id', $request->employee_id);
               }

               if ($request->has('habilitation_id')) {
                    $query->where('habilitation_id', $request->habilitation_id);
               }
          }

          if ($request->has('statut')) {
               $query->where('statut', $request->statut);
          }

          if ($request->has('expiring_soon')) {
               $query->expirantDans((int) $request->expiring_soon);
          }

          $results = $query->orderBy('date_expiration')->get();

          return response()->json($results, 200);
     }

     // GET /api/employee-habilitations/{id}
     public function show(EmployeeHabilitation $employeeHabilitation): JsonResponse
     {
          $employeeHabilitation->load([
               'employee.departement',
               'employee.service',
               'habilitation.volet',
               'documents',
               'alerts',
          ]);

          return response()->json($employeeHabilitation, 200);
     }

     // POST /api/employee-habilitations
     public function store(Request $request): JsonResponse
     {
          $validated = $request->validate([
               'employee_id' => 'required|exists:employees,id',
               'habilitation_id' => 'required|exists:habilitations,id',
               'date_obtention' => 'required|date',
               'type' => 'required|in:initiale,recyclage',
               'organisme_formation' => 'required|string|max:150',
               'date_aptitude_medicale' => 'required|date',
          ]);

           $habilitation = \App\Models\Habilitation::findOrFail($validated['habilitation_id']);

           $dateExpiration = Carbon::parse($validated['date_obtention'])
               ->addYears($habilitation->duree_de_validite);

          $validated['date_expiration'] = $dateExpiration->toDateString();

           $validated['statut'] = $dateExpiration->isPast() ? 'expirée' : 'valide';

          $employeeHabilitation = EmployeeHabilitation::create($validated);
          \Log::info('attribution.created', [
               'employee_id' => $employeeHabilitation->employee_id,
               'habilitation_id' => $employeeHabilitation->habilitation_id,
               'type' => $employeeHabilitation->type,
               'created_by' => auth()->id(),
               'role' => auth()->user()->role,
          ]);
           Alert::genererPourHabilitation($employeeHabilitation);

          $employeeHabilitation->load([
               'employee.departement',
               'habilitation.volet',
               'documents',
               'alerts',
          ]);

          return response()->json($employeeHabilitation, 201);
     }

     // POST /api/employee-habilitations/with-document
     public function storeWithDocument(Request $request): JsonResponse
     {
           $validated = $request->validate([
               'employee_id' => 'required|exists:employees,id',
               'habilitation_id' => 'required|exists:habilitations,id',
               'date_obtention' => 'required|date',
               'type' => 'required|in:initiale,recyclage',
               'organisme_formation' => 'required|string|max:150',
               'date_aptitude_medicale' => 'required|date',
          ]);
           $existingActive = EmployeeHabilitation::where('employee_id', $validated['employee_id'])
        ->where('habilitation_id', $validated['habilitation_id'])
        ->where('statut', 'valide')
        ->first();

   if ($existingActive) {
        $employee     = \App\Models\Employee::find($validated['employee_id']);
        $habilitation = \App\Models\Habilitation::find($validated['habilitation_id']);

        return response()->json([
            'message' => sprintf(
                '%s %s possède déjà une habilitation active "%s" valide jusqu\'au %s. Utilisez le renouvellement pour mettre à jour.',
                $employee->prenom,
                $employee->nom,
                $habilitation->nom,
                Carbon::parse($existingActive->date_expiration)->format('d/m/Y')
            ),
            'existing_id' => $existingActive->id,
        ], 422);
    }
          $habilitation = Habilitation::findOrFail($validated['habilitation_id']);
          $dateExpiration = Carbon::parse($validated['date_obtention'])
               ->addYears($habilitation->duree_de_validite);

          $validated['date_expiration'] = $dateExpiration->toDateString();
          $validated['statut'] = $dateExpiration->isPast() ? 'expirée' : 'valide';

          $employeeHabilitation = EmployeeHabilitation::create($validated);
          \Log::info('attribution.created', [
               'employee_habilitation_id' => $employeeHabilitation->id,
               'employee_id' => $employeeHabilitation->employee_id,
               'habilitation_id' => $employeeHabilitation->habilitation_id,
               'created_by' => auth()->id(),
          ]);
          Alert::genererPourHabilitation($employeeHabilitation);

           $pdf = Pdf::loadView('pdf.habilitation_individuelle', [
               'eh' => $employeeHabilitation,
               'settings' => Setting::getInstance(),
               'validation' => (new ValidationController())->statut($employeeHabilitation)->getData(),
          ])->setPaper('a4', 'portrait');
          $isRecyclage = $employeeHabilitation->type === 'recyclage' ? 'Recyclage_' : '';
          $filename = 'Habilitation_' . $employeeHabilitation->id . '_' . $isRecyclage  . now()->format('Ymd') . '.pdf';
          $relativePath = 'documents/' . $filename;
          $pdf->save(storage_path('app/public/' . $relativePath));

          $document = Document::create([
               'nom' => $filename,
               'employee_habilitation_id' => $employeeHabilitation->id,
               'type' => 'individuelle',
               'chemin' => $relativePath,
          ]);

          $employeeHabilitation->load(['employee.departement', 'habilitation.volet', 'documents', 'alerts']);

          return response()->json([
               'employee_habilitation' => $employeeHabilitation,
               'document' => $document,
          ], 201);
     }

     // PUT /api/employee-habilitations/{id}
     public function update(Request $request, EmployeeHabilitation $employeeHabilitation): JsonResponse
     {

          $validated = $request->validate([
               'date_obtention' => 'required|date',
               'type' => 'required|in:initiale,recyclage',
               'organisme_formation' => 'required|string|max:150',
               'date_aptitude_medicale' => 'required|date',
               'mode' => 'required|in:correction,renouvellement',

          ]);

          $mode = $validated['mode'];
          unset($validated['mode']);

           $habilitation = $employeeHabilitation->habilitation;
          $dateExpiration = Carbon::parse($validated['date_obtention'])
               ->addYears($habilitation->duree_de_validite);

          $validated['date_expiration'] = $dateExpiration->toDateString();
          $validated['statut'] = $dateExpiration->isPast() ? 'expirée' : 'valide';


           $oldDocument = Document::where('employee_habilitation_id', $employeeHabilitation->id)
               ->where('type', 'individuelle')
               ->latest()
               ->first();
          if ($mode === 'correction' && $oldDocument) {
               $oldPath = storage_path('app/public/' . $oldDocument->chemin);
               if (file_exists($oldPath)) {
                    unlink($oldPath);
               }
               $oldDocument->delete();
          } elseif ($mode === 'renouvellement' && $oldDocument) {
               $oldDocument->update(['archived' => true]);
          }

          $employeeHabilitation->update($validated);
          $employeeHabilitation->validations()->delete();
          $employeeHabilitation->update(['validation_statut' => 'non_soumis']);
\Log::info('attribution.updated', [
    'employee_habilitation_id' => $employeeHabilitation->id,
    'mode'                     => $mode,
    'updated_by'               => auth()->id(),
]);
           Alert::where('employee_habilitation_id', $employeeHabilitation->id)->delete();
          Alert::genererPourHabilitation($employeeHabilitation->fresh());


           $settings = Setting::getInstance();
          Carbon::setLocale('fr');

          $employeeHabilitation->load(['employee', 'habilitation', 'habilitation.volet']);

          $pdf = Pdf::loadView('pdf.habilitation_individuelle', [
               'eh' => $employeeHabilitation,
               'settings' => $settings,
               'validation' => null,
          ])->setPaper('a4', 'portrait');

          $filename = 'Habilitation_' . $employeeHabilitation->type . '_' . $employeeHabilitation->id . '_' . now()->format('YmdHis') . '.pdf';
          $relativePath = 'documents/' . $filename;
          $pdf->save(storage_path('app/public/' . $relativePath));

          Document::create([
               'nom' => $filename,
               'employee_habilitation_id' => $employeeHabilitation->id,
               'type' => 'individuelle',
               'chemin' => $relativePath,
          ]);
           \Log::info('attribution.updated', [
               'employee_habilitation_id' => $employeeHabilitation->id,
               'mode' => $mode,
               'updated_by' => auth()->id(),
          ]);

          return response()->json($employeeHabilitation->load(['employee', 'habilitation.volet']), 200);
     }


     // DELETE /api/employee-habilitations/{id}
     public function destroy(EmployeeHabilitation $employeeHabilitation): JsonResponse
     {
           $employeeHabilitation->delete();

          return response()->json([
               'message' => 'Habilitation employé supprimée avec succès.'
          ], 200);
     }

     // GET /api/employee-habilitations/expiring
     public function expiring(Request $request): JsonResponse
     {
          $jours = $request->get('jours', 30);

          $query = EmployeeHabilitation::with([
               'employee.service.departement',
               'habilitation.volet',
          ])->expirantDans((int) $jours);

           if (auth()->user()->role === 'Manager') {
               $managerServiceId = auth()->user()->service_id;
               $query->whereHas('employee', function ($q) use ($managerServiceId) {
                    $q->where('service_id', $managerServiceId);
               });
          }

          $results = $query->orderBy('date_expiration')
               ->get()
               ->map(function ($eh) {
                    $eh->jours_restants_display = $eh->jours_restants;
                    return $eh;
               });

          return response()->json($results, 200);
     }
     // GET /api/employee-habilitations/alertes
     public function alertes(Request $request): JsonResponse
     {
          $query = EmployeeHabilitation::with([
               'employee.service.departement',
               'habilitation.volet',
          ])
               ->where('date_expiration', '<=', Carbon::today()->addDays(30))
               ->orderBy('date_expiration')
               ->whereHas('employee', function ($q) {
                    $q->whereNull('deleted_at');  
               });

          if (auth()->user()->role === 'Manager') {
               $query->whereHas('employee', function ($q) {
                    $q->where('service_id', auth()->user()->service_id)
                         ->whereNull('deleted_at');  
               });
          }

          $results = $query->get()->map(fn($eh) => [
               'id' => $eh->id,
               'employee' => $eh->employee,
               'habilitation' => $eh->habilitation,
               'date_expiration' => $eh->date_expiration,
               'jours_restants' => (int) Carbon::today()->diffInDays($eh->date_expiration, false),
               'statut' => $eh->statut,
               'attribution' => $eh->id,
          ]);

          return response()->json($results);
     }

 
     public function history($empId): JsonResponse
     {
          $history = EmployeeHabilitation::with(['habilitation.volet'])
               ->where('employee_id', $empId)
               ->orderBy('date_obtention', 'desc')
               ->get();

          return response()->json($history, 200);
     }


}
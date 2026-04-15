<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AttributionValidation;
use App\Models\EmployeeHabilitation;
use App\Models\Setting;
use App\Mail\ValidationRequestMail;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Mail;

class ValidationController extends Controller
{
    // POST /api/validations/initier/{employeeHabilitation}
    public function initier(EmployeeHabilitation $employeeHabilitation): JsonResponse
    {
        // Already in progress
        if ($employeeHabilitation->validation_statut === 'en_cours') {
            return response()->json(['message' => 'Validation déjà en cours.'], 409);
        }

        // Delete any previous validation records
        $employeeHabilitation->validations()->delete();

        $settings  = Setting::getInstance();
        $employee  = $employeeHabilitation->employee()->with('service.departement')->first();
        $service   = $employee->service;
        $departement = $service->departement;

        // Build the 4 signatories in order
        $signatories = [
          [
                'ordre'           => 1,
                'role'            => 'employe',
                'signataire_nom'  => $employee->nom . ' ' . $employee->prenom,
                'signataire_email'=> $employee->email_pro,
            ],
            [
                'ordre'           => 2,
                'role'            => 'manager_service',
                'signataire_nom'  => $service->responsable ?? 'Responsable de service',
                'signataire_email'=> $service->responsable_email,
            ],
            [
                'ordre'           => 3,
                'role'            => 'manager_departement',
                'signataire_nom'  => $departement->responsable ?? 'Responsable de département',
                'signataire_email'=> $departement->responsable_email,
            ],
            [
                'ordre'           => 4,
                'role'            => 'resp_sst',
                'signataire_nom'  => $settings->resp_sante_securite,
                'signataire_email'=> $settings->email_resp_sante_securite,
            ],
            [
                'ordre'           => 5,
                'role'            => 'directeur',
                'signataire_nom'  => $settings->directeur_usine,
                'signataire_email'=> $settings->email_directeur,
            ],
        ];

        // Validate all emails exist before starting
        foreach ($signatories as $s) {
            if (empty($s['signataire_email'])) {
                return response()->json([
                    'message' => "Email manquant pour : {$s['signataire_nom']}. Veuillez compléter les paramètres."
                ], 422);
            }
        }

        // Create all validation records
        foreach ($signatories as $s) {
            AttributionValidation::create([
                ...$s,
                'employee_habilitation_id' => $employeeHabilitation->id,
                'token'                    => AttributionValidation::generateToken(),
                'statut'                   => 'en_attente',
            ]);
        }

        // Update attribution status
        $employeeHabilitation->update(['validation_statut' => 'en_cours']);

        // Send first email
        $this->sendNextValidationEmail($employeeHabilitation);

        return response()->json(['message' => 'Workflow de validation initié.'], 200);
    }

    // GET /api/validations/confirmer/{token}
    public function confirmer(string $token)
{
    $validation = AttributionValidation::where('token', $token)
        ->where('statut', 'en_attente')
        ->firstOrFail();

    $validation->update([
        'statut'       => 'confirme',
        'confirmed_at' => now(),
    ]);

    $eh = $validation->employeeHabilitation;

    // Check if all confirmed
    $allConfirmed = $eh->validations()
        ->where('statut', '!=', 'confirme')
        ->doesntExist();

    if ($allConfirmed) {
        $eh->update(['validation_statut' => 'valide']);
        // TODO: regenerate PDF with signatures
    } else {
        // Send next email in sequence
        $this->sendNextValidationEmail($eh);
    }

    return redirect(config('app.frontend_url') . '/validation-confirmer');

}

    // GET /api/validations/refuser/{token}
    public function refuser(Request $request, string $token): \Illuminate\Http\RedirectResponse
    {
        $validation = AttributionValidation::where('token', $token)
            ->where('statut', 'en_attente')
            ->firstOrFail();

        $validation->update([
            'statut'      => 'refuse',
            'commentaire' => $request->query('raison'),
            'confirmed_at'=> now(),
        ]);

        $validation->employeeHabilitation->update(['validation_statut' => 'refuse']);

        // Notify RRH/RH of refusal
        $this->notifyRefus($validation);

        return redirect(config('app.frontend_url') . '/validation-refused');
    }

    // GET /api/validations/{employeeHabilitation}
    public function statut(EmployeeHabilitation $employeeHabilitation): JsonResponse
    {
        $validations = $employeeHabilitation->validations()
            ->orderBy('ordre')
            ->get();

            
        return response()->json([
            'validation_statut' => $employeeHabilitation->validation_statut,
            'etapes'            => $validations,
        ]);
    }

    // ── Private helpers ────────────────────────────────────────────────────
    private function sendNextValidationEmail(EmployeeHabilitation $eh): void
    {
        $next = $eh->validations()
            ->where('statut', 'en_attente')
            ->orderBy('ordre')
            ->first();

        if (!$next) return;

        Mail::to($next->signataire_email)
            ->send(new ValidationRequestMail($next, $eh));
    }

    private function notifyRefus(AttributionValidation $validation): void
    {
        $recipients = \App\Models\User::whereIn('role', ['RRH', 'RH'])
            ->pluck('email')->toArray();

        foreach ($recipients as $email) {
            Mail::to($email)->send(
                new \App\Mail\ValidationRefusMail($validation)
            );
        }
    }


    public function info(string $token): JsonResponse
{
    $validation = AttributionValidation::where('token', $token)->firstOrFail();
    $eh = $validation->employeeHabilitation->load('employee', 'habilitation');
    return response()->json([
        'validation' => $validation,
        'eh'         => $eh,
    ]);
}
}
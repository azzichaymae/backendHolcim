<?php

namespace App\Imports;

use App\Models\Employee;
use App\Models\Service;
use PhpOffice\PhpSpreadsheet\IOFactory;
use Illuminate\Http\UploadedFile;

class EmployeesImport
{
    public int   $imported = 0;
    public int   $updated  = 0;
    public array $errors   = [];

    public function import(UploadedFile $file): void
    {
        $spreadsheet = IOFactory::load($file->getRealPath());
        $sheet       = $spreadsheet->getActiveSheet();
        $rows        = $sheet->toArray(null, true, true, false);

        if (empty($rows)) return;

        // First row = headers, normalize to lowercase
        $headers = array_map(fn($h) => strtolower(trim((string) $h)), $rows[0]);

        foreach (array_slice($rows, 1) as $index => $row) {
            $lineNumber = $index + 2;

            // Skip completely empty rows
            if (empty(array_filter($row, fn($v) => $v !== null && $v !== ''))) continue;

            $data = array_combine($headers, $row);

            // Resolve service by name
            $serviceName = trim((string) ($data['service'] ?? ''));
            $service = Service::whereRaw('LOWER(nom) = ?', [strtolower($serviceName)])->first();
            if (!$service) {
                $this->errors[] = "Ligne {$lineNumber} — service introuvable : \"{$serviceName}\"";
                continue;
            }

            $nom    = strtoupper(trim((string) ($data['nom']    ?? '')));
            $prenom = ucfirst(strtolower(trim((string) ($data['prenom'] ?? ''))));
            $email  = trim((string) ($data['email_pro'] ?? ''));
            $poste  = trim((string) ($data['position']  ?? ''));
            $type   = strtolower(trim((string) ($data['type']   ?? 'propre')));

            if (!$nom || !$prenom || !$email || !$poste) {
                $this->errors[] = "Ligne {$lineNumber} — champs obligatoires manquants (nom, prénom, email_pro, position)";
                continue;
            }

            if (!in_array($type, ['propre', 'sous-traitant'])) {
                $this->errors[] = "Ligne {$lineNumber} — type invalide : \"{$type}\" (propre ou sous-traitant)";
                continue;
            }

            $matricule = null;
            if ($type === 'propre') {
                $raw = $data['matricule'] ?? '';
                $matricule = ($raw !== null && $raw !== '') ? (int) $raw : null;
            }

            $societe = $type === 'sous-traitant' ? trim((string) ($data['societe'] ?? '')) : null;

            $payload = [
                'matricule'  => $matricule,
                'nom'        => $nom,
                'prenom'     => $prenom,
                'email_pro'  => $email,
                'position'   => $poste,
                'type'       => $type,
                'societe'    => $societe ?: null,
                'service_id' => $service->id,
            ];

            $existing = $matricule
                ? Employee::where('matricule', $matricule)->first()
                : Employee::where('email_pro', $email)->first();

            if ($existing) {
                $existing->update($payload);
                $this->updated++;
            } else {
                Employee::create($payload);
                $this->imported++;
            }
        }
    }
}
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

         $headers = array_map(fn($h) => strtolower(trim((string) $h)), $rows[0]);

        foreach (array_slice($rows, 1) as $index => $row) {
            $lineNumber = $index + 2;

             if (empty(array_filter($row, fn($v) => $v !== null && $v !== ''))) continue;

            $data = array_combine($headers, $row);

             $serviceName = trim((string) ($data['service'] ?? ''));
            $service = Service::whereRaw('LOWER(nom) = ?', [strtolower($serviceName)])->first();
            if (!$service) {
                $this->errors[] = "Ligne {$lineNumber} — service introuvable : \"{$serviceName}\"";
                continue;
            }

            $nom    = strtoupper(trim((string) ($data['nom']    ?? '')));
            $prenom = ucfirst(strtolower(trim((string) ($data['prénom'] ?? ''))));
            $poste  = trim((string) ($data['poste']  ?? ''));

             $rawType = trim((string) ($data['type'] ?? ''));
            $type = $rawType === "PP" ? 'propre' : 'sous-traitant';

             $emailInput = trim((string) ($data['e-mail'] ?? ''));
            if ($emailInput !== '') {
                $email = $emailInput;
            } else {
                $email = $this->generateEmail($prenom, $nom);
            }

            if (!$nom || !$prenom || !$email || !$poste) {
                $this->errors[] = "Ligne {$lineNumber} — champs obligatoires manquants (nom, prénom, e-mail, poste)";
                continue;
            }
            

            if (!in_array($rawType, ['PP', 'ST'])) {
                $this->errors[] = "Ligne {$lineNumber} — type invalide : \"{$rawType}\" (propre ou sous-traitant)";
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
            }
        }
    }

    /**
     * Generate a company email from first and last name.
     */
    private function generateEmail(string $prenom, string $nom): string
    {
        $cleanPrenom = $this->sanitizeForEmail($prenom);
        $cleanNom    = $this->sanitizeForEmail($nom);

        return strtolower("{$cleanPrenom}.{$cleanNom}@holcim.com");
    }

    /**
     * Remove accents and non-alphanumeric characters for email local parts.
     */
 private function sanitizeForEmail(string $value): string
{
     $value = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $value);
     $value = preg_replace('/[^a-zA-Z0-9\-]/u', '', $value);

    return $value;
}

}
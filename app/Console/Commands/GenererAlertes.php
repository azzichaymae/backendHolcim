<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\EmployeeHabilitation;
use App\Models\Alert;
use Carbon\Carbon;

class GenererAlertes extends Command
{
    protected $signature   = 'habilitations:generer-alertes';
    protected $description = 'Génère les alertes d\'expiration à 30j, 7j et 0j';

    public function handle(): void
    {
        $today  = Carbon::today();
        $seuils = [30, 7, 0];
        $count  = 0;

        foreach ($seuils as $jours) {
            $targetDate = $today->copy()->addDays($jours);

            // Find all valid habilitations expiring exactly on target date
            $habilitations = EmployeeHabilitation::where('statut', 'valide')
                ->whereDate('date_expiration', $targetDate)
                ->get();

            foreach ($habilitations as $eh) {
                 $existe = Alert::where('employee_habilitation_id', $eh->id)
                    ->where('jours_avant_expiration', $jours)
                    ->exists();

                if (!$existe) {
                    Alert::create([
                        'employee_habilitation_id' => $eh->id,
                        'alert_type'               => 'expiration_proche',
                        'alert_date'               => $targetDate,
                        'jours_avant_expiration'   => $jours,
                        'statut'                   => 'active',
                    ]);
                    $count++;
                }
            }
        }

        $this->info("✅ {$count} alerte(s) générée(s).");
    }
}
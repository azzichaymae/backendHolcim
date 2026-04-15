<?php

namespace App\Console\Commands;

use App\Mail\HabilitationExpirationMail;
use App\Models\Alert;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class EnvoyerAlertesMail extends Command
{
    protected $signature = 'alertes:envoyer-mail';
    protected $description = 'Envoie les emails pour les alertes du jour';

    public function handle(): void
    {
        $alertes = Alert::with([
            'employeeHabilitation.employee',
            'employeeHabilitation.habilitation.volet',
        ])
            ->whereDate('alert_date', Carbon::today())
            ->where('statut', 'active')
            ->whereNull('email_sent_at')
            ->get();

        $sent = 0;

        foreach ($alertes as $alerte) {
            $eh = $alerte->employeeHabilitation;

            $recipients = User::whereIn('role', ['RRH'])
                ->pluck('email')
                ->toArray();

            if (empty($recipients)) {
                continue;
            }

            // Centralized loop for 30j, 7j, 0j alerts
            foreach ([30, 7, 0] as $jours) {
                $alert = Alert::where('employee_habilitation_id', $eh->id)
                    ->where('jours_avant_expiration', $jours)
                    ->whereDate('alert_date', Carbon::today())
                    ->whereNull('email_sent_at')
                    ->first();

                if ($alert) {
                    foreach ($recipients as $recipient) {
                        Mail::to($recipient)->send(
                            new HabilitationExpirationMail($eh, $jours)
                        );
                    }

                    $alert->update(['email_sent_at' => now()]);
                    $sent++;

                    // Resolve previous tier alerts for same habilitation
                    Alert::where('employee_habilitation_id', $eh->id)
                        ->where('jours_avant_expiration', '>', $jours)
                        ->where('statut', 'active')
                        ->update(['statut' => 'resolue']);
                }
            }
        }

        $this->info("✅ {$sent} email(s) envoyé(s).");
    }
}

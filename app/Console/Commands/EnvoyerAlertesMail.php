<?php

namespace App\Console\Commands;

use App\Mail\HabilitationExpirationMail;
use App\Models\Alert;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Mail;

class EnvoyerAlertesMail extends Command
{
    protected $signature   = 'alertes:envoyer-mail';
    protected $description = 'Envoie les emails pour les alertes du jour';

    public function handle(): void
    {
        // Find all alerts whose alert_date is today and not yet emailed
        $alertes = Alert::with([
            'employeeHabilitation.employee',
            'employeeHabilitation.habilitation.volet',
        ])
        ->whereDate('alert_date', Carbon::today())
        ->where('statut', 'active')
        ->whereNull('email_sent_at') // add this column (see migration below)
        ->get();

        $sent = 0;

        foreach ($alertes as $alerte) {
            $eh    = $alerte->employeeHabilitation;
            $email = $eh->employee->email_pro;

            if (!$email) continue;

            // Send to the employee + RRH/RH users
            $recipients = \App\Models\User::whereIn('role', ['RRH', 'RH'])->pluck('email')->toArray();
            $recipients[] = $email;

            foreach (array_unique($recipients) as $recipient) {
                Mail::to($recipient)->queue(
                    new HabilitationExpirationMail($eh, $alerte->jours_avant_expiration)
                );
            }

            $alerte->update(['email_sent_at' => now()]);
            $sent++;
        }

        $this->info("✅ {$sent} email(s) envoyé(s).");
    }
}
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\EmployeeHabilitation;
use Carbon\Carbon;

class UpdateStatutsExpires extends Command
{
    protected $signature   = 'habilitations:update-statuts';
    protected $description = 'Met à jour le statut des habilitations expirées';

    public function handle(): void
    {
        $today = Carbon::today();

        $expired = EmployeeHabilitation::where('statut', 'valide')
            ->whereDate('date_expiration', '<', $today)
            ->get();

        $count = 0;

        foreach ($expired as $eh) {
            $eh->update(['statut' => 'expirée']);
            $count++;
        }

        $this->info("✅ {$count} habilitation(s) marquée(s) comme expirées.");
    }
}
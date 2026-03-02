<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Service;
use App\Models\Departement;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        $prod  = Departement::where('nom', 'Production')->first();
        $maint = Departement::where('nom', 'Maintenance')->first();
        $secu  = Departement::where('nom', 'Sécurité')->first();
        $rh    = Departement::where('nom', 'Ressources Humaines')->first();

        $services = [
            ['nom' => 'Service Production Ciment',   'departement_id' => $prod->id],
            ['nom' => 'Service Production Béton',     'departement_id' => $prod->id],
            ['nom' => 'Service Maintenance Électrique','departement_id' => $maint->id],
            ['nom' => 'Service Maintenance Mécanique','departement_id' => $maint->id],
            ['nom' => 'Service Sécurité Incendie',   'departement_id' => $secu->id],
            ['nom' => 'Service RH',                  'departement_id' => $rh->id],
        ];

        foreach ($services as $service) {
            Service::create($service);
        }
    }
}
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Departement;

class DepartementSeeder extends Seeder
{
    public function run(): void
    {
        $departements = [
            'Production',
            'Maintenance',
            'Qualité',
            'Sécurité',
            'Ressources Humaines',
            'Logistique',
        ];

        foreach ($departements as $nom) {
            Departement::create(['nom' => $nom]);
        }
    }
}
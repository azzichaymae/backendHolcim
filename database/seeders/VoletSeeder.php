<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Volet;

class VoletSeeder extends Seeder
{
    public function run(): void
    {
        $volets = [
            [
                'nom'         => 'Sécurité Incendie',
                'description' => 'Habilitations liées à la prévention et lutte contre l\'incendie',
            ],
            [
                'nom'         => 'Électrique',
                'description' => 'Habilitations pour les travaux électriques basse et haute tension',
            ],
            [
                'nom'         => 'Travail en Hauteur',
                'description' => 'Habilitations pour les interventions en hauteur',
            ],
            [
                'nom'         => 'Conduite d\'Engins',
                'description' => 'Habilitations pour la conduite de chariots et engins de chantier',
            ],
        ];

        foreach ($volets as $volet) {
            Volet::create($volet);
        }
    }
}
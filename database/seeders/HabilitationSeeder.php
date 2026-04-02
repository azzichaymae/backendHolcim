<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Habilitation;
use App\Models\Volet;

class HabilitationSeeder extends Seeder
{
    public function run(): void
    {
        $incendie  = Volet::where('nom', 'Sécurité Incendie')->first();
        $electrique = Volet::where('nom', 'Électrique')->first();
        $hauteur   = Volet::where('nom', 'Travail en Hauteur')->first();
        $engins    = Volet::where('nom', 'Conduite d\'Engins')->first();

        $habilitations = [
            // Sécurité Incendie
            [
                'nom'                            => 'Équipier de Première Intervention',
                'detail_formation'               => 'Formation de base à la lutte contre l\'incendie',
                'duree_formation_initiale'        => 7,
                'duree_formation_initiale_unite'  => 'heures',
                'duree_formation_recyclage'       => 4,
                'duree_formation_recyclage_unite' => 'heures',
                'duree_de_validite'               => 2,
                'volet_id'                        => $incendie->id,
            ],
            [
                'nom'                            => 'Équipier de Seconde Intervention',
                'detail_formation'               => 'Formation avancée à la lutte contre l\'incendie',
                'duree_formation_initiale'        => 2,
                'duree_formation_initiale_unite'  => 'jours',
                'duree_formation_recyclage'       => 1,
                'duree_formation_recyclage_unite' => 'jours',
                'duree_de_validite'               => 2,
                'volet_id'                        => $incendie->id,
            ],
            // Électrique
            [
                'nom'                            => 'Habilitation B0 — Exécutant non électricien',
                'detail_formation'               => 'Sensibilisation aux risques électriques',
                'duree_formation_initiale'        => 1,
                'duree_formation_initiale_unite'  => 'jours',
                'duree_formation_recyclage'       => 4,
                'duree_formation_recyclage_unite' => 'heures',
                'duree_de_validite'               => 3,
                'volet_id'                        => $electrique->id,
            ],
            [
                'nom'                            => 'Habilitation B1 — Exécutant électricien BT',
                'detail_formation'               => 'Travaux électriques basse tension',
                'duree_formation_initiale'        => 3,
                'duree_formation_initiale_unite'  => 'jours',
                'duree_formation_recyclage'       => 1,
                'duree_formation_recyclage_unite' => 'jours',
                'duree_de_validite'               => 3,
                'volet_id'                        => $electrique->id,
            ],
            // Travail en Hauteur
            [
                'nom'                            => 'Travail en Hauteur Niveau 1',
                'detail_formation'               => 'Utilisation des EPI anti-chute',
                'duree_formation_initiale'        => 14,
                'duree_formation_initiale_unite'  => 'heures',
                'duree_formation_recyclage'       => 7,
                'duree_formation_recyclage_unite' => 'heures',
                'duree_de_validite'               => 3,
                'volet_id'                        => $hauteur->id,
            ],
            // Conduite d'Engins
            [
                'nom'                            => 'CACES R489 — Chariot élévateur',
                'detail_formation'               => 'Conduite en sécurité des chariots élévateurs',
                'duree_formation_initiale'        => 5,
                'duree_formation_initiale_unite'  => 'jours',
                'duree_formation_recyclage'       => 2,
                'duree_formation_recyclage_unite' => 'jours',
                'duree_de_validite'               => 5,
                'volet_id'                        => $engins->id,
            ],
        ];

        foreach ($habilitations as $hab) {
            Habilitation::create($hab);
        }
    }
}
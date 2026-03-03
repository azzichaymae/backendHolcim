<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Setting;

class SettingSeeder extends Seeder
{
    public function run(): void
    {
     Setting::create([
          'directeur_usine'       => 'Chakib EL OUDGHIRI',
          'titre_directeur'       => 'Directeur d\'Usine',
          'site'                  => 'cimenterie d\'Oujda',
          'societe'               => 'LafargeHolcim Maroc',
          'resp_sante_securite'   => 'Fatima Zzahra CHARRIK',
          'resp_maintenance_elec' => 'Walid TOURGA',
          'resp_maintenance'      => 'Mohamed FANANE',
          'medecin'               => 'Abdelhamid BENDAHA',   // ← ADD
      ]);
    }
}
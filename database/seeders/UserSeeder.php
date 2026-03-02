<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Service;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $serviceRH   = Service::where('nom', 'Service RH')->first();
        $serviceProd = Service::where('nom', 'Service Production Ciment')->first();

        $rrh = User::create([
            'nom'        => 'Administrateur',
            'email'      => 'rrh@holcim.ma',
            'password'   => 'password123',
            'role'       => 'RRH',
            'service_id' => $serviceRH->id,
        ]);

        $rh = User::create([
            'nom'        => 'Responsable RH',
            'email'      => 'rh@holcim.ma',
            'password'   => 'password123',
            'role'       => 'RH',
            'service_id' => $serviceRH->id,
        ]);

        $manager = User::create([
            'nom'        => 'Manager Production',
            'email'      => 'manager@holcim.ma',
            'password'   => 'password123',
            'role'       => 'Manager',
            'service_id' => $serviceProd->id,
        ]);

        // Assign manager as responsable of their service
        $serviceProd->update(['responsable_id' => $manager->id]);
    }
}
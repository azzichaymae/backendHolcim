<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Employee;
use App\Models\Service;

class EmployeeSeeder extends Seeder
{
    public function run(): void
    {
        $prod  = Service::where('nom', 'Service Production Ciment')->first();
        $maint = Service::where('nom', 'Service Maintenance Électrique')->first();
        $secu  = Service::where('nom', 'Service Sécurité Incendie')->first();

        $employees = [
            [
                'matricule'  => 'EMP001',
                'nom'        => 'Benali',
                'prenom'     => 'Karim',
                'email_pro'  => 'k.benali@holcim.ma',
                'position'   => 'Opérateur de production',
                'service_id' => $prod->id,
            ],
            [
                'matricule'  => 'EMP002',
                'nom'        => 'El Fassi',
                'prenom'     => 'Sara',
                'email_pro'  => 's.elfassi@holcim.ma',
                'position'   => 'Technicienne maintenance',
                'service_id' => $maint->id,
            ],
            [
                'matricule'  => 'EMP003',
                'nom'        => 'Idrissi',
                'prenom'     => 'Youssef',
                'email_pro'  => 'y.idrissi@holcim.ma',
                'position'   => 'Agent de sécurité',
                'service_id' => $secu->id,
            ],
            [
                'matricule'  => 'EMP004',
                'nom'        => 'Tazi',
                'prenom'     => 'Nadia',
                'email_pro'  => 'n.tazi@holcim.ma',
                'position'   => 'Chef d\'équipe production',
                'service_id' => $prod->id,
            ],
        ];

        foreach ($employees as $emp) {
            Employee::create($emp);
        }
    }
}
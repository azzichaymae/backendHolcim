<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            DepartementSeeder::class,
            ServiceSeeder::class,    
            UserSeeder::class,
            EmployeeSeeder::class,
            VoletSeeder::class,
            HabilitationSeeder::class,
            SettingSeeder::class
        ]);
    }
}
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('directeur_usine', 150);
            $table->string('titre_directeur', 150)->default('Directeur d\'Usine');
            $table->string('site', 150);
            $table->string('societe', 150)->default('LafargeHolcim Maroc');
            $table->string('resp_sante_securite', 150);
            $table->string('resp_maintenance_elec', 150);
            $table->string('resp_maintenance', 150);
            $table->string('medecin', 150);              // ← ADD
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('settings');
    }
};
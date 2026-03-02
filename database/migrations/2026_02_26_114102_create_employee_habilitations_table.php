<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('employee_habilitations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')
                  ->constrained('employees')
                  ->cascadeOnDelete();
            $table->foreignId('habilitation_id')
                  ->constrained('habilitations')
                  ->cascadeOnDelete();
            $table->date('date_obtention');
            $table->date('date_expiration');
            $table->enum('type', ['initiale', 'recyclage']);
            $table->enum('statut', ['valide', 'expirée'])->default('valide');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('employee_habilitations');
    }
};
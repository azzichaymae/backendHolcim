<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_habilitation_id')
                  ->constrained('employee_habilitations')
                  ->cascadeOnDelete();
            $table->enum('alert_type', ['expiration_proche', 'recyclage']);
            $table->date('alert_date');
            $table->enum('jours_avant_expiration', [30, 7, 0]);
            $table->enum('statut', ['active', 'vu'])->default('active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('alerts');
    }
};
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::create('attribution_validations', function (Blueprint $table) {
        $table->id();
        $table->foreignId('employee_habilitation_id')
              ->constrained('employee_habilitations')
              ->cascadeOnDelete();
        $table->enum('role', [
            'employe',
            'manager_service',
            'manager_departement', 
            'resp_sst',
            'directeur'
        ]);
        $table->string('signataire_nom');
        $table->string('signataire_email');
        $table->string('token', 64)->unique();
        $table->enum('statut', ['en_attente', 'confirme', 'refuse'])
              ->default('en_attente');
        $table->text('commentaire')->nullable();
        $table->timestamp('confirmed_at')->nullable();
        $table->integer('ordre');  
        $table->timestamps();
    });
}
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attribution_validations');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('habilitations', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->text('detail_formation')->nullable();
            $table->unsignedInteger('duree_formation_initiale');
            $table->enum('duree_formation_initiale_unite', ['heures', 'jours']);
            $table->unsignedInteger('duree_formation_recyclage');
            $table->enum('duree_formation_recyclage_unite', ['heures', 'jours']);
            $table->unsignedInteger('duree_de_validite'); // unité fixe : années
            $table->foreignId('volet_id')
                  ->constrained('volets')
                  ->cascadeOnDelete();
            $table->boolean('is_standard')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('habilitations');
    }
};
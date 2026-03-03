<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
Schema::table('employee_habilitations', function (Blueprint $table) {
    $table->string('organisme_formation', 150)->after('type');
    $table->date('date_aptitude_medicale')->after('organisme_formation');
});
    }

    public function down(): void
    {
        Schema::table('employee_habilitations', function (Blueprint $table) {
            $table->dropColumn(['organisme_formation', 'medecin', 'date_aptitude_medicale']);
        });
    }
};
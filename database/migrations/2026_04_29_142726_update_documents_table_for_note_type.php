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
    Schema::table('documents', function (Blueprint $table) {
        $table->unsignedBigInteger('employee_habilitation_id')->nullable()->change();
        $table->foreignId('habilitation_id')->nullable()->constrained('habilitations')->cascadeOnDelete()->after('employee_habilitation_id');
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};

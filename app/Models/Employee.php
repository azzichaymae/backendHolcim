<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Employee extends Model
{
    use HasFactory;

    protected $table = 'employees';

    protected $fillable = [
        'matricule',
        'nom',
        'prenom',
        'email_pro',
        'position',
        'type',        // ← add
    'societe',  
        'service_id',
    ];

    // ── Relations ──────────────────────────────────────────

    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    public function departement()
    {
        return $this->hasOneThrough(
            Departement::class,
            Service::class,
            'id',           // FK on services
            'id',           // FK on departements
            'service_id',   // Local key on employees
            'departement_id'// Local key on services
        );
    }

    public function habilitations()
    {
        return $this->hasMany(EmployeeHabilitation::class, 'employee_id');
    }

    public function documents()
    {
        return $this->hasManyThrough(
            Document::class,
            EmployeeHabilitation::class,
            'employee_id',
            'employee_habilitation_id',
        );
    }

    public function getNomCompletAttribute(): string
    {
        return "{$this->prenom} {$this->nom}";
    }
}
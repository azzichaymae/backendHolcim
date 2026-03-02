<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Habilitation extends Model
{
    use HasFactory;

    protected $table = 'habilitations';

    protected $fillable = [
        'nom',
        'detail_formation',
        'duree_formation_initiale',
        'duree_formation_initiale_unite',
        'duree_formation_recyclage',
        'duree_formation_recyclage_unite',
        'duree_de_validite',
        'volet_id',
        'is_standard',
    ];

    protected $casts = [
        'is_standard' => 'boolean',
    ];

    // ── Relations ──────────────────────────────────────────

    public function volet()
    {
        return $this->belongsTo(Volet::class, 'volet_id');
    }

    public function employeeHabilitations()
    {
        return $this->hasMany(EmployeeHabilitation::class, 'habilitation_id');
    }

    public function employees()
    {
        return $this->hasManyThrough(
            Employee::class,
            EmployeeHabilitation::class,
            'habilitation_id',  // FK on employee_habilitations
            'id',               // FK on employees
            'id',               // Local key on habilitations
            'employee_id'       // Local key on employee_habilitations
        );
    }

    // ── Accessors ──────────────────────────────────────────

    public function getDureeFormationInitialeLibelleAttribute(): string
    {
        return "{$this->duree_formation_initiale} {$this->duree_formation_initiale_unite}";
    }

    public function getDureeFormationRecyclageLibelleAttribute(): string
    {
        return "{$this->duree_formation_recyclage} {$this->duree_formation_recyclage_unite}";
    }

    public function getDureeValiditeLibelleAttribute(): string
    {
        return "{$this->duree_de_validite} " . ($this->duree_de_validite > 1 ? 'années' : 'année');
    }

    // ── Scopes ─────────────────────────────────────────────

    public function scopeStandard($query)
    {
        return $query->where('is_standard', true);
    }

    public function scopeParVolet($query, int $voletId)
    {
        return $query->where('volet_id', $voletId);
    }

    // ── Helpers ────────────────────────────────────────────

    public function setAsStandard(): void
    {
        // Ensure only one standard per volet
        Habilitation::where('volet_id', $this->volet_id)
                     ->where('id', '!=', $this->id)
                     ->update(['is_standard' => false]);

        $this->update(['is_standard' => true]);
    }
}
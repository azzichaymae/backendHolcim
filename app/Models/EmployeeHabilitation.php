<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Carbon\Carbon;

class EmployeeHabilitation extends Model
{
    use HasFactory;

    protected $table = 'employee_habilitations';

    protected $fillable = [
        'employee_id',
        'habilitation_id',
        'date_obtention',
        'date_expiration',
        'type',
        'statut',
        'organisme_formation',       // ← add
        'date_aptitude_medicale',
            'acknowledged_at',
            'validation_statut',

    ];
    
    protected $casts = [
        'date_obtention'         => 'date',
        'date_expiration'        => 'date',
        'date_aptitude_medicale' => 'date',  // ← add
        'acknowledged_at'        => 'datetime',  // ← add
        'validation_statut'       => 'string',  // ← add

    ];
    public function acknowledge(): void
{
    $this->update(['acknowledged_at' => now()]);
}

    // ── Relations ──────────────────────────────────────────

    public function employee()
    {
        return $this->belongsTo(Employee::class, 'employee_id');
    }

    public function habilitation()
    {
        return $this->belongsTo(Habilitation::class, 'habilitation_id');
    }

    public function documents()
    {
        return $this->hasMany(Document::class, 'employee_habilitation_id');
    }

    public function alerts()
    {
        return $this->hasMany(Alert::class, 'employee_habilitation_id');
    }

    public function validations()
{
    return $this->hasMany(AttributionValidation::class);
}
    // ── Accessors ──────────────────────────────────────────

    public function getJoursRestantsAttribute(): int
    {
        return max(0, Carbon::today()->diffInDays($this->date_expiration, false));
    }

    public function getIsExpiredAttribute(): bool
    {
        return $this->date_expiration->isPast();
    }

    public function getIsExpiringSoonAttribute(): bool
    {
        return $this->jours_restants <= 30 && !$this->is_expired;
    }

    // ── Helpers ────────────────────────────────────────────

    public function updateStatut(): void
    {
        $this->statut = $this->date_expiration->isPast() ? 'expirée' : 'valide';
        $this->save();
    }

    // ── Scopes ─────────────────────────────────────────────

    public function scopeValides($query)
    {
        return $query->where('statut', 'valide');
    }

    public function scopeExpirees($query)
    {
        return $query->where('statut', 'expirée');
    }

    public function scopeExpirantDans($query, int $jours)
    {
        return $query->where('statut', 'valide')
                     ->whereDate('date_expiration', '<=', Carbon::today()->addDays($jours))
                     ->whereDate('date_expiration', '>=', Carbon::today());
    }
    public function scopeExpirantBientot($query, int $jours = 30)
{
    return $query->where('date_expiration', '<=', Carbon::today()->addDays($jours))
                 ->orderBy('date_expiration');
}
}
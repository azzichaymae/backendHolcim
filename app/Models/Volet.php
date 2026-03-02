<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Volet extends Model
{
    use HasFactory;

    protected $table = 'volets';

    protected $fillable = [
        'nom',
        'description',
    ];

    // ── Relations ──────────────────────────────────────────

    public function habilitations()
    {
        return $this->hasMany(Habilitation::class, 'volet_id');
    }

    public function habilitationStandard()
    {
        return $this->hasOne(Habilitation::class, 'volet_id')
                    ->where('is_standard', true);
    }

    // ── Accessors ──────────────────────────────────────────

    public function getNombreHabilitationsAttribute(): int
    {
        return $this->habilitations()->count();
    }

    public function getAStandardAttribute(): bool
    {
        return $this->habilitations()->where('is_standard', true)->exists();
    }

    // ── Scopes ─────────────────────────────────────────────

    public function scopeAvecStandard($query)
    {
        return $query->whereHas('habilitations', function ($q) {
            $q->where('is_standard', true);
        });
    }

    public function scopeSansStandard($query)
    {
        return $query->whereDoesntHave('habilitations', function ($q) {
            $q->where('is_standard', true);
        });
    }
}
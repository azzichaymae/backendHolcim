<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Service extends Model
{
    use HasFactory;

    protected $table = 'services';

    protected $fillable = [
        'nom',
        'departement_id',
        'responsable',
        'responsable_email',
    ];

    // ── Relations ──────────────────────────────────────────

    public function departement()
    {
        return $this->belongsTo(Departement::class, 'departement_id');
    }

    public function responsable()
    {
        return $this->belongsTo(User::class, 'responsable_id');
    }

    public function employees()
    {
        return $this->hasMany(Employee::class, 'service_id');
    }

    public function users()
    {
        return $this->hasMany(User::class, 'service_id');
    }

    // ── Accessors ──────────────────────────────────────────

    public function getNombreEmployesAttribute(): int
    {
        return $this->employees()->count();
    }
}
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'users';

    protected $fillable = [
        'nom',
        'prenom',
        'email',
        'password',
        'role',
        'service_id',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'password' => 'hashed',
    ];

    // ── Relations ──────────────────────────────────────────

    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }

    public function serviceResponsable()
    {
        return $this->hasOne(Service::class, 'responsable_id');
    }

    // ── Role Helpers ───────────────────────────────────────

    public function isRRH(): bool { return $this->role === 'RRH'; }
    public function isRH(): bool  { return $this->role === 'RH'; }

    public function isManager(): bool { return $this->role === 'Manager'; }

    // ── Scopes ─────────────────────────────────────────────

    public function scopeManagers($query)
    {
        return $query->where('role', 'Manager');
    }
}
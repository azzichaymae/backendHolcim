<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Facades\Mail;
use App\Mail\HabilitationExpirationMail;
use Carbon\Carbon;

class Alert extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $table = 'alerts';

    protected $fillable = [
        'employee_habilitation_id',
        'alert_type',
        'alert_date',
        'jours_avant_expiration',
        'statut',
        'email_sent_at'
    ];

    protected $casts = [
        'alert_date'              => 'date',
        'jours_avant_expiration'  => 'integer',
         'email_sent_at' => 'datetime',
    ];

    // ── Relations ──────────────────────────────────────────

    public function employeeHabilitation()
    {
        return $this->belongsTo(EmployeeHabilitation::class, 'employee_habilitation_id');
    }

    public function employee()
    {
        return $this->hasOneThrough(
            Employee::class,
            EmployeeHabilitation::class,
            'id',           // FK on employee_habilitations
            'id',           // FK on employees
            'employee_habilitation_id', // Local key on alerts
            'employee_id'   // Local key on employee_habilitations
        );
    }

    // ── Scopes ─────────────────────────────────────────────

    public function scopeActives($query)
    {
        return $query->where('statut', 'active');
    }

    public function scopeVues($query)
    {
        return $query->where('statut', 'vu');
    }

    public function scopeExpirationProche($query)
    {
        return $query->where('alert_type', 'expiration_proche');
    }

    public function scopeRecyclage($query)
    {
        return $query->where('alert_type', 'recyclage');
    }

    public function scopeUrgentes($query)
    {
        return $query->where('jours_avant_expiration', 0)
                     ->where('statut', 'active');
    }

    // ── Helpers ────────────────────────────────────────────

    public function marquerVue(): void
    {
        $this->update(['statut' => 'vu']);
    }

    public function getLibelleAttribute(): string
    {
        $nom = $this->employeeHabilitation->habilitation->nom ?? 'Habilitation';
        $employe = $this->employeeHabilitation->employee->nom_complet ?? 'Salarié';

        return match((int) $this->jours_avant_expiration) {
            0  => "⛔ {$employe} — {$nom} a expiré aujourd'hui",
            7  => "🔴 {$employe} — {$nom} expire dans 7 jours",
            30 => "🟡 {$employe} — {$nom} expire dans 30 jours",
            default => "ℹ️ {$employe} — {$nom}",
        };
    }

    // ── Static Factory ─────────────────────────────────────

   public static function genererPourHabilitation(EmployeeHabilitation $eh): void
{
    $dateExpiration = $eh->date_expiration;
    $today          = Carbon::today();

    foreach ([30, 7, 0] as $jours) {
        $alertDate = $dateExpiration->copy()->subDays($jours);

        // Only create if alert doesn't already exist
        $exists = self::where('employee_habilitation_id', $eh->id)
                      ->where('jours_avant_expiration', $jours)
                      ->exists();

        if (!$exists && $alertDate->gte($today)) {
            self::create([
                'employee_habilitation_id' => $eh->id,
                'alert_type'               => 'expiration_proche',
                'alert_date'               => $alertDate,
                'jours_avant_expiration'   => $jours,
                'statut'                   => 'active',
            ]);
        }
    }
}

   
}
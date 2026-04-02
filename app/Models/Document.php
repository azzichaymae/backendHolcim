<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Facades\Storage;

class Document extends Model
{
    use HasFactory;

    protected $table = 'documents';

    protected $fillable = [
        'nom',
        'chemin',
        'type',
        'employee_habilitation_id',
    ];

    // ── Relations ──────────────────────────────────────────

    public function employeeHabilitation()
    {
        return $this->belongsTo(EmployeeHabilitation::class, 'employee_habilitation_id');
    }

    // ── Accessors ──────────────────────────────────────────

    public function getUrlAttribute(): string
    {
        return Storage::url($this->chemin);
    }

    public function getTailleAttribute(): string
    {
        if (Storage::exists($this->chemin)) {
            $bytes = Storage::size($this->chemin);
            return number_format($bytes / 1024, 2) . ' Ko';
        }
        return 'Inconnu';
    }


   
}
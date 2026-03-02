<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Departement extends Model
{
    use HasFactory;

    protected $table = 'departements';

    protected $fillable = ['nom'];

    // ── Relations ──────────────────────────────────────────

    public function services()
    {
        return $this->hasMany(Service::class, 'departement_id');
    }

    public function employees()
    {
        return $this->hasManyThrough(
            Employee::class,
            Service::class,
            'departement_id', // FK on services
            'service_id',     // FK on employees
        );
    }
}
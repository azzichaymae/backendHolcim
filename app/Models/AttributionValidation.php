<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AttributionValidation extends Model
{
    protected $fillable = [
        'employee_habilitation_id',
        'role',
        'signataire_nom',
        'signataire_email',
        'token',
        'statut',
        'commentaire',
        'confirmed_at',
        'ordre',
    ];

    protected $casts = [
        'confirmed_at' => 'datetime',
    ];

    public function employeeHabilitation()
    {
        return $this->belongsTo(EmployeeHabilitation::class);
    }

    public static function generateToken(): string
    {
        return bin2hex(random_bytes(32));
    }
  
}
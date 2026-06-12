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

 
    public function habilitations()
    {
        return $this->hasMany(Habilitation::class, 'volet_id');
    }

    

 
    public function getNombreHabilitationsAttribute(): int
    {
        return $this->habilitations()->count();
    }

}
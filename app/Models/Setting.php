<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $table = 'settings';

    protected $fillable = [
     'directeur_usine',
     'titre_directeur',
     'site',
     'societe',
     'resp_sante_securite',
     'medecin',              
     'email_directeur', 
     'email_resp_sante_securite', 
 ];

     public static function getInstance(): self
    {
        return self::firstOrFail();
    }
}
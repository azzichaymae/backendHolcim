<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8">
<style>
  body { font-family: Arial, sans-serif; background: #f4f6f9; margin: 0; padding: 0; }
  .container { max-width: 600px; margin: 40px auto; background: white;
               border-radius: 10px; overflow: hidden;
               box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
  .header { padding: 28px 32px; background: #1a4a6b; }
  .header h1 { color: white; margin: 0; font-size: 1.1rem; font-weight: 700; }
  .header p  { color: rgba(255,255,255,0.7); margin: 4px 0 0; font-size: 0.85rem; }
  .body { padding: 28px 32px; }
  .body p { color: #374151; font-size: 0.95rem; line-height: 1.6; margin: 0 0 16px; }
  .info-card { background: #f8fafc; border: 1px solid #e8ecf0;
               border-radius: 8px; padding: 18px 20px; margin: 20px 0; }
  .info-row { display: flex; justify-content: space-between;
              padding: 7px 0; border-bottom: 1px solid #e8ecf0; font-size: 0.875rem; }
  .info-row:last-child { border-bottom: none; }
  .info-label { color: #9ca3af; font-weight: 500; }
  .info-value { color: #1a2e44; font-weight: 600; }
  .btn-group { display: flex; gap: 12px; margin: 24px 0; }
  .btn-confirm { padding: 12px 28px; background: #16a34a; color: white;
                 text-decoration: none; border-radius: 8px;
                 font-weight: 700; font-size: 0.9rem; }
  .btn-refuse  { padding: 12px 28px; background: #dc2626; color: white;
                 text-decoration: none; border-radius: 8px;
                 font-weight: 700; font-size: 0.9rem; }
  .footer { padding: 20px 32px; background: #f8fafc;
            border-top: 1px solid #e8ecf0; text-align: center; }
  .footer p { color: #9ca3af; font-size: 0.78rem; margin: 0; }
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1>Portail Habilitations Holcim</h1>
    <p>Demande de validation de signature</p>
  </div>
  <div class="body">
    <p>Bonjour <strong>{{ $validation->signataire_nom }}</strong>,</p>
    <p>Vous êtes invité(e) à valider l'habilitation suivante :</p>

    <div class="info-card">
      <div class="info-row">
        <span class="info-label">Employé</span>
        <span class="info-value">{{ $eh->employee->prenom }} {{ $eh->employee->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Matricule</span>
        <span class="info-value">{{ $eh->employee->matricule ?? 'Sous-traitant' }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Habilitation</span>
        <span class="info-value">{{ $eh->habilitation->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Date d'obtention</span>
        <span class="info-value">{{ $eh->date_obtention->format('d/m/Y') }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Date d'expiration</span>
        <span class="info-value">{{ $eh->date_expiration->format('d/m/Y') }}</span>
      </div>
    </div>

    <p>Veuillez confirmer ou refuser cette habilitation en cliquant sur l'un des boutons ci-dessous :</p>

    <div class="btn-group">
      <a href="{{ url('/api/validations/confirmer/' . $validation->token) }}" 
         class="btn-confirm">✓ Confirmer</a>
      <a href="{{ url('/api/validations/refuser/' . $validation->token) }}" 
         class="btn-refuse">✗ Refuser</a>
    </div>

    <p style="font-size:0.78rem;color:#9ca3af">
      Ce lien est à usage unique et sécurisé. Ne le partagez pas.
    </p>
  </div>
  <div class="footer">
    <p>Portail Habilitations Holcim — Email automatique, ne pas répondre.</p>
  </div>
</div>
</body>
</html>
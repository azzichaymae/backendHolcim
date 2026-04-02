<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; background: #f4f6f9; margin: 0; padding: 0; }
    .container { max-width: 600px; margin: 40px auto; background: white;
                 border-radius: 10px; overflow: hidden;
                 box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .header { padding: 28px 32px; background: #1a4a6b; }
    .header h1 { color: white; margin: 0; font-size: 1.2rem; font-weight: 700; }
    .header p  { color: rgba(255,255,255,0.7); margin: 4px 0 0; font-size: 0.85rem; }
    .urgency-bar { height: 5px; }
    .urgency-bar.expired  { background: #ef4444; }
    .urgency-bar.critical { background: #f97316; }
    .urgency-bar.warning  { background: #f59e0b; }
    .body { padding: 28px 32px; }
    .body p { color: #374151; font-size: 0.95rem; line-height: 1.6; margin: 0 0 16px; }
    .info-card { background: #f8fafc; border: 1px solid #e8ecf0;
                 border-radius: 8px; padding: 18px 20px; margin: 20px 0; }
    .info-row { display: flex; justify-content: space-between;
                padding: 7px 0; border-bottom: 1px solid #e8ecf0;
                font-size: 0.875rem; }
    .info-row:last-child { border-bottom: none; }
    .info-label { color: #9ca3af; font-weight: 500; }
    .info-value { color: #1a2e44; font-weight: 600; }
    .badge { display: inline-block; padding: 4px 12px; border-radius: 20px;
             font-size: 0.78rem; font-weight: 700; }
    .badge.expired  { background: #fef2f2; color: #dc2626; }
    .badge.critical { background: #fff7ed; color: #ea580c; }
    .badge.warning  { background: #fffbeb; color: #d97706; }
    .footer { padding: 20px 32px; background: #f8fafc;
              border-top: 1px solid #e8ecf0; text-align: center; }
    .footer p { color: #9ca3af; font-size: 0.78rem; margin: 0; }
  </style>
</head>
<body>
<div class="container">

  <div class="header">
    <h1>Gestion des Habilitations — Holcim Oujda</h1>
    <p>Notification automatique d'expiration</p>
  </div>

  @php
    $urgencyClass = $joursAvant === 0 ? 'expired' : ($joursAvant <= 7 ? 'critical' : 'warning');
  @endphp

  <div class="urgency-bar expired"></div>

  <div class="body">
    <p>Bonjour,</p>

    @if ($joursAvant === 0)
      <p>L'habilitation suivante <strong>a expiré aujourd'hui</strong> et nécessite une action immédiate.</p>
    @elseif ($joursAvant <= 7)
      <p>L'habilitation suivante expire dans <strong>{{ $joursAvant }} jour(s)</strong>. Une action urgente est requise.</p>
    @else
      <p>L'habilitation suivante arrive à expiration dans <strong>{{ $joursAvant }} jours</strong>. Veuillez planifier le recyclage.</p>
    @endif

    <div class="info-card">
      <div class="info-row">
        <span class="info-label">Employé : </span>
        <span class="info-value">{{ $eh->employee->prenom }} {{ $eh->employee->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Matricule : </span>
        <span class="info-value">{{ $eh->employee->matricule }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Habilitation : </span>
        <span class="info-value">{{ $eh->habilitation->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Volet : </span>
        <span class="info-value">{{ $eh->habilitation->volet->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Date d'expiration : </span>
        <span class="info-value">{{ $eh->date_expiration->format('d/m/Y') }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">Urgence : </span>
        <span class="info-value">
          <span class="badge {{ $urgencyClass }}">
            @if ($joursAvant === 0) Expiré aujourd'hui
            @elseif ($joursAvant <= 7) Critique — {{ $joursAvant }}j
            @else À planifier — {{ $joursAvant }}j
            @endif
          </span>
        </span>
      </div>
    </div>

    <p>Veuillez vous connecter à l'application pour traiter cette alerte et planifier le recyclage.</p>
  </div>

  <div class="footer">
    <p>Cet email a été envoyé automatiquement par le système de gestion des habilitations.<br>
    Ne pas répondre à cet email.</p>
  </div>

</div>
</body>
</html>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Holcim - Refus de validation</title>
  <style>
    /* Base styles - inline-block friendly for email clients */
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background: #f1f5f9;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 580px;
      margin: 40px auto;
      background: white;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 24px rgba(0,0,0,0.06);
    }
    .header {
      padding: 32px 36px;
      background: linear-gradient(135deg, #0d7377 0%, #1a4a6b 100%);
      text-align: center;
    }
    .header-logo {
      font-size: 0.75rem;
      font-weight: 800;
      letter-spacing: 3px;
      color: rgba(255,255,255,0.6);
      text-transform: uppercase;
      margin-bottom: 6px;
    }
    .header h1 {
      color: white;
      margin: 0;
      font-size: 1.15rem;
      font-weight: 700;
    }
    .header p {
      color: rgba(255,255,255,0.65);
      margin: 6px 0 0;
      font-size: 0.82rem;
      font-weight: 400;
    }
    /* Refused status bar (like original but refined) */
    .refused-bar {
      height: 5px;
      background-color: #dc2626;
    }
    .body {
      padding: 32px 36px;
    }
    .body p {
      color: #475569;
      font-size: 0.92rem;
      line-height: 1.65;
      margin: 0 0 16px;
    }
    .body strong {
      color: #0f172a;
    }
    .info-card {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      margin: 24px 0;
      overflow: hidden;
    }
    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 13px 20px;
      border-bottom: 1px solid #e2e8f0;
      font-size: 0.85rem;
    }
    .info-row:last-child {
      border-bottom: none;
    }
    .info-row:nth-child(even) {
      background: #ffffff;
    }
    .info-label {
      color: #94a3b8;
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .info-label svg {
      width: 16px;
      height: 16px;
      opacity: 0.5;
    }
    .info-value {
      color: #0f172a;
      font-weight: 600;
    }
    /* Refus box - specific red card for refusal motive */
    .refus-box {
      background: #fef2f2;
      border: 1px solid #fecaca;
      border-radius: 12px;
      padding: 18px 20px;
      margin: 24px 0;
    }
    .refus-box .refus-title {
      color: #dc2626;
      font-weight: 700;
      font-size: 0.85rem;
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .refus-box .refus-title svg {
      width: 18px;
      height: 18px;
    }
    .refus-box .refus-motif {
      color: #374151;
      font-size: 0.875rem;
      line-height: 1.55;
      margin: 0;
    }
    /* Notice styling (used for refusal context if needed) */
    .notice {
      font-size: 0.76rem;
      color: #94a3b8;
      margin-top: 8px;
      padding: 0 4px;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .notice svg {
      width: 14px;
      height: 14px;
      flex-shrink: 0;
    }
    .footer {
      padding: 20px 36px;
      background: #fafbfc;
      border-top: 1px solid #f1f5f9;
      text-align: center;
    }
    .footer p {
      color: #94a3b8;
      font-size: 0.72rem;
      margin: 0;
      letter-spacing: 0.2px;
    }
    /* Mobile responsiveness */
    @media (max-width: 600px) {
      .container {
        margin: 20px auto;
      }
      .header {
        padding: 24px 20px;
      }
      .body {
        padding: 24px 20px;
      }
      .footer {
        padding: 16px 20px;
      }
      .info-row {
        flex-direction: column;
        align-items: flex-start;
        gap: 6px;
      }
    }
  </style>
</head>
<body>
<div class="container">

  <!-- Header inspired by the second email design exactly (gradient, logo, title) 
       but adapted to refusal notification context -->
  <div class="header" style="background: linear-gradient(135deg, #0d7377 0%, #1a4a6b 100%); background-color: #0d7377;">
    <div class="header-logo">HOLCIM</div>
    <h1>Portail Habilitations</h1>
    <p>Notification de refus de validation</p>
  </div>

  <!-- Refusal Red Bar (keeping original concept but integrated elegantly) -->
  <div class="refused-bar"></div>

  <div class="body">
    <!-- Personalized greeting -->
    <p>Bonjour,</p>
    <p>
      La validation de l'habilitation suivante a été <strong style="color:#dc2626;">refusée</strong>
      par <strong>{{ $validation->signataire_nom }}</strong>
      (
      {{
      $validation->role === 'employe' ? 'Salarié' :
           (
       $validation->role === 'manager_service' ? 'Responsable de service' :
         ($validation->role === 'manager_departement' ? 'Responsable de département' :
         ($validation->role === 'resp_sst' ? 'Responsable Santé Sécurité' : 'Directeur d\'usine'))) }}).
    </p>

    @php $eh = $validation->employeeHabilitation; @endphp

    <!-- Information card with consistent modern design & SVG icons (same as second email) -->
    <div class="info-card">
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
            <circle cx="12" cy="7" r="4"/>
          </svg>
          Employé
        </span>
        <span class="info-value">{{ $eh->employee->prenom }} {{ $eh->employee->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="2" y="4" width="20" height="16" rx="2"/>
            <path d="M7 8h4M7 12h10M7 16h6"/>
          </svg>
          Matricule
        </span>
        <span class="info-value">{{ $eh->employee->matricule ?? 'Sous-traitant' }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
          </svg>
          Habilitation
        </span>
        <span class="info-value">{{ $eh->habilitation->nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2"/>
            <path d="M16 2v4M8 2v4M3 10h18"/>
          </svg>
          Date d'obtention
        </span>
        <span class="info-value">{{ $eh->date_obtention->format('d/m/Y') }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="18" rx="2"/>
            <path d="M16 2v4M8 2v4M3 10h18"/>
          </svg>
          Date d'expiration
        </span>
        <span class="info-value">{{ $eh->date_expiration->format('d/m/Y') }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
          Signataire
        </span>
        <span class="info-value">{{ $validation->signataire_nom }}</span>
      </div>
      <div class="info-row">
        <span class="info-label">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/>
            <polyline points="12 6 12 12 16 14"/>
          </svg>
          Date du refus
        </span>
        <span class="info-value">{{ $validation->confirmed_at->format('d/m/Y') }}</span>
      </div>
    </div>

  
    
 

    <p>Veuillez vous connecter à l'application pour prendre les mesures nécessaires ou contacter le responsable habilitations.</p>

    <!-- Notice / secure message with lock icon (consistent with second email design) -->
    <div class="notice">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <rect x="3" y="11" width="18" height="11" rx="2"/>
        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
      </svg>
      Cet email est une notification automatique. Aucune action directe n'est requise via ce message.
    </div>
  </div>

  <div class="footer">
    <p>Portail Habilitations Holcim — Email automatique, ne pas répondre.</p>
  </div>

</div>
</body>
</html>

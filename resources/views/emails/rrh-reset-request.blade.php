<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<style>
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

  .icon {
    text-align: center;
    margin: 24px 0;
  }

  .icon svg {
    width: 48px;
    height: 48px;
    background: #e6f4f1;
    border-radius: 50%;
    padding: 10px;
    fill: #0d7377;
  }

  .body {
    padding: 0 36px 32px;
  }

  .body p {
    color: #475569;
    font-size: 0.92rem;
    line-height: 1.65;
    margin: 0 0 16px;
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

  .info-label {
    color: #64748b;
    font-weight: 500;
  }

  .info-value {
    color: #0f172a;
    font-weight: 600;
  }

  .btn-confirm {
    display: block;
   
    padding: 13px 20px;
    background: #25935f;
    color: white;
    text-decoration: none;
    border-radius: 10px;
    text-align: center;
    font-weight: 700;
    font-size: 0.88rem;
    margin-top: 20px;
    transition: background 0.2s;
  }

  .notice {
    font-size: 0.76rem;
    color: #94a3b8;
    margin-top: 12px;
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .footer {
    padding: 16px 36px;
    background: #fafbfc;
    border-top: 1px solid #f1f5f9;
    text-align: center;
  }

  .footer p {
    color: #94a3b8;
    font-size: 0.72rem;
    margin: 0;
  }

  @media (max-width: 600px) {
    .container { margin: 20px auto; }
    .body { padding: 0 20px 24px; }
    .footer { padding: 12px 20px; }
    .info-row { flex-direction: column; align-items: flex-start; gap: 6px; }
  }
</style>
</head>
<body>
<div class="container">
  <div class="header"  style="background: linear-gradient(135deg, #0d7377 0%, #1a4a6b 100%); background-color: #0d7377;">
    <div class="header-logo">HOLCIM</div>
    <h1>Portail Habilitations</h1>
    <p>Réinitialisation de mot de passe</p>
  </div>

  <div class="icon">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
      <path d="M12 17a2 2 0 1 0 0-4 2 2 0 0 0 0 4zm6-6V9a6 6 0 1 0-12 0v2H4v10h16V11h-2zm-8-2a4 4 0 0 1 8 0v2H10V9z"/>
    </svg>
  </div>

  <div class="body">
    <p>Bonjour,</p>
    <p>L’employé ci-dessous a demandé la réinitialisation de son mot de passe. Cliquez sur le bouton pour accéder à la plateforme et définir un nouveau mot de passe.</p>

    <div class="info-card">
      <div class="info-row">
        <div class="info-label">Employé</div>
        <div class="info-value">{{ $user->nom }} {{ $user->prenom }}</div>
      </div>
      <div class="info-row">
        <div class="info-label">Rôle</div>
        <div class="info-value">{{ $user->role }}</div>
      </div>
      
    </div>

    <a href="http://holcim.local/login" class="btn-confirm">Réinitialiser le mot de passe</a>

    <div class="notice">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
      </svg>
      <span>Ce lien est à usage unique et sécurisé. Si vous n’êtes pas à l’origine de cette demande, ignorez simplement cet email.</span>
    </div>
  </div>

  <div class="footer">
    <p>Portail Habilitations Holcim — Email automatique, ne pas répondre.</p>
  </div>
</div>
</body>
</html>

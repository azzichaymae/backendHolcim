<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Votre mot de passe a été modifié</title>
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
    margin: 28px 0 20px;
  }

  .icon-circle {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 56px;
    height: 56px;
    background: #e6f4f1;
    border-radius: 50%;
  }

  .icon-circle img {
    width: 26px;
    height: 26px;
    /* fill: #0d7377; */
  }

  .body {
    padding: 0 36px 28px;
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
    margin: 20px 0;
    overflow: hidden;
    border-collapse: collapse;
    width: 100%;
  }

  .info-table {
    width: 100%;
    border-collapse: collapse;
  }

  .info-table td {
    padding: 14px 20px;
    font-size: 0.85rem;
    border-bottom: 1px solid #e2e8f0;
    vertical-align: middle;
  }

  .info-table tr:last-child td {
    border-bottom: none;
  }

  .info-label {
    color: #475569;
    font-weight: 600;
    white-space: nowrap;
    width: 1%;
  }

  .info-label-inner {
    display: inline-flex;
    align-items: center;
    gap: 8px;
  }

  .info-label svg {
    width: 15px;
    height: 15px;
    fill: #64748b;
    flex-shrink: 0;
    vertical-align: middle;
  }

  .info-value {
    color: #0f172a;
    font-weight: 600;
    text-align: right;
  }

  .password-box {
    background: #f1f5f9;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    padding: 5px 12px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 0.9rem;
    display: inline-block;
    color: #0f172a;
  }

  .btn-confirm {
    display: block;
    margin: 22px auto 0;
    padding: 14px 20px;
    background: #25935f;
    color: white !important;
    text-decoration: none;
    border-radius: 10px;
    text-align: center;
    font-weight: 700;
    font-size: 0.9rem;
    transition: background 0.2s;
  }

  .security-note {
    background: #f0fdf4;
    border: 1px solid #bbf7d0;
    border-radius: 10px;
    padding: 12px 16px;
    font-size: 0.82rem;
    color: #166534;
    display: flex;
    align-items: flex-start;
    gap: 9px;
    margin-top: 18px;
    line-height: 1.5;
  }

  .security-note svg {
    width: 16px;
    height: 16px;
    fill: #166534;
    flex-shrink: 0;
    margin-top: 1px;
  }

  .confidential-note {
    display: flex;
    align-items: center;
    gap: 7px;
    margin-top: 18px;
    font-size: 0.8rem;
    color: #94a3b8;
  }

  .confidential-note svg {
    width: 14px;
    height: 14px;
    fill: #94a3b8;
    flex-shrink: 0;
  }

  .footer {
    padding: 14px 36px;
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
  <div class="header">
    <div class="header-logo">HOLCIM</div>
    <h1>Portail Habilitations</h1>
    <p>Votre mot de passe a été modifié</p>
  </div>

  <div class="icon">
    
  </div>

  <div class="body">
    <p>Bonjour <strong>{{ $user->name }}</strong>,</p>
    <p>Le RRH a réinitialisé votre mot de passe. Veuillez utiliser les identifiants ci-dessous pour vous connecter à la plateforme.</p>

    <div class="info-card">
      <table class="info-table">
        <tr>
          <td class="info-label">
            <span class="info-label-inner">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/></svg>
              Utilisateur
            </span>
          </td>
          <td class="info-value">{{ $user->nom }} {{ $user->prenom }}</td>
        </tr>
        <tr>
          <td class="info-label">
            <span class="info-label-inner">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12.65 10A6 6 0 1 0 14 13.35L14 14h-2v2H10v2H7v-2H5v-2.17l3.35-3.35A6 6 0 0 0 12.65 10zM18 8a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg>
              Nouveau mot de passe
            </span>
          </td>
          <td class="info-value"><span class="password-box">{{ $password }}</span></td>
        </tr>
      </table>
    </div>

    <a href="http://holcim.local/login" class="btn-confirm">Se connecter</a>

    <div class="security-note">
      <!-- Shield icon -->
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 4a3 3 0 1 1 0 6 3 3 0 0 1 0-6zm0 14c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08A7.24 7.24 0 0 1 12 19z"/>
      </svg>
<span>Ce mot de passe a été défini par le RRH. Veuillez l’utiliser pour accéder à la plateforme.</span>    </div>

    <div class="confidential-note">
      <!-- Lock icon -->
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
      </svg>
      Cet email contient des informations confidentielles. Ne le partagez avec personne.
    </div>
  </div>

  <div class="footer">
    <p>Portail Habilitations Holcim — Email automatique, ne pas répondre.</p>
  </div>
</div>
</body>
</html>
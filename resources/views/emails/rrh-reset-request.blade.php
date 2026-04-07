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
     .btn-group { display: flex; gap: 12px; margin: 24px 10px; }
     .btn-confirm { padding: 10px 20px; background: #16a         
34a; color: white;
                    text-decoration: none; border-radius: 8px;
                    font-weight: 700; font-size: 0.9rem; }  
     .btn-refuse  { padding: 10px 20px; background: #dc2626; color: white;
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
    <p>Demande de réinitialisation de mot de passe</p>
  </div>
  <div class="body">
    <p>Bonjour,</p>
    <p>L'employé {{ $user->nom }} {{ $user->prenom }} a demandé à réinitialiser son mot de passe. Cliquez sur le bouton ci-dessous pour choisir un nouveau mot de passe :</p>

    <div class="btn-group">
      <a href="#" class="btn-confirm">Réinitialiser le mot de passe</a>
    </div>
  </div>
  <div class="footer">
    <p>Portail Habilitations Holcim - &copy; {{ date('Y') }}</p>
  </div>
</div>
</body>
</html>
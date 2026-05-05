<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Refus enregistré</title>
  <style>
    body { font-family: Arial, sans-serif; background: #f1f5f9; display: flex;
           align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: white; border-radius: 16px; padding: 48px 40px;
            max-width: 480px; width: 90%; text-align: center;
            box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
    .icon { width: 64px; height: 64px; background: #fef2f2; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px; font-size: 28px; }
    h2 { color: #dc2626; margin: 0 0 10px; font-size: 1.3rem; }
    p  { color: #64748b; font-size: 0.9rem; line-height: 1.6; margin: 0; }
    .footer { margin-top: 24px; font-size: 0.72rem; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">✗</div>
    <h2>Refus enregistré</h2>
    <p>Bonjour <strong>{{ $signataire }}</strong>,<br>
       votre refus a bien été enregistré.<br>
       Les responsables RH ont été notifiés.</p>
    <div class="footer">
      Portail Habilitations Holcim — Email automatique, ne pas répondre.
    </div>
  </div>
</body>
</html>
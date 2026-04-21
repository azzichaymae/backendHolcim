<!DOCTYPE html>
<html>
<head>
    <title>Votre mot de passe a été modifié</title>
</head>
<body>
    <h2>Bonjour {{ $user->name }},</h2>
    
    <p>Le RRH a modifié votre mot de passe.</p>
    
    <p><strong>Votre nouveau mot de passe est :</strong> {{ $password }}</p>
    
    <p>Veuillez vous connecter avec ce mot de passe.</p>
    
    <a href="holcim.local/login" style="padding: 10px 20px; background: #4CAF50; color: white; text-decoration: none;">
        Se connecter
    </a>
    
    <p>Cordialement,<br>L'équipe RH</p>
</body>
</html>
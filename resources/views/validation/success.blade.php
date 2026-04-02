<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Validation réussie</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap (optional but nice) -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f5f7fa;
        }
        .card {
            border-radius: 12px;
        }
    </style>
</head>
<body>

<div class="d-flex justify-content-center align-items-center vh-100">
    <div class="card shadow p-4 text-center" style="max-width: 500px; width:100%;">
        
        <!-- Icon -->
        <div class="mb-3">
            <span style="font-size:60px; color:green;">✔</span>
        </div>

        <!-- Title -->
        <h3 class="text-success">Habilitation validée !</h3>
        <p class="text-muted">Votre validation a été enregistrée avec succès.</p>

        <!-- Recap (dynamic from backend) -->
        <div class="border rounded p-3 text-start mt-3">
            <p><strong>Employé:</strong> {{ $employee }}</p>
            <p><strong>Matricule:</strong> {{ $matricule }}</p>
            <p><strong>Habilitation:</strong> {{ $habilitation }}</p>
            <p><strong>Date d'obtention:</strong> {{ $obtention }}</p>
            <p><strong>Date d'expiration:</strong> {{ $expiration }}</p>
        </div>

        <!-- Info -->
        <p class="text-muted mt-3" style="font-size: 14px;">
            Cette action est définitive et ne peut pas être modifiée.
        </p>

    </div>
</div>

</body>
</html>
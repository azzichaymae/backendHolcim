<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            color: #000;
            padding: 40px;
            line-height: 1.6;
        }
        .title {
            text-align: center;
            font-size: 15px;
            font-weight: bold;
            text-decoration: underline;
            margin-bottom: 4px;
            text-transform: uppercase;
        }
        .subtitle {
            text-align: center;
            font-size: 13px;
            font-weight: bold;
            text-decoration: underline;
            margin-bottom: 30px;
            text-transform: uppercase;
        }
        .body-text {
            text-align: justify;
            margin-bottom: 16px;
        }
        .section-label {
            font-weight: bold;
            margin-bottom: 8px;
        }
        .employees-table {
            width: 100%;
            border-collapse: collapse;
            margin: 16px 0 24px 0;
        }
        .employees-table th {
            background-color: #cccccc;
            border: 1px solid #000;
            padding: 6px 4px;
            text-align: center;
            font-weight: bold;
            font-size: 11px;
        }
        .employees-table td {
            border: 1px solid #000;
            padding: 5px 4px;
            text-align: center;
            font-size: 11px;
        }
        .employees-table tr:nth-child(even) td {
            background-color: #f5f5f5;
        }
        .validity {
            text-align: justify;
            margin-bottom: 50px;
        }
        .signature-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .signature-table td {
            width: 50%;
            text-align: center;
            padding: 10px;
            vertical-align: top;
        }
        .sig-title {
            font-weight: bold;
            margin-bottom: 40px;
        }
        .sig-name { font-weight: bold; }
        .bold { font-weight: bold; }
    </style>
</head>
<body>

    <div class="title">Note d'Habilitation</div>
    <div class="subtitle">{{ $habilitation->nom }}</div>

    <div class="body-text">
        Je soussigné M. <span class="bold">{{ $settings->directeur_usine }}</span>,
        en qualité de {{ $settings->titre_directeur }} de la {{ $settings->site }},
        atteste par le présent document que les personnes ci-dessous sont habilitées
        à <span class="bold">{{ $habilitation->nom }}</span>.
    </div>

    <div class="section-label">- Personnel {{ $settings->societe }} :</div>

    <table class="employees-table">
        <thead>
            <tr>
                <th>Matricule</th>
                <th>Nom &amp; Prénom</th>
                <th>Fonction</th>
                <th>Service</th>
                <th>Date Obtention</th>
                <th>Date Expiration</th>
                <th>Statut</th>
            </tr>
        </thead>
        <tbody>
            @forelse($employeeHabilitations as $eh)
            <tr>
                <td>{{ $eh->employee->matricule }}</td>
                <td>
                    {{ strtoupper($eh->employee->nom) }}
                    {{ $eh->employee->prenom }}
                </td>
                <td>{{ $eh->employee->position }}</td>
                <td>{{ $eh->employee->service->nom }}</td>
                <td>{{ $eh->date_obtention->format('d/m/Y') }}</td>
                <td>{{ $eh->date_expiration->format('d/m/Y') }}</td>
                <td>{{ ucfirst($eh->statut) }}</td>
            </tr>
            @empty
            <tr>
                <td colspan="7">Aucun employé habilité.</td>
            </tr>
            @endforelse
        </tbody>
    </table>

    <div class="validity">
        Cette habilitation est valable pour une durée de
        <span class="bold">{{ $habilitation->duree_de_validite }} ans</span>,
        avec une réévaluation des compétences obligatoire d'une durée de
        <span class="bold">
            {{ $habilitation->duree_formation_recyclage }}
            {{ $habilitation->duree_formation_recyclage_unite }}
        </span>.
    </div>

    <table class="signature-table">
        <tr>
            <td>
                <div class="sig-title">Responsable Santé Sécurité</div>
                <div class="sig-name">{{ $settings->resp_sante_securite }}</div>
            </td>
            <td>
                <div class="sig-title">{{ $settings->titre_directeur }}</div>
                <div class="sig-name">{{ $settings->directeur_usine }}</div>
            </td>
        </tr>
    </table>

</body>
</html>
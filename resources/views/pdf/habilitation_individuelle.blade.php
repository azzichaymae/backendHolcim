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
            margin-bottom: 30px;
            text-transform: uppercase;
        }
        .body-text {
            text-align: justify;
            margin-bottom: 16px;
        }
        .list {
            margin-left: 40px;
            margin-bottom: 16px;
        }
        .list-item { margin-bottom: 4px; }
        .section-number {
            font-weight: bold;
            margin-bottom: 8px;
        }
        .authorization {
            text-align: justify;
            margin-top: 20px;
            margin-bottom: 16px;
        }
        .validity {
            text-align: justify;
            margin-bottom: 30px;
        }
        .signature-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 50px;
        }
        .signature-table td {
            border: 1px solid #000;
            padding: 10px 6px;
            text-align: center;
            width: 20%;
            vertical-align: top;
            font-size: 11px;
        }
        .sig-title {
            font-weight: normal;
            margin-bottom: 35px;
        }
        .sig-name { font-weight: bold; }
        .bold { font-weight: bold; }
    </style>
</head>
<body>

    <div class="title">
        Habilitation {{ $eh->habilitation->nom }}
    </div>

    <div class="body-text">
        Je soussigné M. <span class="bold">{{ $settings->directeur_usine }}</span>,
        en qualité de {{ $settings->titre_directeur }} de la {{ $settings->site }},
        atteste par le présent document que
        <span class="bold">M. {{ strtoupper($eh->employee->nom) }} {{ $eh->employee->prenom }}</span>
        répond aux conditions suivantes :
    </div>

    <div class="section-number">1. Participation à la formation suivante :</div>
    <div class="list">
        <div class="list-item">
            - Thème de la Formation :
            <span class="bold">{{ $eh->habilitation->nom }}</span>
        </div>
        <div class="list-item">
            - Date de la Formation :
            <span class="bold">{{ $eh->date_obtention->format('d/m/Y') }}</span>
        </div>
        <div class="list-item">
            - Durée de la Formation :
            <span class="bold">
                @if($eh->type === 'initiale')
                    {{ $eh->habilitation->duree_formation_initiale }}
                    {{ $eh->habilitation->duree_formation_initiale_unite }}
                @else
                    {{ $eh->habilitation->duree_formation_recyclage }}
                    {{ $eh->habilitation->duree_formation_recyclage_unite }}
                @endif
            </span>
        </div>
        <div class="list-item">
            - Organisme de Formation :
            <span class="bold">{{ $eh->organisme_formation }}</span>
        </div>
    </div>

    <div class="body-text">
        <span class="bold">2.</span>
        Aptitude médicale délivrée par le Docteur
        <span class="bold">{{ $settings->medecin }}</span>,
        Médecin de Travail, en date du
        <span class="bold">{{ $eh->date_aptitude_medicale->format('d/m/Y') }}</span>
    </div>

    <div class="authorization">
        En foi de quoi, et dans le cadre de ses activités professionnelles au sein de
        {{ $settings->societe }}, {{ $settings->site }},
        j'autorise
        <span class="bold">
            M. {{ strtoupper($eh->employee->nom) }} {{ $eh->employee->prenom }}
            à effectuer les Travaux en tant que {{ $eh->habilitation->nom }}
        </span>.
    </div>

    <div class="validity">
        Cette habilitation est valable à partir du
        <span class="bold">{{ $eh->date_obtention->format('d/m/Y') }}</span>,
        avec une réévaluation des compétences obligatoire d'une durée de
        <span class="bold">
            {{ $eh->habilitation->duree_formation_recyclage }}
            {{ $eh->habilitation->duree_formation_recyclage_unite }}
        </span>
        chaque
        <span class="bold">{{ $eh->habilitation->duree_de_validite }} ans</span>.
    </div>

    <table class="signature-table">
        <tr>
            <td>
                <div class="sig-title">Intéressé</div>
                <div class="sig-name">
                    {{ strtoupper($eh->employee->nom) }}<br>
                    {{ $eh->employee->prenom }}
                </div>
            </td>
            <td>
                <div class="sig-title">Responsable<br>Maintenance<br>Électrique</div>
                <div class="sig-name">{{ $settings->resp_maintenance_elec }}</div>
            </td>
            <td>
                <div class="sig-title">Responsable<br>Maintenance</div>
                <div class="sig-name">{{ $settings->resp_maintenance }}</div>
            </td>
            <td>
                <div class="sig-title">Responsable<br>Santé Sécurité</div>
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
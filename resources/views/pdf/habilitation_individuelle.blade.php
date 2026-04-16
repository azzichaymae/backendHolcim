<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="UTF-8">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Times New Roman", Times, serif;
            font-size: 11pt;
            color: #000;
            line-height: 1.5;
        }

        /* ── Page layout ── */
        .page {
            padding: 2cm 2.5cm 2cm 2.5cm;
            /* Word margins */
        }

        /* ── Header with logo ── */
        .header-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }

        .header-table td {
            vertical-align: middle;
            border: none;
            text-align: center;
        }

        .logo-cell img {
            width: 150px;
            height: auto;
        }

        .header-divider {
            border-top: solid #000;
            margin-bottom: 24px;
        }

        /* ── Title ── */
        .title {
            text-align: center;
            font-size: 14pt;
            font-weight: bold;
            text-decoration: underline;
            text-transform: uppercase;
            margin: 30px 0 28px 0;
            letter-spacing: 0.5px;
        }

        /* ── Body text ── */
        .body-text {
            text-align: justify;
            margin-bottom: 14px;
            font-size: 11pt;
            word-spacing: 7px;
            /* mimic Word spacing */
        }

        /* ── Numbered section ── */
        .section {
            margin: 15px 0 14px 15px;
        }

        .section-title {
            margin-bottom: 6px;
        }

        .section-list {
            margin-left: 50px;
        }

        .section-list .item {
            margin-bottom: 3px;
        }

        /* ── Authorization ── */
        .authorization {
            text-align: justify;
            margin: 18px 0 14px 0;
            word-spacing: 7px;
        }

        /* ── Validity ── */
        .validity {
            text-align: justify;
            margin: 30px 0;
            word-spacing: 7px;
        }

        /* ── Signature table ── */
        .signature-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 50px;
        }

        .signature-table td {
            border: 1px solid #000;
            /* thicker like Word */
            padding: 8px 6px 30px 6px;
            text-align: center;
            width: 20%;
            vertical-align: top;
            font-size: 10pt;
            line-height: 1.4;
        }

        .sig-role {
            font-weight: normal;
            font-size: 10pt;
            min-height: 40px;
        }

        .sig-name {
            font-weight: bold;
            margin-top: 8px;
            font-size: 10pt;
        }

        .bold {
            font-weight: bold;
        }

        .underline {
            text-decoration: underline;
        }
    </style>
</head>

<body>
    <div class="page">

        <!-- Logo -->
        <table class="header-table">
            <tr>
                <td class="logo-cell">
                    <img src="{{ public_path('images/holcim_logo.png') }}" alt="Holcim" />
                </td>
            </tr>
        </table>

        <!-- Title -->
        <div class="title">
            Habilitation {{ $eh->habilitation->nom }}
        </div>

        <!-- Opening paragraph -->
        <div class="body-text">
            Je soussigné M. <span class="bold">{{ $settings->directeur_usine }}</span>,
            en qualité de {{ $settings->titre_directeur }} de la {{ $settings->site }},
            par le présent document que
            M. <span class="bold">{{ strtoupper($eh->employee->nom) }} {{ $eh->employee->prenom }}</span>
            répond aux conditions suivantes :
        </div>

        <!-- Section 1 -->
        <div class="section">
            <div class="section-title">1. Participation à la formation suivante :</div>
            <div class="section-list">
                <div class="item">- Thème de la Formation : <span class="bold">{{ $eh->habilitation->nom }}</span></div>
                <div class="item">- Date de la Formation : <span
                        class="bold">{{ $eh->date_obtention->translatedFormat('d F Y') }}</span></div>
                <div class="item">- Durée de la Formation : <span class="bold">
                        @if($eh->type === 'initiale')
                            {{ $eh->habilitation->duree_formation_initiale }}
                            {{ $eh->habilitation->duree_formation_initiale_unite }}
                        @else
                            {{ $eh->habilitation->duree_formation_recyclage }}
                            {{ $eh->habilitation->duree_formation_recyclage_unite }}
                        @endif
                    </span></div>
                <div class="item">- Organisme de Formation : <span class="bold">{{ $eh->organisme_formation }}</span>
                </div>
            </div>
        </div>

        <!-- Section 2 -->
        <div class="body-text" style="margin-left:15px;">
            <span>2. </span>
            Aptitude médicale délivrée par le Docteur
            <span class="bold">{{ $settings->medecin }}</span>,
            Médecin de Travail, en date du
            <span class="bold">{{ $eh->date_aptitude_medicale->translatedFormat('d F Y') }}</span>
        </div>

        <!-- Authorization -->
        <div class="authorization">
            En foi de quoi, et dans le cadre de ses activités professionnelles
            au sein de {{ $settings->societe }}, {{ $settings->site }},
            j'autorise M.
            <span class="bold">{{ strtoupper($eh->employee->nom) }} {{ $eh->employee->prenom }}</span>
            <span class="bold">à effectuer {{ $eh->habilitation->texte_autorisation }}</span>.
        </div>

        <!-- Validity -->
        <div class="validity">
            Cette habilitation est valable à partir du
            <span class="bold">{{ $eh->date_obtention->translatedFormat('d F Y') }}</span>,
            avec une réévaluation des compétences obligatoire d'une durée de
            <span class="bold">{{ $eh->habilitation->duree_formation_recyclage }}
                {{ $eh->habilitation->duree_formation_recyclage_unite }}</span>
            chaque <span class="bold">{{ $eh->habilitation->duree_de_validite }} ans</span>.
        </div>

        <!-- Signature table -->
        <table class="signature-table">
            <tr>
                <td>
                    <div class="sig-role">Intéressé</div>
                    <div class="sig-name">{{ strtoupper($eh->employee->nom) }}<br>{{ $eh->employee->prenom }}</div>
                </td>
                <td>
                    <div class="sig-role">Responsable<br>{{ $eh->employee->service->nom }}</div>
                    <div class="sig-name">{{ $eh->employee->service->responsable }}</div>
                </td>
                <td>
                    <div class="sig-role">Responsable<br>{{ $eh->employee->service->departement->nom }}</div>
                    <div class="sig-name">{{ $eh->employee->service->departement->responsable }}</div>
                </td>
                <td>
                    <div class="sig-role">Responsable<br>Santé Sécurité</div>
                    <div class="sig-name">{{ $settings->resp_sante_securite }}</div>
                </td>
                <td>
                    <div class="sig-role">{{ $settings->titre_directeur }}</div>
                    <div class="sig-name">{{ $settings->directeur_usine }}</div>
                </td>
            </tr>
   @if($validation && isset($validation->etapes))
    <tr>
        <td id="emp">
            {{ isset($validation->etapes[0]) && $validation->etapes[0]->confirmed_at 
                ? 'Validé le '. \Carbon\Carbon::parse($validation->etapes[0]->confirmed_at)->format('d/m/Y') 
                : '' }}
        </td>
        <td id="respService">
            {{ isset($validation->etapes[1]) && $validation->etapes[1]->confirmed_at 
                ? 'Validé le '. \Carbon\Carbon::parse($validation->etapes[1]->confirmed_at)->format('d/m/Y') 
                : '' }}
        </td>
        <td id="respDepartement">
            {{ isset($validation->etapes[2]) && $validation->etapes[2]->confirmed_at 
                ? 'Validé le '. \Carbon\Carbon::parse($validation->etapes[2]->confirmed_at)->format('d/m/Y') 
                : '' }}
        </td>
        <td id="respSanteSecurite">
            {{ isset($validation->etapes[3]) && $validation->etapes[3]->confirmed_at 
                ? 'Validé le '. \Carbon\Carbon::parse($validation->etapes[3]->confirmed_at)->format('d/m/Y') 
                : '' }}
        </td>
        <td id="directeurUsine">
            {{ isset($validation->etapes[4]) && $validation->etapes[4]->confirmed_at 
                ? 'Validé le '. \Carbon\Carbon::parse($validation->etapes[4]->confirmed_at)->format('d/m/Y') 
                : '' }}
        </td>
    </tr>
@else
    <tr>
        <td id="emp"></td>
        <td id="respService"></td>
        <td id="respDepartement"></td>
        <td id="respSanteSecurite"></td>
        <td id="directeurUsine"></td>
    </tr>
@endif

        </table>

    </div>
</body>

</html>
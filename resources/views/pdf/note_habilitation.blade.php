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
 .logo-cell img {
            width: 150px;
            height: auto;
        }
       body {
            font-family: "Times New Roman", Times, serif;
            font-size: 11pt;
            color: #000;
            line-height: 1.5;
        }

        .page {
            padding: 2cm 2.5cm 2cm 2.5cm;
        }

        /* ── Header blue line ── */
        .header-divider {
            border-top: 3px solid #0070C0;
            margin-bottom: 24px;
        }

        /* ── Titles ── */
        .title {
            text-align: center;
            font-size: 14pt;
            font-weight: bold;
            text-decoration: underline;
            text-transform: uppercase;
            margin-bottom: 4px;
            letter-spacing: 0.5px;
        }

        .subtitle {
            text-align: center;
            font-size: 12pt;
            font-weight: bold;
            text-decoration: underline;
            text-transform: uppercase;
            margin-bottom: 28px;
        }

        /* ── Body text ── */
        .body-text {
            text-align: justify;
            margin-bottom: 14px;
            font-size: 11pt;
        }

        /* ── Section label ── */
        .section-label {
            margin-bottom: 10px;
            margin-top: 20px;
            font-size: 11pt;
        }

        /* ── Employees table ── */
        .employees-table {
            width: 100%;
            border-collapse: collapse;
            margin: 0 0 20px 0;
            font-size: 10pt;
        }

        .employees-table th {
            background-color: #b6b7b8e1;
            border: 1px solid #000;
            padding: 6px 5px;
            text-align: center;
            font-weight: bold;
            font-size: 10pt;
        }

        .employees-table td {
            border: 1px solid #000;
            padding: 5px;
            text-align: center;
            font-size: 10pt;
        }

        .employees-table tr:nth-child(even) td {
            background-color: #DEEAF1;
        }

        .employees-table .num-col {
            width: 30px;
            text-align: center;
        }

        /* ── Validity ── */
        .validity {
            text-align: justify;
            margin-bottom: 50px;
            font-size: 11pt;
        }

        /* ── Signature block ── */
        .signature-wrapper {
            width: 100%;
            margin-top: 20px;
        }

        .signature-wrapper table {
            width: 100%;
            border-collapse: collapse;
        }

        .signature-wrapper td {
            width: 50%;
            text-align: center;
            padding: 0 20px;
            vertical-align: top;
        }
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

        .sig-role {
            font-weight: bold;
            font-size: 11pt;
            text-decoration: underline;
            margin-bottom: 40px;
        }

        .sig-name {
            font-weight: bold;
            font-size: 11pt;
        }

        .bold {
            font-weight: bold;
        }
        .page-break {
    page-break-before: always; /* forces new page */
}
    </style>
</head>

<body>

    @php $pr = $employeeHabilitations->filter(fn($eh) => $eh->employee->type === 'propre'); @endphp
    @if($pr->count() > 0)
        <div class="page">
             <table class="header-table">
        <tr>
            <td class="logo-cell">
                <img src="{{ public_path('images/holcim_logoB&W.png') }}" alt="Holcim" />
            </td>
        </tr>
    </table>
            <div class="title">Note d'Habilitation</div>
            <div class="subtitle">{{ $habilitation->nom }}</div>

            <div class="body-text">
                Je soussigné M. <span class="bold">{{ $settings->directeur_usine }}</span>,
                en qualité de {{ $settings->titre_directeur }} de la {{ $settings->site }},
                par le présent document que les personnes ci-dessous sont habilitées
                à <span class="bold">{{ $habilitation->nom }}</span>.
            </div>

            <div class="section-label" style="margin-top:16px;">•  Personnel Propre</div>
            <table class="employees-table">
                <thead>
                    <tr>
                        <th>Matricule</th>
                        <th>Nom & Prénom</th>
                        <th>Fonction</th>
                        <th>Service</th>
                        <th>Société</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($pr->values() as $index => $eh)
                        <tr>
                            <td>{{ $eh->employee->matricule }}</td>
                            <td><span class="bold">{{ strtoupper($eh->employee->nom) }}</span> {{ $eh->employee->prenom }}</td>
                            <td>{{ $eh->employee->position }}</td>
                            <td>{{ $eh->employee->service->nom }}</td>
                            <td>{{ $settings->societe }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>

            <div class="validity">
                Cette habilitation est valable à partir du
                <span class="bold">{{ now()->translatedFormat('d F Y') }}</span>,
                avec une réévaluation des compétences obligatoire d'une durée de
                <span class="bold">{{ $habilitation->duree_formation_recyclage }}
                    {{ $habilitation->duree_formation_recyclage_unite }}</span>
                chaque <span class="bold">{{ $habilitation->duree_de_validite }} ans</span>.
            </div>

            <div class="signature-wrapper">
                <table>
                    <tr>
                        <td style="text-align:left;padding-left:40px;">
                            <div class="sig-role">Responsable Santé Sécurité</div>
                            <div class="sig-name">{{ $settings->resp_sante_securite }}</div>
                        </td>
                        <td style="text-align:right;padding-right:40px;">
                            <div class="sig-role">{{ $settings->titre_directeur }}</div>
                            <div class="sig-name">{{ $settings->directeur_usine }}</div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    @endif

    

    @php $st = $employeeHabilitations->filter(fn($eh) => $eh->employee->type === 'sous-traitant'); @endphp
    @if($st->count() > 0)
    <div class="page-break"></div> 
        <div class="page">
            <table class="header-table">
                <tr>
                    <td class="logo-cell">
                        <img src="{{ public_path('images/holcim_logoB&W.png') }}" alt="Holcim" />
                    </td>
                </tr>
            </table>
            <div class="title">Note d'Autorisation</div>
            <div class="subtitle">{{ $habilitation->nom }}</div>

            <div class="body-text">
                Je soussigné M. <span class="bold">{{ $settings->directeur_usine }}</span>,
                en qualité de {{ $settings->titre_directeur }} de la {{ $settings->site }},
                par le présent document que les personnes ci-dessous sont autorisées
                à <span class="bold">{{ $habilitation->nom }}</span> dans le cadre de leurs activités professionnelles au sein de {{ $settings->societe }} {{ $settings->site }} .
            </div>

            <div class="section-label" style="margin-top:16px;">•  Personnel Sous-Traitant</div>
            <table class="employees-table">
                <thead>
                    <tr>
                        <th>Nom & Prénom</th>
                        <th>Fonction</th>
                        <th>Société</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($st->values() as $index => $eh)
                        <tr>
                            <td>{{ strtoupper($eh->employee->nom) }} {{ $eh->employee->prenom }}</td>
                            <td>{{ $eh->employee->position }}</td>
                            <td>{{ $eh->employee->societe ?? '—' }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>

            <div class="validity">
                Cette autorisation est valable à partir du
                <span class="bold">{{ now()->translatedFormat('d F Y') }}</span>,
                avec une réévaluation des compétences obligatoire d'une durée de
                <span class="bold">{{ $habilitation->duree_formation_recyclage }}
                    {{ $habilitation->duree_formation_recyclage_unite }}</span>
                chaque <span class="bold">{{ $habilitation->duree_de_validite }} ans</span>.
            </div>

            <div class="signature-wrapper">
                <table>
                    <tr>
                        <td style="text-align:left;padding-left:40px;">
                            <div class="sig-role">Responsable Santé Sécurité</div>
                            <div class="sig-name">{{ $settings->resp_sante_securite }}</div>
                        </td>
                        <td style="text-align:right;padding-right:40px;">
                            <div class="sig-role">{{ $settings->titre_directeur }}</div>
                            <div class="sig-name">{{ $settings->directeur_usine }}</div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    @endif
</body>

</html>
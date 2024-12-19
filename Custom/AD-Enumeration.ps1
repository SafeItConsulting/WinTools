# Prérequis : Le module ActiveDirectory doit être installé.

# Vérification du module Active Directory
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Le module ActiveDirectory n'est pas installé. Veuillez l'installer pour continuer." -ForegroundColor Red
    exit
}

# Chemin de sortie des rapports
$reportBasePath = "AD_Reports"
if (-not (Test-Path -Path $reportBasePath)) {
    New-Item -ItemType Directory -Path $reportBasePath | Out-Null
}

# Fonction pour ajouter des sections formatées en tableaux HTML
function Add-TableSection {
    param (
        [string]$Title,
        [array]$Data,
        [string]$SectionId
    )
    if (-not $Data -or $Data.Count -eq 0) {
        # Ajouter une section avec un message "Données indisponibles"
        $global:reportContent += @"
        <div class="section">
            <div class="section-title" onclick="toggleSection('$SectionId')">$Title</div>
            <div class="section-content" id="$SectionId">
                <p>Aucune donnée disponible pour cette section.</p>
            </div>
        </div>
"@
        return
    }

    # Si les données sont disponibles, construire le tableau HTML
    $tableContent = "<table border='1' style='border-collapse: collapse; width: 100%;'><thead><tr>"

    # Génération des en-têtes à partir des propriétés des objets
    $headers = $Data[0].PSObject.Properties.Name
    foreach ($header in $headers) {
        $tableContent += "<th>$header</th>"
    }
    $tableContent += "</tr></thead><tbody>"

    # Génération des lignes du tableau
    foreach ($item in $Data) {
        $tableContent += "<tr>"
        foreach ($header in $headers) {
            $tableContent += "<td>$($item.$header)</td>"
        }
        $tableContent += "</tr>"
    }
    $tableContent += "</tbody></table>"

    # Ajouter le tableau HTML à la section
    $global:reportContent += @"
    <div class="section">
        <div class="section-title" onclick="toggleSection('$SectionId')">$Title</div>
        <div class="section-content" id="$SectionId">$tableContent</div>
    </div>
"@
}

# Fonction pour générer un rapport HTML
function Generate-HTMLReport {
    param (
        [string]$ReportPath,
        [string]$DomainOrForest
    )

    $htmlHeader = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Active Directory - $DomainOrForest</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { margin-bottom: 20px; }
        .section-title { cursor: pointer; font-size: 1.5em; background-color: #f4f4f4; padding: 10px; border: 1px solid #ccc; }
        .section-content { display: none; padding: 10px; border: 1px solid #ccc; border-top: none; }
        table { margin: 10px 0; }
        th, td { padding: 5px; text-align: left; }
        th { background-color: #f4f4f4; }
    </style>
    <script>
        function toggleSection(id) {
            const section = document.getElementById(id);
            section.style.display = section.style.display === "none" ? "block" : "none";
        }
    </script>
</head>
<body>
    <h1>Rapport Active Directory : $DomainOrForest</h1>
"@

    $htmlFooter = @"
</body>
</html>
"@

    # Écriture dans le fichier
    $htmlContent = $htmlHeader + $global:reportContent + $htmlFooter
    $htmlContent | Out-File -Encoding utf8 $ReportPath
    Write-Host "Rapport généré : $ReportPath" -ForegroundColor Green
}

# Fonction pour collecter et structurer les données
function Collect-ADData {
    param (
        [string]$Scope,
        [string]$EntityName
    )

    # Initialiser le contenu du rapport
    $global:reportContent = ""

    # Informations de Domaine/Forêt
    if ($Scope -eq "Domain") {
        $domainInfo = Get-ADDomain -Server $EntityName | Select-Object *
        Add-TableSection -Title "Domain Information ($EntityName)" -Data @($domainInfo) -SectionId "domain-info-$EntityName"
    } elseif ($Scope -eq "Forest") {
        $forestInfo = Get-ADForest -Server $EntityName | Select-Object *
        Add-TableSection -Title "Forest Information ($EntityName)" -Data @($forestInfo) -SectionId "forest-info-$EntityName"
    }

    # Relations de confiance
    $trustInfo = Get-ADTrust -Filter * -Server $EntityName | Select-Object Name, TrustType, TrustDirection, TargetName
    Add-TableSection -Title "Trust Relationships" -Data $trustInfo -SectionId "trust-info-$EntityName"

    # Utilisateurs
    $userInfo = Get-ADUser -Filter * -Properties DisplayName, EmailAddress, LastLogonDate -Server $EntityName |
        Select-Object Name, DisplayName, EmailAddress, LastLogonDate
    Add-TableSection -Title "Users" -Data $userInfo -SectionId "user-info-$EntityName"

    # Groupes
    $groupInfo = Get-ADGroup -Filter * -Properties Description -Server $EntityName |
        Select-Object Name, Description
    Add-TableSection -Title "Groups" -Data $groupInfo -SectionId "group-info-$EntityName"

    # Ordinateurs
    $computerInfo = Get-ADComputer -Filter * -Properties OperatingSystem, LastLogonDate -Server $EntityName |
        Select-Object Name, OperatingSystem, LastLogonDate
    Add-TableSection -Title "Computers" -Data $computerInfo -SectionId "computer-info-$EntityName"

    # Organizational Units
    $ouInfo = Get-ADOrganizationalUnit -Filter * -Server $EntityName |
        Select-Object Name, DistinguishedName
    Add-TableSection -Title "Organizational Units" -Data $ouInfo -SectionId "ou-info-$EntityName"

    # Politique de mot de passe
    $passwordPolicyInfo = Get-ADDefaultDomainPasswordPolicy -Server $EntityName | Select-Object *
    Add-TableSection -Title "Password Policy" -Data @($passwordPolicyInfo) -SectionId "password-policy-$EntityName"
}

# Collecte des domaines et forêts disponibles
Write-Host "Collecte des domaines et forêts disponibles..."
$forests = Get-ADForest
$domains = $forests.Domains

# Générer un rapport par forêt
foreach ($forest in $forests.Name) {
    Write-Host "Collecte des données pour la forêt : $forest"
    Collect-ADData -Scope "Forest" -EntityName $forest
    $forestReportPath = Join-Path $reportBasePath "Forest_Report_$forest.html"
    Generate-HTMLReport -ReportPath $forestReportPath -DomainOrForest $forest
}

# Générer un rapport par domaine
foreach ($domain in $domains) {
    Write-Host "Collecte des données pour le domaine : $domain"
    Collect-ADData -Scope "Domain" -EntityName $domain
    $domainReportPath = Join-Path $reportBasePath "Domain_Report_$domain.html"
    Generate-HTMLReport -ReportPath $domainReportPath -DomainOrForest $domain
}

Write-Host "Tous les rapports ont été générés dans le dossier : $reportBasePath" -ForegroundColor Green

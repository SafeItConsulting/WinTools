# Vérification de PowerView
if (-not (Get-Command Get-NetDomain -ErrorAction SilentlyContinue)) {
    Write-Host "PowerView n'est pas chargé. Veuillez importer PowerView avant d'exécuter ce script." -ForegroundColor Red
    exit
}

# Chemin de sortie des rapports
$reportBasePath = "PowerView_AD_Reports"
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

    # Construire le tableau HTML si des données sont disponibles
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
            $tableContent += "<td>$($

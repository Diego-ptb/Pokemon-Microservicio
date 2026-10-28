# =====================================================================
# Smoke tests (versión PowerShell, para Windows / terminal de VS Code)
# Equivalente a scripts/smoke-test.sh, que es el que usa el pipeline.
#
# Uso:  .\scripts\smoke-test.ps1                 (2 réplicas, puerto 8080)
#       .\scripts\smoke-test.ps1 -Replicas 3 -BaseUrl http://localhost:8081
# =====================================================================
param(
    [string]$BaseUrl = "http://localhost:8080",
    [int]$Replicas = 2,
    [string]$ExpectedCommit = ""
)

$ErrorActionPreference = "Stop"
$script:failed = $false

function Invoke-Api {
    param([string]$Method, [string]$Path, [string]$Body = $null)
    $params = @{ Uri = "$BaseUrl$Path"; Method = $Method; UseBasicParsing = $true }
    if ($Body) { $params.Body = [Text.Encoding]::UTF8.GetBytes($Body); $params.ContentType = "application/json" }
    try {
        $r = Invoke-WebRequest @params
        # PowerShell 5.1 entrega como bytes los tipos que no reconoce como texto
        # (p. ej. application/vnd.spring-boot.actuator.v3+json del actuator)
        $content = $r.Content
        if ($content -is [byte[]]) { $content = [Text.Encoding]::UTF8.GetString($content) }
        return [pscustomobject]@{ Status = [int]$r.StatusCode; Content = $content; Headers = $r.Headers }
    } catch {
        $resp = $_.Exception.Response
        if ($null -eq $resp) { throw }
        return [pscustomobject]@{ Status = [int]$resp.StatusCode; Content = ""; Headers = @{} }
    }
}

function Assert-Status {
    param([int]$Expected, $Response, [string]$What)
    if ($Response.Status -eq $Expected) {
        Write-Host "  [OK]   $What -> HTTP $($Response.Status)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $What -> esperado $Expected, recibido $($Response.Status)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Smoke tests contra $BaseUrl"

# 1. Salud
$r = Invoke-Api GET "/actuator/health"
Assert-Status 200 $r "GET /actuator/health"

# 2. Trazabilidad
$r = Invoke-Api GET "/actuator/info"
Assert-Status 200 $r "GET /actuator/info"
$info = $r.Content | ConvertFrom-Json
Write-Host "         commit desplegado: $($info.app.commit)  entorno: $($info.app.environment)"
if ($ExpectedCommit -and $info.app.commit -ne $ExpectedCommit) {
    Write-Host "  [FAIL] el commit desplegado no coincide con $ExpectedCommit" -ForegroundColor Red; exit 1
}

# 3. CRUD de punta a punta
$name = "smoke-" + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
Assert-Status 200 (Invoke-Api GET "/api/pokemons") "GET /api/pokemons"

$r = Invoke-Api POST "/api/pokemons" "{`"name`":`"$name`",`"type`":`"Test`",`"level`":5}"
Assert-Status 201 $r "POST /api/pokemons"
$id = ($r.Content | ConvertFrom-Json).id

Assert-Status 200 (Invoke-Api GET "/api/pokemons/$id") "GET /api/pokemons/$id"
Assert-Status 200 (Invoke-Api GET "/api/pokemons/name/$name") "GET /api/pokemons/name/$name"

$r = Invoke-Api PUT "/api/pokemons/$id" '{"level":10}'
Assert-Status 200 $r "PUT /api/pokemons/$id"
if (($r.Content | ConvertFrom-Json).level -ne 10) { Write-Host "  [FAIL] el nivel no se actualizó" -ForegroundColor Red; exit 1 }

Assert-Status 400 (Invoke-Api POST "/api/pokemons" '{"name":"","type":"Test","level":0}') "POST inválido es rechazado"
Assert-Status 204 (Invoke-Api DELETE "/api/pokemons/$id") "DELETE /api/pokemons/$id"
Assert-Status 404 (Invoke-Api GET "/api/pokemons/$id") "GET tras eliminar"

# 4. Balanceo de carga entre réplicas
$seen = @{}
1..20 | ForEach-Object {
    $h = (Invoke-Api GET "/actuator/health").Headers["X-Upstream-Addr"]
    if ($h) { $seen["$h"] = $true }
}
Write-Host "         réplicas que respondieron: $($seen.Count) ($($seen.Keys -join ', '))"
if ($seen.Count -ge $Replicas) {
    Write-Host "  [OK]   el gateway reparte carga entre $($seen.Count) réplica(s)" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] solo respondieron $($seen.Count) réplica(s), se esperaban $Replicas" -ForegroundColor Red; exit 1
}

Write-Host "Todos los smoke tests pasaron." -ForegroundColor Green

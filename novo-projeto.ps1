#!/usr/bin/env pwsh
# Cria um novo projeto Data Science a partir do template
# Uso: .\novo-projeto.ps1 -Nome "analise-vendas"

param(
    [Parameter(Mandatory = $true)]
    [string]$Nome
)

$root = $PSScriptRoot
$destino = Join-Path $root "projetos\$Nome"
$template = Join-Path $root "projetos\.template"

if (Test-Path $destino) {
    Write-Error "Projeto '$Nome' ja existe em $destino"
    exit 1
}

# Copiar template
Copy-Item -Path $template -Destination $destino -Recurse

# Renomear pasta src/template → src/<nome>
$srcTemplate = Join-Path $destino "src\template"
$srcNovo = Join-Path $destino "src\$Nome"
Rename-Item -Path $srcTemplate -NewName $Nome

# Substituir NOME_PROJETO no pyproject.toml
$pyproject = Join-Path $destino "pyproject.toml"
(Get-Content $pyproject) -replace "NOME_PROJETO", $Nome | Set-Content $pyproject -Encoding utf8

Write-Host ""
Write-Host "Projeto '$Nome' criado em $destino" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "  1. uv sync                              # atualizar venv"
Write-Host "  2. cd projetos\$Nome"
Write-Host "  3. uv add <pacote> --package $Nome      # deps especificas"
Write-Host "  4. uv run jupyter lab                   # abrir JupyterLab"

# Atajos de ejecución para Windows / PowerShell
# Uso: .\demo.ps1 setup | run | ui | clean
param(
    [ValidateSet("setup", "run", "ui", "clean")]
    [string]$Step = "run"
)

$ErrorActionPreference = "Stop"
$PY = ".\.venv\Scripts\python.exe"
$DB = (Join-Path (Get-Location) "demanda_ia_obs\mlflow.db") -replace "\\", "/"

switch ($Step) {
    "setup" {
        python -m venv .venv
        & $PY -m pip install --upgrade pip
        & $PY -m pip install -r requirements.txt
    }
    "run" {
        if (Test-Path demanda_ia_obs) {
            Write-Host "Ya existe demanda_ia_obs. Ejecuta '.\demo.ps1 clean' antes para no duplicar versiones en el Model Registry."
            exit 1
        }
        $env:PYTHONUTF8 = "1"
        & $PY src\Act__8__Monitoreo_DEMANDA-IA_JGOL.py
    }
    "ui" { & $PY -m mlflow server --backend-store-uri "sqlite:///$DB" --port 5000 }
    "clean" {
        if (Test-Path demanda_ia_obs) {
            $dest = "demanda_ia_obs_" + (Get-Date -Format "yyyyMMdd_HHmmss")
            Rename-Item demanda_ia_obs $dest
            Write-Host "Corrida anterior movida a $dest"
        }
    }
}

[CmdletBinding()]
param(
    [switch]$SoloGenerar
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $Raiz 'publicacion-github.json'
$CarpetaPublicable = Join-Path $Raiz 'SIN CONDUCCION'
$CopiaGit = Join-Path $Raiz '.publicacion-github'

function Titulo([string]$Texto) {
    Write-Host ''
    Write-Host ('=' * 68) -ForegroundColor DarkCyan
    Write-Host ('  ' + $Texto) -ForegroundColor Cyan
    Write-Host ('=' * 68) -ForegroundColor DarkCyan
}

function Ejecutar([string]$Programa, [string[]]$Argumentos, [string]$Descripcion) {
    Write-Host ('  > ' + $Descripcion) -ForegroundColor Gray
    & $Programa @Argumentos
    if ($LASTEXITCODE -ne 0) {
        throw "$Descripcion fallo (codigo $LASTEXITCODE)."
    }
}

function Buscar-Python {
    $Comando = Get-Command py -ErrorAction SilentlyContinue
    if ($Comando) {
        return @{ Programa = $Comando.Source; Prefijo = @('-3') }
    }
    $Comando = Get-Command python -ErrorAction SilentlyContinue
    if ($Comando) {
        return @{ Programa = $Comando.Source; Prefijo = @() }
    }
    throw 'No se encontro Python. Instala Python 3 y vuelve a intentarlo.'
}

function Leer-Configuracion {
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        Titulo 'CONFIGURACION INICIAL DE GITHUB'
        Write-Host 'Esto se pide una sola vez.'
        Write-Host 'Ejemplo: https://github.com/usuario/repositorio.git'
        $Repositorio = (Read-Host 'Pega la direccion HTTPS del repositorio').Trim()
        if ($Repositorio -notmatch '^https://github\.com/[^/\s]+/[^/\s]+(?:\.git)?$') {
            throw 'La direccion no parece un repositorio de GitHub valido.'
        }
        $Rama = (Read-Host 'Rama que publica el sitio [main]').Trim()
        if (-not $Rama) { $Rama = 'main' }
        if ($Rama -notmatch '^[A-Za-z0-9._/-]+$') {
            throw 'El nombre de la rama contiene caracteres no permitidos.'
        }
        [ordered]@{
            repositorio = $Repositorio
            rama = $Rama
        } | ConvertTo-Json | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
        Write-Host ('Configuracion guardada en ' + (Split-Path -Leaf $ConfigPath)) -ForegroundColor Green
    }

    $Config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $Config.repositorio -or -not $Config.rama) {
        throw 'publicacion-github.json debe contener repositorio y rama.'
    }
    if ([string]$Config.repositorio -notmatch '^https://github\.com/[^/\s]+/[^/\s]+(?:\.git)?$') {
        throw 'El repositorio guardado no es una direccion HTTPS valida de GitHub.'
    }
    if ([string]$Config.rama -notmatch '^[A-Za-z0-9._/-]+$') {
        throw 'La rama guardada contiene caracteres no permitidos.'
    }
    return $Config
}

try {
    Set-Location -LiteralPath $Raiz
    Titulo 'SYNCRORED EFESUR - GENERAR DATOS'

    $Python = Buscar-Python
    $Pasos = @(
        @{ Archivo = 'convertir_pautas.py'; Texto = 'Actualizar pautas/pautas.json' },
        @{ Archivo = 'convertir_boletin.py'; Texto = 'Actualizar prevenciones/boletin.json' },
        @{ Archivo = 'convertir_grafico.py'; Texto = 'Actualizar grafico/grafico.json' },
        @{ Archivo = 'generar_sin_conduccion.py'; Texto = 'Preparar la version para publicar' }
    )

    foreach ($Paso in $Pasos) {
        $Script = Join-Path $Raiz $Paso.Archivo
        if (-not (Test-Path -LiteralPath $Script)) {
            throw ('No se encontro ' + $Paso.Archivo)
        }
        $Argumentos = @($Python.Prefijo) + @('-X', 'utf8', $Script)
        Ejecutar $Python.Programa $Argumentos $Paso.Texto
    }

    if (-not (Test-Path -LiteralPath (Join-Path $CarpetaPublicable 'index.html'))) {
        throw 'No se genero SIN CONDUCCION\index.html.'
    }

    if ($SoloGenerar) {
        Titulo 'DATOS GENERADOS'
        Write-Host 'No se envio nada a GitHub porque se uso -SoloGenerar.' -ForegroundColor Yellow
        exit 0
    }

    $Config = Leer-Configuracion
    $Git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $Git) {
        throw 'No se encontro Git. Instala Git for Windows y vuelve a intentarlo.'
    }

    Titulo 'ACTUALIZAR REPOSITORIO DE GITHUB'

    if (-not (Test-Path -LiteralPath (Join-Path $CopiaGit '.git'))) {
        if (Test-Path -LiteralPath $CopiaGit) {
            $RutaCompleta = [System.IO.Path]::GetFullPath($CopiaGit)
            $RaizCompleta = [System.IO.Path]::GetFullPath($Raiz)
            if (-not $RutaCompleta.StartsWith($RaizCompleta + [System.IO.Path]::DirectorySeparatorChar)) {
                throw 'La carpeta temporal de publicacion esta fuera del proyecto.'
            }
            Remove-Item -LiteralPath $CopiaGit -Recurse -Force
        }
        Ejecutar $Git.Source @('clone', '--branch', [string]$Config.rama, '--single-branch', [string]$Config.repositorio, $CopiaGit) 'Descargar el repositorio por primera vez'
    }
    else {
        $Origin = (& $Git.Source -C $CopiaGit remote get-url origin).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer el repositorio configurado.' }
        if ($Origin.TrimEnd('/') -ne ([string]$Config.repositorio).TrimEnd('/')) {
            Ejecutar $Git.Source @('-C', $CopiaGit, 'remote', 'set-url', 'origin', [string]$Config.repositorio) 'Actualizar la direccion del repositorio'
        }

        # Esta carpeta es una copia automatica y descartable. Si una ejecucion
        # anterior se interrumpio, se limpia antes de volver a generar cambios.
        Ejecutar $Git.Source @('-C', $CopiaGit, 'reset', '--hard', 'HEAD') 'Preparar la copia local'
        Ejecutar $Git.Source @('-C', $CopiaGit, 'clean', '-fd') 'Limpiar archivos temporales de la copia'
        Ejecutar $Git.Source @('-C', $CopiaGit, 'checkout', [string]$Config.rama) 'Seleccionar la rama de publicacion'
        Ejecutar $Git.Source @('-C', $CopiaGit, 'pull', '--rebase', 'origin', [string]$Config.rama) 'Recibir cambios nuevos de GitHub'
    }

    Write-Host '  > Copiar la version generada' -ForegroundColor Gray
    Get-ChildItem -LiteralPath $CarpetaPublicable -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $CopiaGit -Recurse -Force
    }

    if (-not (& $Git.Source -C $CopiaGit config user.name)) {
        Ejecutar $Git.Source @('-C', $CopiaGit, 'config', 'user.name', 'SyncroRed EFESUR') 'Configurar el nombre de los cambios'
    }
    if (-not (& $Git.Source -C $CopiaGit config user.email)) {
        Ejecutar $Git.Source @('-C', $CopiaGit, 'config', 'user.email', 'syncrored@users.noreply.github.com') 'Configurar el correo de los cambios'
    }

    Ejecutar $Git.Source @('-C', $CopiaGit, 'add', '-A') 'Preparar los archivos modificados'
    & $Git.Source -C $CopiaGit diff --cached --quiet
    $HayCambios = $LASTEXITCODE -ne 0

    if ($HayCambios) {
        $Mensaje = 'Actualizacion automatica ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')
        Ejecutar $Git.Source @('-C', $CopiaGit, 'commit', '-m', $Mensaje) 'Guardar la actualizacion'
    }
    else {
        Write-Host '  No hay archivos nuevos; se comprobara igualmente GitHub.' -ForegroundColor Yellow
    }

    Ejecutar $Git.Source @('-C', $CopiaGit, 'push', 'origin', [string]$Config.rama) 'Subir la actualizacion a GitHub'
    $Revision = (& $Git.Source -C $CopiaGit rev-parse --short HEAD).Trim()

    Titulo 'PUBLICACION TERMINADA'
    Write-Host ('Repositorio: ' + $Config.repositorio) -ForegroundColor Green
    Write-Host ('Rama:       ' + $Config.rama) -ForegroundColor Green
    Write-Host ('Revision:   ' + $Revision) -ForegroundColor Green
    Write-Host ''
    Write-Host 'GitHub ya recibio los JSON y la version nueva del sitio.' -ForegroundColor Green
    Write-Host 'Si usas GitHub Pages, el cambio normalmente aparece en pocos minutos.'
    exit 0
}
catch {
    Write-Host ''
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'No se informo una publicacion terminada. Corrige el dato indicado y vuelve a ejecutar.' -ForegroundColor Yellow
    exit 1
}

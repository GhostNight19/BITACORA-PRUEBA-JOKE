[CmdletBinding()]
param(
    # con = la version de prueba, con Modo Conduccion (toda esta carpeta)
    # sin = la version que usan todos (la carpeta SIN CONDUCCION)
    [Parameter(Mandatory = $true)]
    [ValidateSet('con', 'sin')]
    [string]$Destino,

    # Hace todo menos subir: sirve para revisar que cambiaria en GitHub.
    [switch]$SinSubir
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
$Rama = 'main'

# Cada boton sube a su propio repositorio. GitHub Pages publica los dos desde
# la rama main, asi que basta con que el cambio llegue ahi.
$Destinos = @{
    con = @{
        Nombre      = 'CON MODO CONDUCCION'
        Repositorio = 'https://github.com/GhostNight19/BITACORA-PRUEBA-JOKE.git'
        Pagina      = 'https://ghostnight19.github.io/BITACORA-PRUEBA-JOKE/'
        Origen      = $Raiz
    }
    sin = @{
        Nombre      = 'SIN MODO CONDUCCION'
        Repositorio = 'https://github.com/GhostNight19/bitacorappefe-sur.git'
        Pagina      = 'https://ghostnight19.github.io/bitacorappefe-sur/'
        Origen      = Join-Path $Raiz 'SIN CONDUCCION'
    }
}
$D = $Destinos[$Destino]

# La copia de trabajo de Git vive fuera de esta carpeta: asi no se sube a si
# misma cuando se publica la version con Modo Conduccion, que es la carpeta
# entera.
$CopiaGit = Join-Path $env:LOCALAPPDATA ('SyncroRed EFESUR\publicacion-' + $Destino)

# Lo que nunca va a GitHub desde esta carpeta.
$CarpetasFuera = @('SIN CONDUCCION', '__pycache__', '.git', '.publicacion-github')
$ArchivosFuera = @('~$*', 'publicacion-github.json', '_*', '*.tmp')

function Titulo([string]$Texto) {
    Write-Host ''
    Write-Host ('=' * 68) -ForegroundColor DarkCyan
    Write-Host ('  ' + $Texto) -ForegroundColor Cyan
    Write-Host ('=' * 68) -ForegroundColor DarkCyan
}

function Ejecutar([string]$Programa, [string[]]$Argumentos, [string]$Descripcion) {
    if (-not (Probar $Programa $Argumentos $Descripcion)) {
        throw "$Descripcion fallo (codigo $LASTEXITCODE)."
    }
}

# Git escribe su avance por stderr, y Windows PowerShell lo tomaria como un
# error: lo que manda es el codigo de salida.
function Probar([string]$Programa, [string[]]$Argumentos, [string]$Descripcion) {
    $ErrorActionPreference = 'Continue'
    Write-Host ('  > ' + $Descripcion) -ForegroundColor Gray
    & $Programa @Argumentos | Out-Host
    return ($LASTEXITCODE -eq 0)
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

# Git entra a GitHub con la sesion de GitHub CLI (gh) si esta iniciada: es la
# misma cuenta y no pregunta nada. Si no hay gh, usa el administrador de
# credenciales de Git, que la primera vez abre el navegador para autorizar.
function Opciones-Acceso {
    # Windows PowerShell trata como error lo que gh escribe en stderr: aca
    # solo interesa si respondio bien o no.
    $ErrorActionPreference = 'Continue'
    $Gh = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $Gh) { return @() }
    & $Gh.Source auth status --hostname github.com 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { return @() }
    $Ayudante = "!'" + ($Gh.Source -replace '\\', '/') + "' auth git-credential"
    return @('-c', 'credential.https://github.com.helper=', '-c', ('credential.https://github.com.helper=' + $Ayudante))
}

function Autor {
    $ErrorActionPreference = 'Continue'
    $Gh = Get-Command gh -ErrorAction SilentlyContinue
    if ($Gh) {
        $Login = [string](& $Gh.Source api user --jq .login 2>&1)
        $okLogin = $LASTEXITCODE -eq 0
        $Id = [string](& $Gh.Source api user --jq .id 2>&1)
        if ($okLogin -and $LASTEXITCODE -eq 0 -and $Login -match '^[A-Za-z0-9-]+$' -and $Id -match '^\d+$') {
            return @{ Nombre = $Login.Trim(); Correo = ($Id.Trim() + '+' + $Login.Trim() + '@users.noreply.github.com') }
        }
    }
    return @{ Nombre = 'SyncroRed EFESUR'; Correo = 'syncrored@users.noreply.github.com' }
}

function Copiar-Version {
    Write-Host '  > Copiar la version nueva' -ForegroundColor Gray
    $Argumentos = @($D.Origen, $CopiaGit, '/E', '/R:2', '/W:1', '/NFL', '/NDL', '/NJH', '/NJS', '/NP',
                    '/XD') + $CarpetasFuera + @('/XF') + $ArchivosFuera
    & robocopy @Argumentos | Out-Null
    # robocopy avisa con codigos 0 a 7 cuando copio bien; 8 o mas es error.
    if ($LASTEXITCODE -ge 8) { throw "No se pudo copiar la version (robocopy $LASTEXITCODE)." }
    $global:LASTEXITCODE = 0
}

try {
    Set-Location -LiteralPath $Raiz
    Titulo ('SYNCRORED EFESUR - ' + $D.Nombre)

    # ---------------------------------------------------- generar los datos --
    $Python = Buscar-Python
    $Pasos = @(
        @{ Archivo = 'convertir_pautas.py'; Texto = 'Leer las pautas diarias' },
        @{ Archivo = 'convertir_boletin.py'; Texto = 'Leer los boletines de via' },
        @{ Archivo = 'convertir_grafico.py'; Texto = 'Leer el grafico del mes' },
        @{ Archivo = 'generar_sin_conduccion.py'; Texto = 'Armar la version sin Modo Conduccion' }
    )
    foreach ($Paso in $Pasos) {
        $Script = Join-Path $Raiz $Paso.Archivo
        if (-not (Test-Path -LiteralPath $Script)) { throw ('No se encontro ' + $Paso.Archivo) }
        Ejecutar $Python.Programa (@($Python.Prefijo) + @('-X', 'utf8', $Script)) $Paso.Texto
    }
    if (-not (Test-Path -LiteralPath (Join-Path $D.Origen 'index.html'))) {
        throw ('No se encontro index.html en ' + $D.Origen)
    }

    # ------------------------------------------------------ subir a GitHub --
    $Git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $Git) { throw 'No se encontro Git. Instala Git for Windows y vuelve a intentarlo.' }
    $Acceso = @(Opciones-Acceso)
    $G = $Git.Source

    Titulo ('SUBIR A GITHUB - ' + $D.Nombre)

    if (-not (Test-Path -LiteralPath (Join-Path $CopiaGit '.git'))) {
        if (Test-Path -LiteralPath $CopiaGit) { Remove-Item -LiteralPath $CopiaGit -Recurse -Force }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $CopiaGit) | Out-Null
        Ejecutar $G ($Acceso + @('clone', '--branch', $Rama, '--single-branch', $D.Repositorio, $CopiaGit)) 'Descargar el repositorio (solo la primera vez)'
    }
    else {
        Ejecutar $G @('-C', $CopiaGit, 'remote', 'set-url', 'origin', $D.Repositorio) 'Revisar la direccion del repositorio'
    }

    $Quien = Autor
    Ejecutar $G @('-C', $CopiaGit, 'config', 'user.name', $Quien.Nombre) 'Firmar con la cuenta de GitHub'
    Ejecutar $G @('-C', $CopiaGit, 'config', 'user.email', $Quien.Correo) 'Firmar con la cuenta de GitHub'
    Ejecutar $G @('-C', $CopiaGit, 'config', 'core.quotepath', 'false') 'Nombres con tilde legibles'

    # La copia es desechable: siempre se parte de lo que hay hoy en GitHub,
    # incluido lo que se haya subido a mano por la pagina.
    for ($Intento = 1; $Intento -le 2; $Intento++) {
        Ejecutar $G ($Acceso + @('-C', $CopiaGit, 'fetch', 'origin', $Rama)) 'Traer lo ultimo de GitHub'
        Ejecutar $G @('-C', $CopiaGit, 'reset', '--hard', ('origin/' + $Rama)) 'Dejar la copia igual a GitHub'
        Ejecutar $G @('-C', $CopiaGit, 'clean', '-fdq') 'Limpiar restos de una subida anterior'

        Copiar-Version
        Ejecutar $G @('-C', $CopiaGit, 'add', '-A') 'Preparar los cambios'

        & $G -C $CopiaGit diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Titulo 'NO HAY NADA NUEVO'
            Write-Host 'GitHub ya tiene exactamente esta version. No se subio nada.' -ForegroundColor Yellow
            exit 0
        }

        Write-Host ''
        Write-Host '  Cambios que se van a subir:' -ForegroundColor White
        & $G -C $CopiaGit diff --cached --stat=90 | ForEach-Object { Write-Host ('    ' + $_) }
        Write-Host ''

        if ($SinSubir) {
            Titulo 'PRUEBA TERMINADA'
            Write-Host 'Se uso -SinSubir: no se envio nada a GitHub.' -ForegroundColor Yellow
            exit 0
        }

        $Mensaje = 'Actualizacion ' + (Get-Date -Format 'yyyy-MM-dd HH:mm')
        Ejecutar $G @('-C', $CopiaGit, 'commit', '-q', '-m', $Mensaje) 'Guardar la actualizacion'

        if (Probar $G ($Acceso + @('-C', $CopiaGit, 'push', 'origin', $Rama)) 'Subir a GitHub') { break }
        # Si alguien subio algo por la pagina justo ahora, se vuelve a partir
        # desde lo ultimo y se intenta una vez mas.
        if ($Intento -eq 2) { throw 'GitHub no acepto la subida.' }
        Write-Host '  GitHub tenia algo mas nuevo; se vuelve a intentar.' -ForegroundColor Yellow
    }

    $Revision = (& $G -C $CopiaGit rev-parse --short HEAD).Trim()
    Titulo 'SUBIDA TERMINADA'
    Write-Host ('Repositorio: ' + $D.Repositorio) -ForegroundColor Green
    Write-Host ('Revision:    ' + $Revision) -ForegroundColor Green
    Write-Host ('Pagina:      ' + $D.Pagina) -ForegroundColor Green
    Write-Host ''
    Write-Host 'GitHub Pages publica el cambio en uno o dos minutos.'
    exit 0
}
catch {
    Write-Host ''
    Write-Host ('ERROR: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'No se subio nada a medias. Corrige lo indicado y vuelve a intentarlo.' -ForegroundColor Yellow
    exit 1
}

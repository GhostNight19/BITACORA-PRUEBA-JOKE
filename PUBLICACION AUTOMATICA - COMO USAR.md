# Subir la Bitácora a GitHub con un doble clic

Hay dos botones, uno para cada versión:

| Botón | Sube a | Página |
|---|---|---|
| **`SUBIR A GITHUB - CON CONDUCCION.cmd`** | `GhostNight19/BITACORA-PRUEBA-JOKE` | https://ghostnight19.github.io/BITACORA-PRUEBA-JOKE/ |
| **`SUBIR A GITHUB - SIN CONDUCCION.cmd`** | `GhostNight19/bitacorappefe-sur` | https://ghostnight19.github.io/bitacorappefe-sur/ |

La versión **con** Modo Conducción sube esta carpeta entera, igual que se
hacía a mano: la app, los JSON, los Excel, los instructivos y los scripts.
La versión **sin** Modo Conducción sube solo la carpeta `SIN CONDUCCION`, que
es la que usan todos.

## Cada actualización

1. Deja los archivos nuevos en su carpeta: pautas en `pautas_excel`, boletines
   en `boletines_excel` y el gráfico en `graficos_excel`.
2. Haz doble clic en el botón de la versión que quieras subir, o en los dos.

Cada botón hace todo el proceso:

1. Lee los Excel y arma `pautas/pautas.json`, `prevenciones/boletin.json` y
   `grafico/grafico.json`.
2. Arma la carpeta `SIN CONDUCCION`.
3. Trae lo último que haya en GitHub, incluido lo que se haya subido a mano
   por la página.
4. Muestra la lista de archivos que cambian.
5. Los sube a GitHub con tu cuenta.

GitHub Pages publica el cambio en uno o dos minutos. Si no había nada nuevo,
el botón lo dice y no sube nada.

## Acceso

Los botones entran a GitHub con la sesión de **GitHub CLI** (`gh`) que ya está
iniciada en este computador con la cuenta **GhostNight19**. No piden usuario
ni contraseña, y no guardan ninguna clave en esta carpeta.

Si algún día la sesión se cierra, abre una terminal y escribe:

```
gh auth login
```

Sin `gh`, Git usa su propio administrador de credenciales: la primera vez abre
el navegador para autorizar y después ya no pregunta.

## Bueno saber

- Los botones **agregan y actualizan** archivos; nunca borran nada de GitHub.
  Si quieres sacar un archivo del repositorio, hazlo desde la página.
- Lo que no se sube nunca: la carpeta `SIN CONDUCCION` al repositorio con
  conducción, los archivos temporales de Excel (`~$...`) y los que empiezan
  con `_`.
- La copia de trabajo de Git vive en
  `%LOCALAPPDATA%\SyncroRed EFESUR\publicacion-con` y `...\publicacion-sin`.
  Es desechable: si algo se enreda, se puede borrar y el botón la vuelve a
  descargar.
- Para revisar qué subiría sin subir nada, desde PowerShell:
  `.\publicar-github.ps1 -Destino sin -SinSubir` (o `-Destino con`).

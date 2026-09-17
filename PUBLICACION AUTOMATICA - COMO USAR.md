# Actualización automática de la Bitácora

La publicación queda preparada para hacerse con un doble clic.

## Primera vez

1. Abre **`ACTUALIZAR Y SUBIR A GITHUB.cmd`**.
2. Pega la dirección HTTPS del repositorio, por ejemplo:

   `https://github.com/usuario/repositorio.git`

3. Presiona Enter para usar la rama `main`.
4. GitHub puede abrir el navegador para iniciar sesión. Esto ocurre solamente
   cuando Git necesita autorizar este computador.

La configuración se guarda en `publicacion-github.json`. Solo guarda la
dirección y la rama; no guarda contraseñas ni tokens.

## Cada actualización futura

1. Deja el gráfico nuevo en **`graficos_excel`**.
2. Si también hay pautas o boletines nuevos, déjalos en `pautas_excel` o
   `boletines_excel`.
3. Haz doble clic en **`ACTUALIZAR Y SUBIR A GITHUB.cmd`**.

El botón realiza todo este proceso:

1. Convierte los Excel en archivos JSON.
2. Actualiza `grafico/grafico.json`, `pautas/pautas.json` y
   `prevenciones/boletin.json`.
3. Genera la carpeta `SIN CONDUCCION` lista para publicar.
4. Descarga cualquier cambio reciente del repositorio.
5. Guarda la actualización en Git.
6. La sube a GitHub.

Los archivos Excel originales no se suben. El repositorio recibe la aplicación
lista y sus JSON. Si GitHub Pages publica desde la rama `main`, la página se
actualiza automáticamente después del envío.

## Cambiar de repositorio

Edita `publicacion-github.json` y reemplaza `repositorio` o `rama`. También
puedes borrar ese archivo para que el botón vuelva a pedir ambos datos.

La carpeta oculta `.publicacion-github` es una copia de trabajo automática. No
edites archivos allí: se reemplazan en cada publicación.

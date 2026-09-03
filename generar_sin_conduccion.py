# -*- coding: utf-8 -*-
"""
Genera la version SIN el Modo Conduccion, lista para subir al repositorio.

Uso:
    python generar_sin_conduccion.py

Deja todo en la carpeta "SIN CONDUCCION": el index.html sin ese modulo y los
mismos datos (pautas, boletines, grafico, dotacion) que la version de pruebas.
Es esa carpeta la que se sube a GitHub mientras el Modo Conduccion siga en
pruebas; aqui, en la carpeta de trabajo, el modulo sigue estando.

El corte no es a ojo: en index.html el modulo va entre marcas

    >>> MODO CONDUCCION >>>   ...   <<< MODO CONDUCCION <<<

en el boton, los estilos, la ventana y el codigo. El script borra lo que hay
entre cada par de marcas, asi que aunque el modulo cambie, la version limpia
sigue saliendo bien. Si alguna marca falta o quedan pares descuadrados, avisa y
no escribe nada.
"""

import re
import shutil
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
DESTINO = BASE / "SIN CONDUCCION"

# Lo que se copia tal cual: es lo mismo que se sube hoy al repositorio.
CARPETAS = ["pautas", "prevenciones", "grafico", "personal"]
ARCHIVOS = ["sw.js", "manifest.json", "icon-512.png", "logo-syncrored.png"]

ABRE = ">>> MODO CONDUCCION >>>"
CIERRA = "<<< MODO CONDUCCION <<<"


def limpiar(html):
    """Borra cada bloque marcado, con su comentario de apertura y de cierre."""
    # Cada bloque va dentro de un comentario HTML (<!-- ... -->) o JS (/* ... */).
    patron = re.compile(
        r"[ \t]*(?:<!--|/\*)\s*" + re.escape(ABRE) + r"\s*(?:-->|\*/)"
        r".*?"
        r"(?:<!--|/\*)\s*" + re.escape(CIERRA) + r"\s*(?:-->|\*/)[ \t]*\n?",
        re.S,
    )
    limpio, n = patron.subn("", html)

    if limpio.count(ABRE) or limpio.count(CIERRA):
        raise SystemExit("Quedaron marcas sueltas de MODO CONDUCCION: revisa index.html")
    return limpio, n


def main():
    origen = BASE / "index.html"
    if not origen.exists():
        raise SystemExit("No se encontro index.html")

    html = origen.read_text(encoding="utf-8")
    abre, cierra = html.count(ABRE), html.count(CIERRA)
    if abre == 0:
        raise SystemExit("index.html no trae las marcas del modulo; no se toca nada.")
    if abre != cierra:
        raise SystemExit("Marcas descuadradas: %d aperturas y %d cierres." % (abre, cierra))

    limpio, n = limpiar(html)

    # Nada del modulo puede sobrevivir al corte.
    sobras = [x for x in ("abrirConduccion", "cond-overlay", "condTick", "COND_LLAVE")
              if x in limpio]
    if sobras:
        raise SystemExit("Quedaron restos del modulo: %s" % ", ".join(sobras))

    DESTINO.mkdir(exist_ok=True)
    (DESTINO / "index.html").write_text(limpio, encoding="utf-8")
    print("  index.html  ->  %d bloques quitados  (%d KB, antes %d KB)" % (
        n, len(limpio.encode("utf-8")) / 1024, len(html.encode("utf-8")) / 1024))

    for nombre in CARPETAS:
        src = BASE / nombre
        if not src.exists():
            continue
        dst = DESTINO / nombre
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
        print("  %s/  ->  %d archivos" % (nombre, len(list(dst.iterdir()))))

    for nombre in ARCHIVOS:
        src = BASE / nombre
        if src.exists():
            shutil.copy(src, DESTINO / nombre)
            print("  %s" % nombre)

    (DESTINO / "NO EDITAR AQUI.txt").write_text(
        "Esta carpeta se genera sola con generar_sin_conduccion.py.\n"
        "Lo que se edite aqui se pierde en la proxima generacion: los\n"
        "cambios van en la carpeta de arriba y se vuelve a generar.\n",
        encoding="utf-8")

    print("\nListo: %s" % DESTINO)
    print("Esa carpeta es la que se sube al repositorio.")


if __name__ == "__main__":
    main()

# Prevenciones (prueba)

Esta carpeta es la bitácora completa —con Mis Turnos y el planificador— más un
apartado nuevo: **⚠️ Prevenciones**, que lee el Boletín de Vía C y avisa la
prevención que se viene según dónde está el tren.

---

## Cómo publicar el boletín del día

Igual que las pautas, es un archivo y un comando:

1. Deja el Excel del boletín en la carpeta **`boletines_excel`**.
2. Ejecuta:

```bash
python convertir_boletin.py
```

3. Sube al repositorio **`prevenciones/boletin.json`**.

El script se queda solo con la parte útil: desde *NOTIFICACIÓN DE FAENAS EN EL
INICIO DEL RECORRIDO* hasta antes de *PROGRAMACIÓN DE CORTADAS*. Las cortadas
son trabajos con vía fuera de servicio, no prevenciones de circulación.

---

## Qué hace

**El aviso bajo el reloj.** Aparece solo cuando queda una prevención dentro de
**1000 m** en el sentido de marcha. Muestra la distancia, la gravedad, la
restricción, la vía y el PK. Se pinta según la gravedad (rojo ≤15 km/h, naranjo
≤30, azul otras restricciones, gris los avisos de solo toque pito).

Va pegado al reloj: **al desplazar la pantalla los dos quedan a la vista**, la
franja siempre justo debajo. Su posición se calcula sola, porque el reloj no
mide lo mismo en el celular que en el computador.

El aviso pasa por tres momentos:

| Momento | Se ve | |
|---|---|---|
| Se acerca | `420 m` | cuenta hacia atrás desde los 1000 m |
| Se está dentro | `EN ZONA` | la franja late |
| Ya se pasó | `◀ 90 m` | atenuada y con el borde punteado |

Después de **150 m** de haber salido de la zona, desaparece. Si en el intertanto
aparece otra prevención por delante, esa toma el lugar de inmediato: la que
quedó atrás nunca tapa a la que viene. El teléfono vibra al entrar una
prevención nueva, no al salir de una.

**El panel ⚠️ Prevenciones.** Dónde está el tren (línea, PK, sentido y vía), lo
que viene en los próximos 15 km, y el listado completo de lo vigente en L1 y L2.

---

## Cómo sabe dónde está y por qué vía va

El GPS entrega latitud y longitud. Esa coordenada se proyecta sobre el trazado
de la línea —una polilínea con su kilometraje, muestreada cada 500 m— y de ahí
sale el **PK**. Con dos posiciones seguidas se sabe si el PK sube o baja:

| Línea | Tramo y sentido | Vía |
|---|---|---|
| **L1** | Hualqui → El Arenal (PK creciente) | **VÍA 1** |
| **L1** | El Arenal → Hualqui (PK decreciente) | **VÍA 2** |
| **L1** | El Arenal → Mercado (PK 84 en adelante) | **VÍA 4** |
| **L2** | Concepción → Coronel (PK creciente) | **VÍA 1** |
| **L2** | Coronel → Concepción (PK decreciente) | **VÍA 2** |

Las prevenciones de *AMBAS VÍAS*, *TODAS*, *PRINCIPAL*, *PUENTE* y *CRUCE*
aplican siempre. Las de *VÍA 1* y *VÍA 2* se filtran por el sentido de marcha.
Las de *VÍA 4* aplican en los dos sentidos: es vía única entre El Arenal y
Mercado, y en Concepción es la de acceso al ramal a Coronel.

Mientras el tren está detenido y todavía no hay sentido definido, no se filtra
nada: se muestran todas.

---

## Qué se muestra y qué no

- **Solo lo vigente.** Tiene que estar dentro de su horario y de sus fechas. Las
  ventanas que cruzan medianoche (23:00 → 00:00) se entienden bien.
- **Lo más grave primero.** El orden es: ≤15 km/h → ≤30 km/h → otras
  restricciones (sin tráfico, bajada de pantógrafo, prohibición de maniobra) →
  solo toque pito. A igual gravedad, lo más cercano.
- **Patio, desvío, enlace y variante no tapan a la vía.** Se listan, pero bajan
  un escalón en el orden, para que un 10 km/h de patio no desplace un 30 km/h
  de la vía por la que se circula.
- **Siete prevenciones no se ubican en el mapa** y salen marcadas como *sin
  ubicación en el trazado*: las cuatro de **VARIANTE** (CC-LQ, BB-EZ, BB-LQ) y
  las tres de **INDUSTRIAS DERIVADAS**. Llevan su propio kilometraje: el km 3 de
  Industrias Derivadas no es el km 3 de L1. Se muestran en el listado, pero no
  generan aviso de proximidad.

---

## Modo prueba

Dentro del panel, **🧪 Modo prueba** permite fijar línea, PK y sentido a mano,
sin GPS y sin estar arriba del tren. Sirve para revisar que el boletín quedó
bien leído: pones L2, PK 15,90, sentido creciente, y tiene que salir el cruce
del PK 16 P. 15 a 15 km/h (pero solo entre 00:00 y 06:30, o después de 22:30,
que es su horario).

---

## Precisión, y qué no hay que esperar de esto

- El trazado está muestreado **cada 500 m**. El PK sale de interpolar entre esos
  puntos, así que tiene un margen del orden de la decena de metros en recta y
  algo más en curva. Para un aviso a 1000 m sirve; no es un sistema de
  señalización.
- La **vía** se deduce del movimiento, no de la vía física: las dos vías van
  paralelas a pocos metros y el GPS no las distingue. Si el tren está detenido,
  se conserva el último sentido conocido.
- En **Concepción** L1 y L2 se tocan. Se mantiene la línea en la que se venía
  salvo que la otra quede claramente más cerca.
- El **poste** se lee como centésima de kilómetro: `27 P. 41` → PK 27,41. Es la
  convención del propio boletín (así, el 27 P. 41 de Coronel cae justo en la
  estación, PK 27,43).

**Esto es una ayuda de conducción. El Boletín de Vía C sigue siendo el documento
válido.**

---

## Cuando el boletín trae varias versiones en un mismo Excel

Un archivo como `243-B BOLETÍN DE VIA C (CTC) 31-08-26.xlsx` puede venir con
tres pestañas: el boletín original y sus reediciones (`243`, `243-A`, `243-B`).
El conversor lee el **folio de cada pestaña** y se queda siempre con la última
revisión; al ejecutarlo lo dice en pantalla:

```
(3 versiones en el archivo: 243, 243-A, 243-B -> se usa el folio 243-B)
```

Lo mismo entre archivos distintos del mismo día: si en `boletines_excel` están
el `243` y el `243-B`, gana el `243-B` aunque el otro se haya copiado después.
No hace falta borrar el archivo viejo.

## Quitar una línea que ya no corre

Cuando tráfico avisa que una línea del boletín ya no está vigente ("la 50 ya
terminó"), se quita desde el panel de Prevenciones:

- Escribe el número en **"Quitar una línea que tráfico dio por terminada"** y
  toca **Quitar** (o Enter). Sirve aunque la línea todavía no esté en su
  horario.
- O toca **Quitar** en la tarjeta de esa prevención. Cada tarjeta muestra su
  **N°** de línea del boletín.

Una línea quitada deja de avisarse y de aparecer en las listas, esté o no
dentro de su horario. Queda abajo, en **"Quitadas de este boletín"**, con un
botón **Volver a mostrar** por si fue un error.

Vale solo para ese boletín: cuando entra el del día siguiente, vuelven a
aparecer todas sus líneas. Lo que se quita queda en el teléfono donde se hizo.

## Qué vías se avisan

El tren de pasajeros va por la vía 1, la 2 o la 4, y la app sabe por cuál va
según el sentido de marcha. Por eso:

- **Vía 1, vía 2, vía 4, ambas vías, principal, puente, cruce, "vía 1 y 2"**:
  se avisan según corresponda al sentido de marcha.
- **Enlaces** entre vías (por ejemplo Ag.1-Ag.3 en La Leonera): se avisan en
  los dos sentidos, porque el tren los cruza al cambiar de vía.
- **Vías secundarias** (la vía 8-B de Concepción, la vía 20 y el patio de
  El Arenal, desviadores, variantes): **no se avisan en marcha**. Siguen en el
  listado del panel, marcadas como "vía secundaria".
- **Solo carga** ("sin tráfico de carga"): no se avisa al tren de pasajeros.
  También queda en el listado, marcada como "solo carga".

## Cruces en falla

Cuando avisan por radio que un paso a nivel quedó en falla (barrera
atropellada, sin protección), se marca con el botón **🚧 Cruces** del menú:

1. Elige la línea: L1 (19 cruces) o L2 (28 cruces).
2. Toca el cruce.
3. Elige la vía por la que avisaron la falla: **Vía 1**, **Vía 2** o **Ambas
   vías**. Donde los trenes van por una sola vía en los dos sentidos sale solo
   esa opción (vía única entre Hualqui y La Leonera y en Chepe; vía 4 en
   Bilbao, La Unión y Desiderio Sanhueza por L2).

Desde ese momento el cruce se avisa como una prevención **crítica**, igual que
las del boletín: a 1000 m y bajo el reloj. Se avisa **en los dos sentidos**,
cualquiera sea la vía que se marcó: el cruce atraviesa las dos vías y la
precaución hay que tomarla igual. La vía queda anotada como dato ("Falla vía 1").
También aparece arriba en el panel de Prevenciones, en "Cruces en falla".

El botón muestra cuántos cruces hay en falla. Cada uno se quita con **Quitar**
cuando lo reparan, y si nadie lo quita se borra solo a las 24 horas. La marca
queda en el teléfono donde se hizo: no se comparte con los demás.

Los PK salen de los listados de cruces de EFE. En L1 el listado trae el
kilómetro con decimales; en L2 trae el kilómetro y los postes ("PK 16 P. 15-17"),
que es lo que se muestra, y para avisar se usa el punto donde se marcó cada
cruce con GPS en terreno.

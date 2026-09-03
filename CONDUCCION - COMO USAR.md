# Modo Conducción

Para llevar el turno arriba de la máquina. El GPS marca solo la salida y la
llegada de cada estación; lo único que se toca es el motivo de un atraso, y aun
eso se puede dictar.

---

## Cómo se usa

1. Se abre **🚦 Modo Conducción** y se escribe el apellido.
2. Aparecen los servicios del turno de hoy, sacados de la **pauta diaria**, con
   su hora de salida.
3. Se toca el servicio que se va a hacer. Ya no hay que tocar nada más.

Arriba de todo va el **estado del GPS**. Si el teléfono no ha dado permiso, sale
en rojo con un botón **«Activar ubicación»**; cuando ya está tomando, muestra la
línea, el PK y la precisión.

La pantalla queda encendida sola mientras el modo está abierto (Wake Lock).

## Servicios que no vienen en la pauta

El turno del día no siempre es todo lo que se hace. Al final de la lista hay un
campo **«¿Vas a hacer otro servicio?»**: se escribe el número del tren y se
agrega. Si ese número no tiene itinerario guardado, lo avisa en vez de agregarlo
vacío.

Los servicios agregados quedan guardados y vuelven solos si se cierra la app. Se
quitan con la ✕ que aparece junto al número.

Lo mismo sirve cuando la pauta del día todavía no está cargada o cuando alguien
no aparece en ella: la lista parte vacía y se arma a mano.

---

## Qué muestra

| | |
|---|---|
| Arriba | La **prevención más grave dentro de 500 m**: restricción, distancia, PK y motivo |
| Al centro | La **velocidad** en km/h, el número del tren y si está detenido o en marcha |
| Debajo | De dónde salió y **la estación siguiente con su horario** |
| Abajo | El recorrido completo, con la hora real de cada parada y su atraso |

---

## Cómo marca las salidas

Cuando el tren está detenido en una estación, la app espera la salida:

- **Se da por salido** cuando mantiene más de **5 km/h durante 4 segundos**, o
  cuando se despegó **60 m** del andén.
- El horario tiene **un minuto de cortesía**: la salida de las 17:12 no es
  atraso hasta las 17:12:59.
- Pasado eso, el atraso se cuenta en minutos y se muestra **en vivo**, subiendo,
  antes de que el tren parta.

Al partir queda escrita la hora real y el atraso.

## Cómo marca las llegadas

Estando en marcha, la llegada se da por hecha cuando el tren entra en un radio
de **300 m** de la estación siguiente **y baja de 5 km/h**. Ahí avanza sola a la
parada siguiente.

---

## Cuándo pide justificación

- **En la estación de origen**, si salió atrasado. Obligatoria.
- **Al llegar al término del servicio**, si llegó atrasado. Obligatoria.
- **En las estaciones intermedias** el atraso se registra igual, pero **no** se
  pide justificación: el botón «Motivo del atraso» queda disponible por si se
  quiere anotar algo.

La justificación se puede dar de tres maneras:

1. **Tocando un motivo** de la lista (cruce ocupado, espera de tren, señal en
   rojo, pasajeros/puerta, falla del material, orden del controlador, prevención
   de vía, llegó atrasado el anterior).
2. **Dictándola**: el botón 🎤 transcribe la voz al texto.
3. **Escribiéndola** a mano.

El dictado usa el reconocimiento del teléfono. Necesita internet y permiso de
micrófono, y funciona en Chrome Android; si el equipo no lo soporta, lo avisa y
quedan las otras dos formas.

---

## Si el GPS falla

Dentro del túnel, o si el teléfono pierde señal, están los botones **«Ya salí»**
y **«Ya llegué»**: marcan la hora igual, y quedan señalados como marca manual.

---

## Dónde queda todo

En el teléfono, por persona y por día. Al volver a entrar al mismo servicio se
retoma donde iba, con las paradas ya marcadas.

---

## Lo que todavía no hace

- No manda el reporte a ninguna parte: por ahora queda guardado en el teléfono.
- No pasa las horas reales a **Mi Alistación** de forma automática.
- El aviso de prevención es visual; no suena ni habla.
- «Laja» no tiene coordenadas en el trazado guardado, así que en los servicios
  que llegan hasta allá esa parada hay que marcarla a mano.

---

## Borrar lo marcado

Al final de la lista de servicios hay dos botones:

- **🗑 Borrar y salir** — borra el registro del día completo y cierra el modo.
  Es el que se usa cuando se abrió solo a mirar y no se está en servicio.
- **↺ Borrar lo marcado (n)** — borra las horas del día pero deja el modo
  abierto. Si no hay nada marcado, en su lugar aparece **✕ Salir**.

Dentro de un servicio en curso está además **🗑 Borrar este servicio**, que
limpia solo ese tren y lo deja como si no se hubiera empezado.

Los tres preguntan antes y dicen qué se pierde:

> Vas a borrar el registro de hoy de B. Bustamante.
> Se pierde: 2 horas anotadas con sus atrasos y motivos.
> ¿Borrar?

# CarreraBot

Trabajo Final de Algoritmia y Lógica Computacional (UCA).
Alumno: Ignacio Di Bartolo.

Sistema experto de correlatividades académicas: la base de conocimiento y el
motor de inferencia están en Prolog (`carrerabot.pl`) y se consultan desde
Python con PySwip, con una interfaz gráfica de chat en Tkinter
(`carrerabot_gui.py`). Usa el plan real de (285) Ingeniería en Informática
(65 materias) y responde qué se puede cursar, qué falta para cada materia,
recomendaciones, simulaciones y un análisis del avance con una máquina de
Turing. El detalle completo está en el informe.

## Requisitos

1. **Python 3**
2. **SWI-Prolog**
3. **PySwip**
4. **Tkinter**

## Ejecución

Desde esta carpeta:

```
python3 carrerabot_gui.py
```

En la primera ejecución se carga la historia académica real del alumno; al
cerrar, el estado se guarda en `estado_carrera.txt` y se restaura al volver
a abrir.

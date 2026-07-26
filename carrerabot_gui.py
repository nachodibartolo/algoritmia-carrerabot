# =====================================================================
#  CarreraBot - Sistema experto de correlatividades academicas
#  Trabajo Final - Algoritmia y Logica Computacional (UCA)
#  Alumno: Ignacio Di Bartolo
#
#  Interfaz grafica (Tkinter) + puente Python <-> SWI-Prolog (PySwip).
#  La base de conocimiento y el motor de inferencia estan en Prolog
#  (archivo carrerabot.pl); este modulo solo consulta al motor y
#  presenta los resultados en un chat.
#
#  Librerias necesarias y como instalarlas:
#    - SWI-Prolog (motor de inferencia, programa externo):
#        macOS:   brew install swi-prolog
#        Linux:   sudo apt-get install swi-prolog
#        Windows: instalador desde https://www.swi-prolog.org
#    - pyswip (puente Python <-> SWI-Prolog):
#        pip install pyswip        (o pip3 install pyswip)
#    - tkinter (interfaz grafica): viene incluida con Python.
#        macOS (python de Homebrew): brew install python-tk
#        Linux (si faltara):         sudo apt-get install python3-tk
#    - os / pathlib: modulos estandar de Python, no requieren instalacion.
#
#  Ejecucion:  python3 carrerabot_gui.py
# =====================================================================

import os
from pathlib import Path

from pyswip import Prolog

import tkinter as tk
from tkinter import font as tkfont
from tkinter import messagebox
from tkinter import ttk

# Carpeta donde vive este script: se usa para localizar carrerabot.pl
# y el archivo de estado, sin depender de desde donde se ejecute.
CARPETA = Path(__file__).resolve().parent
ARCHIVO_PROLOG = "carrerabot.pl"
ARCHIVO_ESTADO = CARPETA / "estado_carrera.txt"


class ExpertoCarrera:
    """Puente entre Python y el sistema experto escrito en Prolog.

    Cada metodo publico se corresponde con uno o mas predicados de
    carrerabot.pl. Python nunca razona sobre correlatividades: solo
    consulta al motor de inferencia de Prolog y formatea resultados.
    """

    def __init__(self):
        # PySwip resuelve rutas relativas contra el directorio actual,
        # por eso nos paramos en la carpeta del proyecto antes del consult.
        os.chdir(CARPETA)
        self.prolog = Prolog()
        self.prolog.consult(ARCHIVO_PROLOG)
        # Cache slug -> nombre completo (los nombres no cambian).
        self.nombres = {
            r["M"]: r["N"] for r in self.prolog.query("nombre(M, N)")
        }

    # ----------------- helpers internos -----------------

    def _q(self, consulta):
        """Ejecuta una consulta Prolog y devuelve la lista de soluciones."""
        return list(self.prolog.query(consulta))

    def _ok(self, consulta):
        """True si la consulta tiene al menos una solucion (exito)."""
        return bool(self._q(consulta))

    def nombre_de(self, slug):
        return self.nombres.get(slug, slug)

    # ----------------- estado de la carrera -----------------

    def materias_info(self):
        """[(slug, nombre, anio, cuatri, estado, nota), ...] en orden de
        plan. La nota es -1 si la materia no tiene nota numerica."""
        filas = self._q("materias_info(L)")[0]["L"]
        return [(m, n, a, c, e, nt) for m, n, a, c, e, nt in filas]

    def estado_de(self, slug):
        return self._q(f"estado_materia({slug}, E)")[0]["E"]

    def aprobar(self, slug):
        """Registra una materia como aprobada. Devuelve True si el motor
        valido la operacion (todas las correlativas aprobadas)."""
        return self._ok(f"aprobar({slug})")

    def desaprobar(self, slug):
        return self._ok(f"desaprobar({slug})")

    def faltantes_directas(self, slug):
        """Correlativas directas aun no aprobadas (modulo de explicacion)."""
        return [r["F"] for r in self._q(f"falta_para({slug}, F)")]

    def dependientes_aprobadas(self, slug):
        """Materias aprobadas que dependen de slug (impiden desaprobarla)."""
        return sorted({r["X"] for r in self._q(f"impide_desaprobar({slug}, X)")})

    # ----------------- motor de inferencia -----------------

    def cursables(self):
        """Materias disponibles para cursar, en orden curricular."""
        return [r["M"] for r in self._q("plan(M, _, _), puede_cursar(M)")]

    def camino_para(self, slug):
        """Ruta pendiente (ordenada por plan) para llegar a una materia."""
        return self._q(f"camino_para({slug}, C)")[0]["C"]

    def desbloquea(self, slug):
        return self._q(f"desbloquea({slug}, N)")[0]["N"]

    def recomendaciones(self):
        """[(impacto, slug), ...] cursables ordenadas por impacto desc."""
        return [(n, m) for n, m in self._q("recomendaciones(L)")[0]["L"]]

    def mejor_cursada(self, k=3):
        """Mejor combinacion de k materias (busqueda exhaustiva en Prolog).
        Devuelve (seleccion, valor) o None si no hay cursables."""
        r = self._q(f"mejor_cursada({k}, Sel, Valor)")
        if not r:
            return None
        return (list(r[0]["Sel"]), r[0]["Valor"])

    def simular(self, slug):
        """Materias que se habilitarian de inmediato al aprobar slug."""
        r = self._q(f"simular_aprobar({slug}, Nuevas)")
        return list(r[0]["Nuevas"]) if r else None

    # ----------------- progreso -----------------

    def progreso(self):
        r = self._q("progreso(A, T)")[0]
        return (r["A"], r["T"])

    def progreso_por_anio(self):
        return [(r["Anio"], r["A"], r["T"])
                for r in self._q("progreso_anio(Anio, A, T)")]

    def promedio(self):
        """Promedio de las notas numericas, o None si no hay notas."""
        r = self._q("promedio(P)")
        return r[0]["P"] if r else None

    # ----------------- maquina de Turing -----------------

    def avance_turing(self):
        """Ejecuta la MT sobre la cinta de avance.
        Devuelve (cinta, 'ordenado'|'desordenado', [arrastradas])."""
        r = self._q("avance_ordenado(Cinta, Res)")[0]
        arrastradas = [x["M"] for x in self._q("plan(M, _, _), arrastrada(M)")]
        return (list(r["Cinta"]), r["Res"], arrastradas)

    # ----------------- persistencia del estado -----------------

    def guardar_estado(self):
        """Guarda las materias aprobadas (una por linea) para la proxima
        sesion. El estado dinamico de Prolog vive solo en memoria."""
        aprobadas = [r["M"] for r in self._q("plan(M, _, _), aprobada(M)")]
        ARCHIVO_ESTADO.write_text("\n".join(aprobadas), encoding="utf-8")

    def cargar_estado(self):
        """Restaura el estado guardado. Devuelve cuantas materias cargo.
        En la primera ejecucion (sin estado guardado) carga la historia
        academica real del alumno definida en carrerabot.pl."""
        if not ARCHIVO_ESTADO.exists():
            self._ok("cargar_historia")
            return self.progreso()[0]
        cargadas = 0
        for linea in ARCHIVO_ESTADO.read_text(encoding="utf-8").splitlines():
            slug = linea.strip()
            if slug and self._ok(f"cargar_aprobada({slug})"):
                cargadas += 1
        return cargadas


class CarreraBotGUI:
    """Interfaz grafica del sistema experto.

    El flujo de interaccion esta gobernado por un AUTOMATA FINITO
    DETERMINISTA (DFA) implementado de forma explicita (ver el
    diccionario DFA): cada seleccion del usuario es un simbolo de
    entrada que dispara una transicion de estado, y los widgets se
    habilitan o deshabilitan segun el estado actual.

      Estados:
        S0 = inicio            (esperando que se elija una accion)
        S1 = esperando materia (la accion elegida necesita una materia)
        S2 = listo             (la consulta puede ejecutarse)

      Alfabeto de entrada (eventos):
        accion_simple      -> se eligio una accion que no pide materia
        accion_con_materia -> se eligio una accion que pide materia
        materia_elegida    -> se eligio una materia en el desplegable
        consultar          -> se presiono el boton Consultar

    S2 es el estado de aceptacion: solo alli el boton esta habilitado.
    Al ejecutarse la consulta, el automata vuelve al estado inicial S0.
    """

    # Funcion de transicion delta: (estado, evento) -> estado
    DFA = {
        ("S0", "accion_simple"):      "S2",
        ("S0", "accion_con_materia"): "S1",
        ("S1", "accion_simple"):      "S2",
        ("S1", "accion_con_materia"): "S1",
        ("S1", "materia_elegida"):    "S2",
        ("S2", "accion_simple"):      "S2",
        ("S2", "accion_con_materia"): "S1",
        ("S2", "materia_elegida"):    "S2",
        ("S2", "consultar"):          "S0",
    }

    # Paleta de colores de la interfaz
    COLOR_HEADER = "#2c3e50"
    COLOR_FONDO = "#f0f2f5"
    COLOR_APROBADA = "#27ae60"
    COLOR_DISPONIBLE = "#2980b9"
    COLOR_BLOQUEADA = "#95a5a6"

    ICONOS_ESTADO = {"aprobada": "✅", "disponible": "🟢", "bloqueada": "🔒"}

    def __init__(self, root):
        self.bot = ExpertoCarrera()
        self.estado = "S0"  # estado actual del DFA

        self.root = root
        self.root.title("CarreraBot 🎓")
        self.root.geometry("1200x760")
        self.root.configure(bg=self.COLOR_FONDO)
        self.root.minsize(1060, 640)
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

        # En macOS con modo oscuro, los widgets ttk heredan el tema del
        # sistema y desentonan con el fondo claro de la app: se fuerza la
        # apariencia clara de la ventana (si la version de Tk lo permite).
        try:
            self.root.tk.call("tk::unsupported::MacWindowStyle",
                              "appearance", self.root, "aqua")
        except tk.TclError:
            pass

        self.fuente_titulo = tkfont.Font(family="Helvetica Neue", size=16, weight="bold")
        self.fuente_texto = tkfont.Font(family="Helvetica Neue", size=12)
        self.fuente_lista = tkfont.Font(family="Helvetica Neue", size=12)
        self.fuente_boton = tkfont.Font(family="Helvetica Neue", size=12, weight="bold")

        # Acciones disponibles: (etiqueta, requiere_materia, handler)
        self.acciones = [
            ("¿Qué puedo cursar ahora?",            False, self.h_que_puedo_cursar),
            ("¿Qué me falta para una materia?",     True,  self.h_que_me_falta),
            ("Recomendame qué cursar",              False, self.h_recomendar),
            ("Simular que apruebo una materia",     True,  self.h_simular),
            ("Ver mi progreso",                     False, self.h_progreso),
            ("Analizar mi avance (Máq. de Turing)", False, self.h_turing),
        ]

        # El footer y los controles se anclan abajo ANTES de empaquetar el
        # cuerpo: asi Tk les reserva espacio aunque la ventana sea chica.
        self._armar_header()
        self._armar_footer()
        self._armar_controles()
        self._armar_cuerpo()

        # Restaurar la sesion anterior, si existe.
        cargadas = self.bot.cargar_estado()
        self.refrescar_plan()
        self._aplicar_estado()

        self.mensaje_bot(
            "¡Hola! Soy CarreraBot 🎓, tu asesor de correlatividades.\n"
            "Plan cargado: (285) Ingeniería en Informática — UCA, "
            "plan INF 2016 (v_3), 65 actividades académicas.\n"
            "En el panel de la izquierda marcá las materias que vayas "
            "aprobando y elegí una consulta en el menú de abajo.\n"
            "Puedo decirte qué podés cursar, qué te falta para cada materia, "
            "recomendarte la próxima cursada, simular aprobaciones y analizar "
            "tu avance con una Máquina de Turing."
        )
        if cargadas:
            aprobadas, total = self.bot.progreso()
            self.mensaje_bot(
                f"Cargué tu historia académica: {aprobadas} de {total} "
                "actividades aprobadas. 💾"
            )

    # ================= construccion de la interfaz =================

    def _armar_header(self):
        header = tk.Frame(self.root, bg=self.COLOR_HEADER, height=64)
        header.pack(fill=tk.X)
        tk.Label(
            header, text="CarreraBot 🎓  —  Sistema experto de correlatividades",
            font=self.fuente_titulo, fg="white", bg=self.COLOR_HEADER,
        ).pack(side=tk.LEFT, padx=20, pady=14)

    def _armar_cuerpo(self):
        cuerpo = tk.Frame(self.root, bg=self.COLOR_FONDO)
        cuerpo.pack(fill=tk.BOTH, expand=True, padx=14, pady=10)

        # ---------- panel izquierdo: plan de estudios ----------
        panel_plan = tk.Frame(cuerpo, bg=self.COLOR_FONDO)
        panel_plan.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))

        tk.Label(
            panel_plan, text="Plan de estudios",
            font=self.fuente_boton, bg=self.COLOR_FONDO, fg="#333333",
        ).pack(anchor="w")

        marco_lista = tk.Frame(panel_plan, bg="white", bd=2, relief=tk.GROOVE)
        marco_lista.pack(fill=tk.BOTH, expand=True, pady=(4, 6))

        self.lista_plan = tk.Listbox(
            marco_lista, width=52, height=20, font=self.fuente_lista,
            bg="white", bd=0, highlightthickness=0, activestyle="none",
            selectbackground="#d6e4f0", selectforeground="#000000",
        )
        self.lista_plan.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=4, pady=4)

        scroll_plan = ttk.Scrollbar(marco_lista, command=self.lista_plan.yview)
        scroll_plan.pack(side=tk.RIGHT, fill=tk.Y)
        self.lista_plan.config(yscrollcommand=scroll_plan.set)

        botones = tk.Frame(panel_plan, bg=self.COLOR_FONDO)
        botones.pack(fill=tk.X)
        tk.Button(
            botones, text="✔ Aprobé esta materia", font=self.fuente_texto,
            command=self.on_marcar_aprobada,
        ).pack(side=tk.LEFT, expand=True, fill=tk.X, padx=(0, 4))
        tk.Button(
            botones, text="↩ Quitar aprobada", font=self.fuente_texto,
            command=self.on_quitar_aprobada,
        ).pack(side=tk.LEFT, expand=True, fill=tk.X)

        tk.Label(
            panel_plan,
            text="✅ aprobada    🟢 disponible    🔒 bloqueada",
            font=self.fuente_texto, bg=self.COLOR_FONDO, fg="#666666",
        ).pack(anchor="w", pady=(6, 0))

        # ---------- panel derecho: chat ----------
        marco_chat = tk.Frame(cuerpo, bg="white", bd=2, relief=tk.GROOVE)
        marco_chat.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.chat = tk.Text(
            marco_chat, state="disabled", bg="white", fg="#333333",
            font=self.fuente_texto, padx=12, pady=10, wrap=tk.WORD,
            bd=0, highlightthickness=0,
        )
        self.chat.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=4, pady=4)

        scroll_chat = ttk.Scrollbar(marco_chat, command=self.chat.yview)
        scroll_chat.pack(side=tk.RIGHT, fill=tk.Y)
        self.chat.config(yscrollcommand=scroll_chat.set)

        self.chat.tag_config("bot", foreground="#2c3e50", lmargin1=14,
                             lmargin2=30, spacing3=8)
        self.chat.tag_config("usuario", foreground="#2980b9", lmargin1=14,
                             lmargin2=30, spacing3=8)

    def _armar_controles(self):
        controles = tk.Frame(self.root, bg=self.COLOR_FONDO)
        controles.pack(side=tk.BOTTOM, fill=tk.X, padx=14, pady=(0, 6))

        tk.Label(
            controles, text="Consulta:", font=self.fuente_texto,
            bg=self.COLOR_FONDO, fg="#333333",
        ).grid(row=0, column=0, padx=(0, 6), sticky="w")

        self.var_accion = tk.StringVar()
        self.combo_accion = ttk.Combobox(
            controles, textvariable=self.var_accion, state="readonly",
            font=self.fuente_texto, width=34,
            values=[etiqueta for etiqueta, _, _ in self.acciones],
        )
        self.combo_accion.set("Elegí una consulta")
        self.combo_accion.grid(row=0, column=1, padx=4, pady=6, sticky="ew")
        self.combo_accion.bind("<<ComboboxSelected>>", self.on_accion_seleccionada)

        tk.Label(
            controles, text="Materia:", font=self.fuente_texto,
            bg=self.COLOR_FONDO, fg="#333333",
        ).grid(row=0, column=2, padx=(12, 6), sticky="w")

        self.var_materia = tk.StringVar()
        self.combo_materia = ttk.Combobox(
            controles, textvariable=self.var_materia, state="disabled",
            font=self.fuente_texto, width=30,
            values=[self.bot.nombre_de(m) for m, *_ in self.bot.materias_info()],
        )
        self.combo_materia.set("—")
        self.combo_materia.grid(row=0, column=3, padx=4, pady=6, sticky="ew")
        self.combo_materia.bind("<<ComboboxSelected>>", self.on_materia_seleccionada)

        self.boton_consultar = tk.Button(
            controles, text="🔎 Consultar", font=self.fuente_boton,
            state="disabled", command=self.on_consultar, padx=16,
        )
        self.boton_consultar.grid(row=0, column=4, padx=(12, 0), pady=6)

        controles.grid_columnconfigure(1, weight=1)
        controles.grid_columnconfigure(3, weight=1)

    def _armar_footer(self):
        footer = tk.Frame(self.root, bg="#ecf0f1", height=34)
        footer.pack(side=tk.BOTTOM, fill=tk.X)
        tk.Label(
            footer,
            text="© 2026 CarreraBot — Trabajo Final de Algoritmia y Lógica "
                 "Computacional · Prolog + PySwip + Tkinter",
            font=("Helvetica Neue", 10), fg="#7f8c8d", bg="#ecf0f1",
        ).pack(pady=8)

    # ================= automata finito (DFA) =================

    def transicion(self, evento):
        """Aplica la funcion de transicion del DFA y actualiza la interfaz.
        Un evento no definido para el estado actual se ignora (la cadena
        de entrada no avanza)."""
        nuevo = self.DFA.get((self.estado, evento))
        if nuevo is not None:
            self.estado = nuevo
            self._aplicar_estado()

    def _aplicar_estado(self):
        """Habilita/deshabilita widgets segun el estado actual del DFA."""
        if self.estado == "S0":
            self.combo_accion.set("Elegí una consulta")
            self.combo_materia.set("—")
            self.combo_materia.config(state="disabled")
            self.boton_consultar.config(state="disabled")
        elif self.estado == "S1":
            self.combo_materia.config(state="readonly")
            if self.var_materia.get() == "—":
                self.combo_materia.set("Elegí una materia")
            self.boton_consultar.config(state="disabled")
        elif self.estado == "S2":
            accion = self._accion_actual()
            if accion is not None and accion[1]:  # la accion usa materia
                self.combo_materia.config(state="readonly")
            else:
                self.combo_materia.set("—")
                self.combo_materia.config(state="disabled")
            self.boton_consultar.config(state="normal")

    def _accion_actual(self):
        for accion in self.acciones:
            if accion[0] == self.var_accion.get():
                return accion
        return None

    def _materia_actual(self):
        nombre = self.var_materia.get()
        for slug, nom in self.bot.nombres.items():
            if nom == nombre:
                return slug
        return None

    # ================= eventos de la interfaz =================

    def on_accion_seleccionada(self, _evento):
        accion = self._accion_actual()
        if accion is None:
            return
        self.mensaje_usuario(accion[0])
        if accion[1]:
            self.transicion("accion_con_materia")
            self.mensaje_bot("¿Sobre qué materia querés consultar? "
                             "Elegila en el desplegable «Materia».")
        else:
            self.transicion("accion_simple")

    def on_materia_seleccionada(self, _evento):
        slug = self._materia_actual()
        if slug is None:
            return
        self.mensaje_usuario(f"Materia: {self.bot.nombre_de(slug)}")
        self.transicion("materia_elegida")

    def on_consultar(self):
        accion = self._accion_actual()
        if accion is None:
            return
        etiqueta, requiere_materia, handler = accion
        slug = self._materia_actual() if requiere_materia else None
        if requiere_materia and slug is None:
            messagebox.showerror("Error", "Elegí una materia válida.")
            return

        self.boton_consultar.config(state="disabled", text="Consultando…")
        self.root.update()
        try:
            if requiere_materia:
                handler(slug)
            else:
                handler()
        except Exception as e:  # errores inesperados del puente Prolog
            messagebox.showerror("Error", f"Ocurrió un error: {e}")
        finally:
            self.boton_consultar.config(text="🔎 Consultar")
            self.transicion("consultar")  # el DFA vuelve al estado inicial

    def on_marcar_aprobada(self):
        slug = self._slug_seleccionado_en_lista()
        if slug is None:
            return
        nombre = self.bot.nombre_de(slug)
        self.mensaje_usuario(f"Aprobé {nombre}")

        if self.bot.estado_de(slug) == "aprobada":
            self.mensaje_bot(f"{nombre} ya figuraba como aprobada. 😉")
            return

        antes = set(self.bot.cursables())
        if self.bot.aprobar(slug):
            nuevas = [m for m in self.bot.cursables() if m not in antes]
            texto = f"¡Felicitaciones! 🎉 Registré {nombre} como aprobada."
            if nuevas:
                texto += ("\nCon esto se habilitan: "
                          + ", ".join(self.bot.nombre_de(m) for m in nuevas) + ".")
            self.mensaje_bot(texto)
            self.refrescar_plan()
        else:
            # Modulo de explicacion: el motor rechazo la operacion.
            faltan = self.bot.faltantes_directas(slug)
            self.mensaje_bot(
                f"No puedo registrar {nombre} como aprobada: según el "
                "régimen de correlatividades primero necesitás aprobar "
                + ", ".join(self.bot.nombre_de(f) for f in faltan) + ". 🔒"
            )

    def on_quitar_aprobada(self):
        slug = self._slug_seleccionado_en_lista()
        if slug is None:
            return
        nombre = self.bot.nombre_de(slug)
        self.mensaje_usuario(f"Quitar {nombre} de mis aprobadas")

        if self.bot.estado_de(slug) != "aprobada":
            self.mensaje_bot(f"{nombre} no figura como aprobada.")
            return

        if self.bot.desaprobar(slug):
            self.mensaje_bot(f"Listo, quité {nombre} de tus aprobadas. ↩")
            self.refrescar_plan()
        else:
            deps = self.bot.dependientes_aprobadas(slug)
            self.mensaje_bot(
                f"No puedo quitar {nombre}: tenés aprobadas materias que "
                "dependen de ella ("
                + ", ".join(self.bot.nombre_de(d) for d in deps)
                + "). Quitá esas primero para mantener la base consistente."
            )

    def on_close(self):
        """Al cerrar la ventana se persiste el estado de la sesion."""
        try:
            self.bot.guardar_estado()
        finally:
            self.root.destroy()

    # ================= handlers de consultas =================

    def h_que_puedo_cursar(self):
        cursables = self.bot.cursables()
        if not cursables:
            aprobadas, total = self.bot.progreso()
            if aprobadas == total:
                self.mensaje_bot("¡Aprobaste todo el plan! 🏆 No queda nada "
                                 "por cursar. ¡Felicitaciones, futuro colega!")
            else:
                self.mensaje_bot("No encuentro materias disponibles. 🤔")
            return
        lineas = [self._linea_materia(m) for m in cursables]
        self.mensaje_bot(
            f"Con tu estado actual podés cursar {len(cursables)} materia(s): 📗\n"
            + "\n".join(lineas)
        )

    def h_que_me_falta(self, slug):
        nombre = self.bot.nombre_de(slug)
        estado = self.bot.estado_de(slug)
        if estado == "aprobada":
            self.mensaje_bot(f"¡{nombre} ya la aprobaste! 🎉 No te falta nada.")
            return
        if estado == "disponible":
            self.mensaje_bot(
                f"¡Buenas noticias! {nombre} ya está disponible: tenés todas "
                "sus correlativas aprobadas. La podés cursar ahora. 🟢"
            )
            return
        directas = self.bot.faltantes_directas(slug)
        camino = self.bot.camino_para(slug)
        texto = (
            f"Para cursar {nombre} te faltan estas correlativas directas: 🔒\n"
            + "\n".join(f"   • {self.bot.nombre_de(f)}" for f in directas)
        )
        if len(camino) > len(directas):
            texto += (
                f"\nContando prerequisitos indirectos, el camino completo son "
                f"{len(camino)} materias. Ruta sugerida (en orden del plan): 🗺️\n"
                + " → ".join(self.bot.nombre_de(m) for m in camino)
                + f"\n…y ahí ya podés anotarte en {nombre}."
            )
        self.mensaje_bot(texto)

    def h_recomendar(self):
        recomendadas = self.bot.recomendaciones()
        if not recomendadas:
            self.mensaje_bot("No hay materias disponibles para recomendar. "
                             "Marcá tus aprobadas en el panel izquierdo. 🤔")
            return
        top = recomendadas[:5]
        lineas = []
        for i, (impacto, slug) in enumerate(top, start=1):
            detalle = (f"de ella dependen {impacto} materias del plan"
                       if impacto else "no traba ninguna materia")
            lineas.append(f"   {i}. {self.bot.nombre_de(slug)} — {detalle}")
        texto = ("Ranking de cursables por impacto en tu carrera: 🏆\n"
                 + "\n".join(lineas))

        resultado = self.bot.mejor_cursada(3)
        if resultado:
            seleccion, valor = resultado
            texto += (
                "\n\nBusqué entre todas las combinaciones posibles de 3 "
                "materias cursables (búsqueda exhaustiva, C(n,3) casos) y la "
                "mejor cursada para el próximo cuatrimestre es: 🧮\n   "
                + "  +  ".join(self.bot.nombre_de(m) for m in seleccion)
            )
            if valor:
                texto += f"\nAprobándolas se te habilitan {valor} materia(s) nueva(s)."
            else:
                texto += ("\nNo habilita materias nuevas de inmediato, pero es "
                          "el mayor avance posible.")
        self.mensaje_bot(texto)

    def h_simular(self, slug):
        nombre = self.bot.nombre_de(slug)
        estado = self.bot.estado_de(slug)
        if estado == "aprobada":
            self.mensaje_bot(f"{nombre} ya está aprobada, no hay nada que simular. 😉")
            return
        if estado == "bloqueada":
            faltan = self.bot.faltantes_directas(slug)
            self.mensaje_bot(
                f"Todavía no podés cursar {nombre}, así que no simulo su "
                "aprobación. Antes necesitás: "
                + ", ".join(self.bot.nombre_de(f) for f in faltan) + ". 🔒"
            )
            return
        nuevas = self.bot.simular(slug) or []
        impacto = self.bot.desbloquea(slug)
        if nuevas:
            texto = (
                f"Simulación 🔮: si aprobás {nombre}, se habilitan de inmediato:\n"
                + "\n".join(f"   • {self.bot.nombre_de(m)}" for m in nuevas)
            )
        else:
            texto = (f"Simulación 🔮: aprobar {nombre} no habilita materias "
                     "nuevas de inmediato (sus dependientes tienen otras "
                     "correlativas pendientes).")
        texto += (f"\nEn total, {impacto} materia(s) del plan dependen de "
                  f"{nombre}." if impacto else
                  f"\nNinguna materia del plan depende de {nombre}.")
        texto += "\n(La simulación no modificó tu estado real.)"
        self.mensaje_bot(texto)

    def h_progreso(self):
        aprobadas, total = self.bot.progreso()
        porcentaje = 100 * aprobadas / total if total else 0
        lineas = [f"Tu progreso general: {aprobadas}/{total} actividades "
                  f"({porcentaje:.1f}%) 📊"]
        for anio, a, t in self.bot.progreso_por_anio():
            llenos = round(10 * a / t) if t else 0
            barra = "▓" * llenos + "░" * (10 - llenos)
            lineas.append(f"   Año {anio}:  {barra}  {a}/{t}")
        promedio = self.bot.promedio()
        if promedio is not None:
            lineas.append(f"Promedio general (materias con nota): "
                          f"{promedio:.2f} 🎯")
        if aprobadas == total:
            lineas.append("¡Plan completo! 🏆")
        self.mensaje_bot("\n".join(lineas))

    def h_turing(self):
        cinta, resultado, arrastradas = self.bot.avance_turing()
        # La cinta formal es una sola cadena de 65 simbolos; para leerla
        # mas comodo se muestra una linea por anio del plan.
        anios = [a for _, _, a, _, _, _ in self.bot.materias_info()]
        lineas_cinta, inicio = [], 0
        for anio in sorted(set(anios)):
            cantidad = anios.count(anio)
            tramo = " ".join(str(b) for b in cinta[inicio:inicio + cantidad])
            lineas_cinta.append(f"      Año {anio}:  {tramo}")
            inicio += cantidad
        texto = (
            "Ejecuté la Máquina de Turing sobre tu cinta de avance 🤖\n"
            "(una celda por materia, en el orden del plan; 1 = aprobada, "
            "0 = pendiente):\n   📼 Cinta:\n" + "\n".join(lineas_cinta) + "\n"
        )
        if resultado == "ordenado":
            texto += (
                "✅ CADENA ACEPTADA — pertenece al lenguaje 1ⁿ0ᵐ: tu avance "
                "sigue estrictamente el orden del plan, sin materias "
                "arrastradas. ¡Impecable!"
            )
        else:
            mostradas = arrastradas[:10]
            detalle = "\n".join(f"   • {self.bot.nombre_de(m)}"
                                for m in mostradas)
            if len(arrastradas) > len(mostradas):
                detalle += f"\n   … y {len(arrastradas) - len(mostradas)} más."
            texto += (
                "❌ CADENA RECHAZADA — la máquina encontró un 1 después de un "
                "0 (no pertenece a 1ⁿ0ᵐ): tenés materias pendientes anteriores "
                "a otras que ya aprobaste.\nMaterias arrastradas: ⚠️\n"
                + detalle
            )
        self.mensaje_bot(texto)

    # ================= utilidades de la interfaz =================

    def _linea_materia(self, slug):
        for m, nom, anio, cuatri, _, _ in self.bot.materias_info():
            if m == slug:
                return f"   • {nom}  (Año {anio} · C{cuatri})"
        return f"   • {slug}"

    def _slug_seleccionado_en_lista(self):
        seleccion = self.lista_plan.curselection()
        if not seleccion:
            messagebox.showinfo("Plan de estudios",
                                "Primero seleccioná una materia en la lista.")
            return None
        return self.orden_plan[seleccion[0]]

    def refrescar_plan(self):
        """Redibuja el listado del plan con el estado actual de cada materia."""
        colores = {
            "aprobada": self.COLOR_APROBADA,
            "disponible": self.COLOR_DISPONIBLE,
            "bloqueada": self.COLOR_BLOQUEADA,
        }
        seleccion = self.lista_plan.curselection()
        self.lista_plan.delete(0, tk.END)
        self.orden_plan = []
        for slug, nom, anio, cuatri, estado, nota in self.bot.materias_info():
            self.orden_plan.append(slug)
            icono = self.ICONOS_ESTADO[estado]
            etiqueta = f" {icono}  {nom}  · A{anio}C{cuatri}"
            if estado == "aprobada" and nota >= 0:
                etiqueta += f" · {nota}"
            self.lista_plan.insert(tk.END, etiqueta)
            self.lista_plan.itemconfig(tk.END, foreground=colores[estado])
        if seleccion:
            self.lista_plan.selection_set(seleccion[0])

    def mensaje_bot(self, texto):
        self._agregar_chat(f"🤖 {texto}\n\n", "bot")

    def mensaje_usuario(self, texto):
        self._agregar_chat(f"🧑‍🎓 {texto}\n\n", "usuario")

    def _agregar_chat(self, texto, tag):
        self.chat.config(state="normal")
        self.chat.insert(tk.END, texto, tag)
        self.chat.config(state="disabled")
        self.chat.see(tk.END)


def main():
    root = tk.Tk()
    CarreraBotGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()

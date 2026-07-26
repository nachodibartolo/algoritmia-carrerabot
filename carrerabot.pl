% =====================================================================
%  CarreraBot - Sistema experto de correlatividades academicas
%  Trabajo Final - Algoritmia y Logica Computacional (UCA)
%  Alumno: Ignacio Di Bartolo
%
%  Este archivo contiene la BASE DE CONOCIMIENTO y el MOTOR DE
%  INFERENCIA del sistema experto. Se consulta desde Python mediante
%  la libreria PySwip (ver carrerabot_gui.py).
%
%  Software necesario para que funcione:
%    - SWI-Prolog (interprete):  https://www.swi-prolog.org
%        macOS:   brew install swi-prolog
%        Linux:   sudo apt-get install swi-prolog
%        Windows: instalador desde el sitio oficial
%    - Este archivo usa solo predicados incorporados (built-ins) de
%      SWI-Prolog: no requiere instalar paquetes adicionales.
%
%  Organizacion del archivo:
%    1) Base de conocimiento: plan de estudios y correlatividades
%    2) Historia academica del alumno (notas y aprobadas)
%    3) Estado dinamico: materias aprobadas (assert/retract)
%    4) Motor de inferencia: reglas de correlatividad (recursivas)
%    5) Progreso de la carrera
%    6) Simulacion ("que pasa si apruebo X")
%    7) Seleccion optima de cursada (busqueda combinatoria, tema NP)
%    8) Maquina de Turing: analisis del avance del alumno
% =====================================================================

:- encoding(utf8).

% El estado "aprobada" se modifica en tiempo de ejecucion desde Python
% (modulo de adquisicion de conocimiento del sistema experto), por eso
% se declara dinamico al inicio del programa.
:- dynamic aprobada/1.


% =====================================================================
% 1) BASE DE CONOCIMIENTO: PLAN DE ESTUDIOS
% ---------------------------------------------------------------------
% Plan real: (285) Ingenieria en Informatica - UCA
% Plan (285INF2016) INF 2016, version v_3 - 65 actividades academicas.
% Fuente: reporte "Plan de estudios" del sistema de gestion academica
% (SIU Guarani) del alumno, archivo plan_estudios.xls.
%
%   materia(M)            : M es una actividad del plan (slug interno).
%   nombre(M, N)          : nombre completo (para mostrar en pantalla).
%   plan(M, Anio, Cuatri) : ubicacion de M en el plan. El ORDEN en que
%                           estan declarados estos hechos define el
%                           "orden curricular" que usa la Maquina de
%                           Turing de la seccion 8.
%   correlativa(M, C)     : para cursar M hay que tener aprobada C.
%
% NOTA sobre correlativa/2: el reporte del sistema academico no incluye
% el regimen de correlatividades, por lo que estas se estimaron a
% partir de las cadenas naturales del plan (Calculo Elemental ->
% Calculo Avanzado -> Matematica Superior; Fisica I -> II -> III;
% Programacion Estructurada -> POO I -> POO II; Ing. del Software
% I -> II -> III; etc.). Son faciles de ajustar: basta editar los
% hechos de esta seccion.
%
% De las materias optativas del catalogo solo se incluyen las dos que
% el alumno efectivamente curso (Innovacion y Emprendimiento del Ciclo
% I e Inteligencia Artificial del Ciclo II).
% =====================================================================

materia(calculo_elemental).
materia(representacion_grafica).
materia(informatica_general).
materia(intro_ingenieria).
materia(filosofia).
materia(complementos_matematica).
materia(algebra_geometria).
materia(fisica1).
materia(quimica).
materia(programacion_web).
materia(seminario1).
materia(redes_comunicacion).
materia(calculo_avanzado).
materia(fisica2).
materia(programacion_estructurada).
materia(administracion).
materia(etica_fundamentos).
materia(poo1).
materia(fisica3).
materia(probabilidad).
materia(matematica_superior).
materia(seminario2).
materia(idioma_castellano).
materia(idioma_ingles1).
materia(ingsoft1).
materia(electronica_digital).
materia(metodos_numericos).
materia(protocolos_internet).
materia(matematica_discreta).
materia(intro_teologia).
materia(arquitectura).
materia(estructura_datos).
materia(poo2).
materia(sistemas_operativos1).
materia(seminario3).
materia(optativa_innovacion).
materia(analisis_economico).
materia(algoritmia).
materia(ingsoft2).
materia(sistemas_operativos2).
materia(redes_area_amplia).
materia(sintesis_teologica).
materia(modelos_simulacion).
materia(base_datos).
materia(apps_moviles).
materia(seguridad_cripto).
materia(macroeconomia).
materia(legislacion).
materia(seminario4).
materia(prog_paralela).
materia(investigacion_operativa).
materia(base_datos_avanzada).
materia(ingsoft3).
materia(seguridad_aplicada).
materia(seminario_tf).
materia(moral_social).
materia(gerenciamiento).
materia(auditoria).
materia(proyecto_integral).
materia(economia_empresa).
materia(seminario5).
materia(optativa_ia).
materia(idioma_ingles2).
materia(pps).
materia(trabajo_final).

nombre(calculo_elemental,       'Cálculo Elemental').
nombre(representacion_grafica,  'Representación Gráfica').
nombre(informatica_general,     'Informática General').
nombre(intro_ingenieria,        'Introducción a la Ingeniería').
nombre(filosofia,               'Filosofía y Antropología').
nombre(complementos_matematica, 'Complementos de Matemática').
nombre(algebra_geometria,       'Álgebra y Geometría').
nombre(fisica1,                 'Física I (Mecánica)').
nombre(quimica,                 'Química General').
nombre(programacion_web,        'Programación Web').
nombre(seminario1,              'Seminario I').
nombre(redes_comunicacion,      'Redes de Comunicación').
nombre(calculo_avanzado,        'Cálculo Avanzado').
nombre(fisica2,                 'Física II (Calor y Óptica)').
nombre(programacion_estructurada, 'Programación Estructurada').
nombre(administracion,          'Administración de Empresas').
nombre(etica_fundamentos,       'Ética y sus Fundamentos').
nombre(poo1,                    'Programación Orientada a Objetos I').
nombre(fisica3,                 'Física III (Electricidad y Magnetismo)').
nombre(probabilidad,            'Probabilidad y Estadística').
nombre(matematica_superior,     'Matemática Superior').
nombre(seminario2,              'Seminario II').
nombre(idioma_castellano,       'Nivel de Idioma Castellano').
nombre(idioma_ingles1,          'Nivel de Idioma Inglés I').
nombre(ingsoft1,                'Ingeniería del Software I').
nombre(electronica_digital,     'Electrónica Digital').
nombre(metodos_numericos,       'Métodos Numéricos').
nombre(protocolos_internet,     'Protocolos de Internet').
nombre(matematica_discreta,     'Matemática Discreta').
nombre(intro_teologia,          'Introducción a la Teología').
nombre(arquitectura,            'Arquitectura de Computadoras').
nombre(estructura_datos,        'Estructura de Datos').
nombre(poo2,                    'Programación Orientada a Objetos II').
nombre(sistemas_operativos1,    'Sistemas Operativos I').
nombre(seminario3,              'Seminario III').
nombre(optativa_innovacion,     'Innovación y Emprendimiento (Optativa)').
nombre(analisis_economico,      'Análisis Económico y Optimización (Micro)').
nombre(algoritmia,              'Algoritmia y Lógica Computacional').
nombre(ingsoft2,                'Ingeniería del Software II').
nombre(sistemas_operativos2,    'Sistemas Operativos II').
nombre(redes_area_amplia,       'Redes y Protocolos de Área Amplia').
nombre(sintesis_teologica,      'Síntesis Teológica').
nombre(modelos_simulacion,      'Modelos y Simulación').
nombre(base_datos,              'Base de Datos').
nombre(apps_moviles,            'Programación de Aplicaciones Móviles').
nombre(seguridad_cripto,        'Seguridad Informática y Criptografía').
nombre(macroeconomia,           'Macroeconomía y Economía Argentina').
nombre(legislacion,             'Legislación Profesional').
nombre(seminario4,              'Seminario IV').
nombre(prog_paralela,           'Programación Paralela y Clusters').
nombre(investigacion_operativa, 'Investigación Operativa').
nombre(base_datos_avanzada,     'Base de Datos Avanzada y Big Data').
nombre(ingsoft3,                'Ingeniería del Software III').
nombre(seguridad_aplicada,      'Seguridad Informática Aplicada').
nombre(seminario_tf,            'Seminario Metodológico de TF').
nombre(moral_social,            'Moral y Compromiso Social').
nombre(gerenciamiento,          'Gerenciamiento y Evaluación de Proyectos').
nombre(auditoria,               'Auditoría Informática').
nombre(proyecto_integral,       'Proyecto Integral de Desarrollo').
nombre(economia_empresa,        'Economía de la Empresa').
nombre(seminario5,              'Seminario V').
nombre(optativa_ia,             'Inteligencia Artificial (Optativa)').
nombre(idioma_ingles2,          'Nivel de Idioma Inglés II').
nombre(pps,                     'Práctica Profesional Supervisada').
nombre(trabajo_final,           'Trabajo Final').

% --- Anio 1, 1er semestre ---
plan(calculo_elemental,       1, 1).
plan(representacion_grafica,  1, 1).
plan(informatica_general,     1, 1).
plan(intro_ingenieria,        1, 1).
plan(filosofia,               1, 1).
plan(complementos_matematica, 1, 1).   % nivelacion, sin periodo en el reporte
% --- Anio 1, 2do semestre ---
plan(algebra_geometria,       1, 2).
plan(fisica1,                 1, 2).
plan(quimica,                 1, 2).
plan(programacion_web,        1, 2).
plan(seminario1,              1, 2).
% --- Anio 2, 1er semestre ---
plan(redes_comunicacion,      2, 1).
plan(calculo_avanzado,        2, 1).
plan(fisica2,                 2, 1).
plan(programacion_estructurada, 2, 1).
plan(administracion,          2, 1).
plan(etica_fundamentos,       2, 1).
% --- Anio 2, 2do semestre ---
plan(poo1,                    2, 2).
plan(fisica3,                 2, 2).
plan(probabilidad,            2, 2).
plan(matematica_superior,     2, 2).
plan(seminario2,              2, 2).
plan(idioma_castellano,       2, 2).   % sin periodo en el reporte
plan(idioma_ingles1,          2, 2).   % sin periodo en el reporte
% --- Anio 3, 1er semestre ---
plan(ingsoft1,                3, 1).
plan(electronica_digital,     3, 1).
plan(metodos_numericos,       3, 1).
plan(protocolos_internet,     3, 1).
plan(matematica_discreta,     3, 1).
plan(intro_teologia,          3, 1).
% --- Anio 3, 2do semestre ---
plan(arquitectura,            3, 2).
plan(estructura_datos,        3, 2).
plan(poo2,                    3, 2).
plan(sistemas_operativos1,    3, 2).
plan(seminario3,              3, 2).
plan(optativa_innovacion,     3, 2).   % Optativa Ciclo I elegida
% --- Anio 4, 1er semestre ---
plan(analisis_economico,      4, 1).
plan(algoritmia,              4, 1).
plan(ingsoft2,                4, 1).
plan(sistemas_operativos2,    4, 1).
plan(redes_area_amplia,       4, 1).
plan(sintesis_teologica,      4, 1).
% --- Anio 4, 2do semestre ---
plan(modelos_simulacion,      4, 2).
plan(base_datos,              4, 2).
plan(apps_moviles,            4, 2).
plan(seguridad_cripto,        4, 2).
plan(macroeconomia,           4, 2).
plan(legislacion,             4, 2).
plan(seminario4,              4, 2).
% --- Anio 5, 1er semestre ---
plan(prog_paralela,           5, 1).
plan(investigacion_operativa, 5, 1).
plan(base_datos_avanzada,     5, 1).
plan(ingsoft3,                5, 1).
plan(seguridad_aplicada,      5, 1).
plan(seminario_tf,            5, 1).
plan(moral_social,            5, 1).
% --- Anio 5, 2do semestre y tramo final ---
plan(gerenciamiento,          5, 2).
plan(auditoria,               5, 2).
plan(proyecto_integral,       5, 2).
plan(economia_empresa,        5, 2).
plan(seminario5,              5, 2).
plan(optativa_ia,             5, 2).   % Optativa Ciclo II elegida
plan(idioma_ingles2,          5, 2).
plan(pps,                     5, 2).   % sin periodo en el reporte
plan(trabajo_final,           5, 2).   % sin periodo en el reporte

% correlativa(Materia, Requerida): grafo dirigido aciclico (DAG).
% --- cadena matematica ---
correlativa(calculo_avanzado,       calculo_elemental).
correlativa(calculo_avanzado,       algebra_geometria).
correlativa(matematica_superior,    calculo_avanzado).
correlativa(probabilidad,           calculo_avanzado).
correlativa(matematica_discreta,    algebra_geometria).
correlativa(metodos_numericos,      calculo_avanzado).
correlativa(metodos_numericos,      algebra_geometria).
correlativa(investigacion_operativa, probabilidad).
correlativa(investigacion_operativa, metodos_numericos).
% --- cadena fisica ---
correlativa(fisica1,                calculo_elemental).
correlativa(fisica2,                fisica1).
correlativa(fisica3,                fisica2).
correlativa(electronica_digital,    fisica3).
% --- cadena de programacion ---
correlativa(programacion_web,       informatica_general).
correlativa(programacion_estructurada, informatica_general).
correlativa(poo1,                   programacion_estructurada).
correlativa(poo2,                   poo1).
correlativa(estructura_datos,       programacion_estructurada).
correlativa(estructura_datos,       matematica_discreta).
correlativa(algoritmia,             estructura_datos).
correlativa(algoritmia,             matematica_discreta).
correlativa(apps_moviles,           poo2).
correlativa(apps_moviles,           programacion_web).
correlativa(prog_paralela,          algoritmia).
correlativa(prog_paralela,          sistemas_operativos2).
% --- sistemas, redes y arquitectura ---
correlativa(redes_comunicacion,     informatica_general).
correlativa(protocolos_internet,    redes_comunicacion).
correlativa(arquitectura,           electronica_digital).
correlativa(sistemas_operativos1,   programacion_estructurada).
correlativa(sistemas_operativos2,   sistemas_operativos1).
correlativa(redes_area_amplia,      protocolos_internet).
correlativa(seguridad_cripto,       redes_area_amplia).
correlativa(seguridad_cripto,       sistemas_operativos2).
correlativa(seguridad_aplicada,     seguridad_cripto).
correlativa(auditoria,              seguridad_cripto).
% --- ingenieria de software y datos ---
correlativa(ingsoft1,               poo1).
correlativa(ingsoft2,               ingsoft1).
correlativa(ingsoft3,               ingsoft2).
correlativa(base_datos,             estructura_datos).
correlativa(base_datos_avanzada,    base_datos).
correlativa(modelos_simulacion,     probabilidad).
correlativa(modelos_simulacion,     metodos_numericos).
correlativa(optativa_ia,            algoritmia).
correlativa(optativa_ia,            probabilidad).
correlativa(proyecto_integral,      ingsoft3).
% --- economia y gestion ---
correlativa(analisis_economico,     administracion).
correlativa(analisis_economico,     calculo_avanzado).
correlativa(macroeconomia,          analisis_economico).
correlativa(economia_empresa,       macroeconomia).
correlativa(legislacion,            etica_fundamentos).
correlativa(gerenciamiento,         ingsoft2).
correlativa(gerenciamiento,         administracion).
% --- formacion humanistica (cadena UCA) ---
correlativa(etica_fundamentos,      filosofia).
correlativa(intro_teologia,         filosofia).
correlativa(sintesis_teologica,     intro_teologia).
correlativa(moral_social,           sintesis_teologica).
correlativa(seminario2,             seminario1).
correlativa(seminario3,             seminario2).
correlativa(seminario4,             seminario3).
correlativa(seminario5,             seminario4).
% --- idiomas y tramo final ---
correlativa(idioma_ingles2,         idioma_ingles1).
correlativa(seminario_tf,           seminario4).
correlativa(pps,                    ingsoft2).
correlativa(trabajo_final,          seminario_tf).


% =====================================================================
% 2) HISTORIA ACADEMICA DEL ALUMNO
% ---------------------------------------------------------------------
% Datos reales del reporte del sistema academico (plan_estudios.xls):
%   historia_academica(M) : M figura como Aprobada o Promocionada.
%   nota(M, N)            : nota final de M (solo aprobadas con nota
%                           numerica; las aprobadas "S" y las
%                           equivalencias no tienen nota).
%
% Las materias "En Curso" del reporte (Metodos Numericos, Analisis
% Economico y Optimizacion, Ingenieria del Software II) NO se cargan
% como aprobadas: el sistema las mostrara como disponibles, coherente
% con que el alumno las este cursando.
% =====================================================================

historia_academica(calculo_elemental).
historia_academica(representacion_grafica).
historia_academica(informatica_general).
historia_academica(intro_ingenieria).
historia_academica(filosofia).
historia_academica(complementos_matematica).
historia_academica(algebra_geometria).
historia_academica(fisica1).
historia_academica(quimica).
historia_academica(programacion_web).
historia_academica(seminario1).
historia_academica(redes_comunicacion).
historia_academica(calculo_avanzado).
historia_academica(fisica2).
historia_academica(programacion_estructurada).
historia_academica(administracion).
historia_academica(etica_fundamentos).
historia_academica(poo1).
historia_academica(fisica3).
historia_academica(probabilidad).
historia_academica(matematica_superior).
historia_academica(seminario2).
historia_academica(idioma_castellano).
historia_academica(ingsoft1).
historia_academica(electronica_digital).
historia_academica(protocolos_internet).
historia_academica(matematica_discreta).
historia_academica(intro_teologia).
historia_academica(arquitectura).
historia_academica(estructura_datos).
historia_academica(poo2).
historia_academica(sistemas_operativos1).
historia_academica(seminario3).
historia_academica(optativa_innovacion).
historia_academica(algoritmia).
historia_academica(sistemas_operativos2).
historia_academica(redes_area_amplia).
historia_academica(sintesis_teologica).
historia_academica(optativa_ia).

nota(calculo_elemental, 4).
nota(representacion_grafica, 7).
nota(informatica_general, 4).
nota(intro_ingenieria, 7).
nota(filosofia, 4).
nota(algebra_geometria, 7).
nota(fisica1, 6).
nota(quimica, 7).
nota(programacion_web, 7).
nota(seminario1, 8).
nota(redes_comunicacion, 7).
nota(calculo_avanzado, 4).
nota(fisica2, 7).
nota(programacion_estructurada, 5).
nota(administracion, 4).
nota(etica_fundamentos, 7).
nota(poo1, 4).
nota(fisica3, 7).
nota(probabilidad, 6).
nota(matematica_superior, 5).
nota(seminario2, 7).
nota(ingsoft1, 6).
nota(electronica_digital, 4).
nota(protocolos_internet, 6).
nota(matematica_discreta, 6).
nota(intro_teologia, 9).
nota(arquitectura, 8).
nota(estructura_datos, 4).
nota(poo2, 4).
nota(sistemas_operativos1, 9).
nota(seminario3, 10).
nota(optativa_innovacion, 9).
nota(algoritmia, 7).
nota(sistemas_operativos2, 4).
nota(redes_area_amplia, 6).
nota(sintesis_teologica, 9).
nota(optativa_ia, 8).

% cargar_historia: carga en el estado dinamico la historia academica
% real del alumno. Se invoca en la primera ejecucion, cuando todavia
% no existe un estado guardado. ignore/1 evita que falle si alguna
% materia ya estaba cargada.
cargar_historia :-
    forall(historia_academica(M), ignore(cargar_aprobada(M))).

% nota_de(+M, -N): nota de M, o -1 si no tiene nota numerica.
nota_de(M, N) :- ( nota(M, X) -> N = X ; N = -1 ).

% promedio(-P): promedio de las notas numericas de las aprobadas.
promedio(P) :-
    findall(N, (aprobada(M), nota(M, N)), Notas),
    Notas \= [],
    sum_list(Notas, Suma),
    length(Notas, Cantidad),
    P is Suma / Cantidad.


% =====================================================================
% 3) ESTADO DINAMICO (modulo de adquisicion de conocimiento)
% ---------------------------------------------------------------------
% El conocimiento sobre QUE materias aprobo el alumno no es estatico:
% se incorpora en tiempo de ejecucion con assertz/1 y se elimina con
% retract/1. Esto implementa el "modulo de adquisicion de conocimiento"
% de la arquitectura clasica de un sistema experto.
% =====================================================================

% aprobar(+M): registra M como aprobada, validando la INTEGRIDAD de la
% base de conocimiento: solo se puede haber aprobado una materia si
% todas sus correlativas ya estaban aprobadas. Complejidad: O(c) con c
% la cantidad de correlativas directas de M.
aprobar(M) :-
    materia(M),
    \+ aprobada(M),
    forall(correlativa(M, C), aprobada(C)),
    assertz(aprobada(M)).

% cargar_aprobada(+M): carga directa sin validar correlativas. Se usa
% solo al restaurar un estado guardado previamente (ya consistente).
cargar_aprobada(M) :-
    materia(M),
    \+ aprobada(M),
    assertz(aprobada(M)).

% desaprobar(+M): quita M de las aprobadas, siempre que ninguna materia
% ya aprobada dependa (directa o transitivamente) de M. De lo contrario
% la base quedaria en un estado inconsistente.
desaprobar(M) :-
    aprobada(M),
    \+ impide_desaprobar(M, _),
    retract(aprobada(M)).

% impide_desaprobar(+M, -X): X es una materia aprobada que requiere M.
% Forma parte del MODULO DE EXPLICACION: permite justificar por que el
% sistema rechaza una operacion.
impide_desaprobar(M, X) :-
    aprobada(X),
    requiere(X, M).

% reiniciar: borra todo el estado dinamico (retractall).
reiniciar :-
    retractall(aprobada(_)).


% =====================================================================
% 4) MOTOR DE INFERENCIA: REGLAS DE CORRELATIVIDAD
% =====================================================================

% puede_cursar(?M): M no esta aprobada y TODAS sus correlativas
% directas si lo estan. Las materias sin correlativas siempre estan
% disponibles hasta que se aprueban, porque forall/2 sobre cero casos
% es trivialmente verdadero.
% Complejidad: O(n * c) para enumerar todas (n materias, c correlativas).
puede_cursar(M) :-
    materia(M),
    \+ aprobada(M),
    forall(correlativa(M, C), aprobada(C)).

% falta_para(+M, -F): F es una correlativa DIRECTA de M aun no aprobada.
falta_para(M, F) :-
    correlativa(M, F),
    \+ aprobada(F).

% requiere(?M, ?R): clausura transitiva de correlativa/2, definida de
% forma RECURSIVA: R es prerequisito directo o indirecto de M. Es la
% regla central del motor: recorre el grafo de correlatividades en
% profundidad (asi busca soluciones el motor de inferencia de Prolog).
% Termina siempre porque el grafo de correlativas es aciclico (DAG).
requiere(M, R) :-
    correlativa(M, R).
requiere(M, R) :-
    correlativa(M, X),
    requiere(X, R).

% pendientes_para(+Obj, -Pendientes): todas las materias que faltan
% aprobar (directa o transitivamente) para poder cursar Obj.
% sort/2 elimina duplicados: un mismo prerequisito puede alcanzarse por
% varios caminos del grafo.
pendientes_para(Obj, Pendientes) :-
    findall(R, (requiere(Obj, R), \+ aprobada(R)), L),
    sort(L, Pendientes).

% camino_para(+Obj, -Camino): igual que pendientes_para/2 pero ordenado
% segun el orden curricular del plan, para sugerir una ruta de cursada.
camino_para(Obj, Camino) :-
    pendientes_para(Obj, Pendientes),
    findall(P-R, (member(R, Pendientes), posicion(R, P)), Pares),
    keysort(Pares, Ordenados),
    findall(R, member(_-R, Ordenados), Camino).

% desbloquea(+M, -N): cantidad de materias del plan que dependen
% (directa o transitivamente) de M. Mide el "impacto" de aprobar M:
% cuanto mas alto, mas materias traba si no se aprueba.
desbloquea(M, N) :-
    findall(X, requiere(X, M), L),
    sort(L, S),
    length(S, N).

% recomendaciones(-L): materias cursables ordenadas por impacto
% descendente. Cada elemento es una lista [N, M] (asi PySwip la recibe
% como lista simple de Python). sort/4 con @>= ordena de mayor a menor
% SIN eliminar duplicados.
recomendaciones(L) :-
    findall(N-M, (puede_cursar(M), desbloquea(M, N)), Pares),
    sort(0, @>=, Pares, Ordenados),
    findall([N, M], member(N-M, Ordenados), L).

% estado_materia(+M, -E): clasifica cada materia en uno de tres estados.
% Los cortes (!) hacen la clasificacion determinista y excluyente:
% son los tres estados del "ciclo de vida" de una materia.
estado_materia(M, aprobada)   :- aprobada(M), !.
estado_materia(M, disponible) :- puede_cursar(M), !.
estado_materia(_, bloqueada).

% posicion(+M, -P): posicion (1..n) de M en el orden curricular del
% plan. findall/3 respeta el orden de declaracion de los hechos plan/3.
posicion(M, P) :-
    findall(X, plan(X, _, _), Ms),
    nth1(P, Ms, M).

% materias_info(-L): resumen completo del plan para la interfaz grafica.
% Cada elemento: [Slug, Nombre, Anio, Cuatrimestre, Estado, Nota].
materias_info(L) :-
    findall([M, Nom, A, C, E, N],
            ( plan(M, A, C),
              nombre(M, Nom),
              estado_materia(M, E),
              nota_de(M, N) ),
            L).


% =====================================================================
% 5) PROGRESO DE LA CARRERA
% =====================================================================

% progreso(-Aprobadas, -Total): cantidades globales.
progreso(Aprobadas, Total) :-
    aggregate_all(count, aprobada(_), Aprobadas),
    aggregate_all(count, materia(_), Total).

% progreso_anio(?Anio, -Aprobadas, -Total): desglose por anio del plan.
progreso_anio(Anio, Aprobadas, Total) :-
    setof(A, M^C^plan(M, A, C), Anios),
    member(Anio, Anios),
    aggregate_all(count, plan(_, Anio, _), Total),
    aggregate_all(count, (plan(M2, Anio, _), aprobada(M2)), Aprobadas).


% =====================================================================
% 6) SIMULACION: "¿que pasa si apruebo X?"
% ---------------------------------------------------------------------
% Uso de assert/retract como memoria de trabajo TEMPORAL: se agrega la
% hipotesis "aprobada(M)", se consulta el nuevo estado del mundo, y se
% retira la hipotesis dejando la base como estaba (razonamiento
% hipotetico, tipico de sistemas expertos).
% =====================================================================

simular_aprobar(M, Nuevas) :-
    puede_cursar(M),
    findall(X, puede_cursar(X), Antes),
    assertz(aprobada(M)),
    findall(X, puede_cursar(X), Despues),
    retract(aprobada(M)),
    subtract(Despues, Antes, Nuevas).


% =====================================================================
% 7) SELECCION OPTIMA DE CURSADA (naturaleza NP del problema)
% ---------------------------------------------------------------------
% Problema: de las materias cursables, elegir el subconjunto de K que
% maximice la cantidad de materias nuevas que quedan habilitadas.
%
% Se resuelve por GENERACION Y PRUEBA (generate & test): se enumeran
% TODOS los subconjuntos de tamanio K -> C(n,k) combinaciones, un
% crecimiento combinatorio. VERIFICAR el valor de una seleccion dada es
% polinomial, pero ENCONTRAR la mejor exige recorrer el espacio completo
% de combinaciones: el esquema clasico de los problemas de la clase NP
% (verificacion eficiente, busqueda exponencial). Con el tamanio de esta
% base (n <= 65) la busqueda exhaustiva es viable; al escalar n, deja
% de serlo y habria que recurrir a heuristicas.
% =====================================================================

% subconjunto_k(+K, +Lista, -Sub): genera por backtracking todos los
% subconjuntos de tamanio K de Lista (en cada paso, el elemento se
% incluye o se descarta: arbol binario de decisiones).
subconjunto_k(0, _, []) :- !.
subconjunto_k(K, [X|Resto], [X|Sub]) :-
    K > 0,
    K1 is K - 1,
    subconjunto_k(K1, Resto, Sub).
subconjunto_k(K, [_|Resto], Sub) :-
    K > 0,
    subconjunto_k(K, Resto, Sub).

% valor_seleccion(+Sel, -Valor): cuantas materias NUEVAS quedarian
% habilitadas si se aprobara toda la seleccion Sel (verificacion en
% tiempo polinomial, con hipotesis temporales assert/retract).
valor_seleccion(Sel, Valor) :-
    findall(X, puede_cursar(X), Antes),
    forall(member(M, Sel), assertz(aprobada(M))),
    findall(X, puede_cursar(X), Despues),
    forall(member(M, Sel), retract(aprobada(M))),
    subtract(Despues, Antes, Nuevas),
    length(Nuevas, Valor).

% mejor_cursada(+K, -Sel, -Valor): explora todas las combinaciones y se
% queda con la de mayor valor. Falla si no hay materias cursables.
mejor_cursada(K, Sel, Valor) :-
    findall(M, puede_cursar(M), Cursables),
    Cursables \= [],
    length(Cursables, NC),
    (NC < K -> K2 = NC ; K2 = K),
    findall(V-S,
            ( subconjunto_k(K2, Cursables, S),
              valor_seleccion(S, V) ),
            Todas),
    sort(0, @>=, Todas, [Valor-Sel|_]).


% =====================================================================
% 8) MAQUINA DE TURING: ANALISIS DEL AVANCE
% ---------------------------------------------------------------------
% Se implementa una Maquina de Turing REAL (simulador generico con
% cinta, cabezal y funcion de transicion delta) y se la usa para
% analizar el avance del alumno.
%
% La CINTA codifica el estado de cada materia en el orden curricular
% del plan: 1 = aprobada, 0 = pendiente. El simbolo 'b' es el blanco.
%
% La maquina reconoce el lenguaje  L = { 1^n 0^m  |  n, m >= 0 }
% (unos seguidos de ceros, sin mezclar):
%   * ACEPTA  -> el alumno avanzo en el orden del plan, sin dejar
%                materias pendientes detras de otras ya aprobadas.
%   * RECHAZA -> hay "arrastre": alguna materia pendiente es anterior
%                (en el plan) a una ya aprobada.
%
% Definicion formal: MT = (Q, Sigma, Gamma, delta, q0, b, F) con
%   Q = {q0, q1, qacepta},  Sigma = {0, 1},  Gamma = {0, 1, b},
%   F = {qacepta}, y delta dada por los hechos delta/5 de abajo.
% =====================================================================

% delta(Estado, Lee, NuevoEstado, Escribe, Movimiento)
delta(q0, 1, q0,      1, der).     % en q0 consume la racha inicial de unos
delta(q0, 0, q1,      0, der).     % primer cero: pasa a q1
delta(q0, b, qacepta, b, quieto).  % cadena 1^n vacia de ceros: acepta
delta(q1, 0, q1,      0, der).     % en q1 solo admite ceros
delta(q1, b, qacepta, b, quieto).  % fin de cinta: acepta
% (q1, 1) NO tiene transicion definida: si aparece un 1 despues de un 0
% la maquina se detiene sin alcanzar qacepta => RECHAZA la cadena.

% tm_acepta(+Cinta): true si la MT acepta la cinta partiendo de q0.
tm_acepta(Cinta) :-
    tm_paso(q0, [], Cinta), !.

% tm_paso(+Estado, +IzquierdaInvertida, +[SimboloActual|Derecha])
% Configuracion instantanea de la maquina. La parte izquierda de la
% cinta se guarda invertida para mover el cabezal en O(1).
tm_paso(qacepta, _, _) :- !.               % estado de aceptacion: termina
tm_paso(Q, Izq, []) :-                     % cinta "infinita": al llegar al
    !, tm_paso(Q, Izq, [b]).               % final se materializa un blanco
tm_paso(Q, Izq, [S|Der]) :-
    delta(Q, S, Q2, S2, Mov),              % si no hay transicion, falla
    mover(Mov, Izq, [S2|Der], Izq2, Cinta2),
    tm_paso(Q2, Izq2, Cinta2).

% mover(+Direccion, +Izq, +Cinta, -NuevaIzq, -NuevaCinta)
mover(der,    Izq,      [S|Der], [S|Izq], Der).
mover(quieto, Izq,      Cinta,   Izq,     Cinta).
mover(izq,    [I|Izq],  Cinta,   Izq,     [I|Cinta]).

% cinta_avance(-Cinta): construye la cinta de entrada de la MT a partir
% del estado actual de la base de conocimiento, respetando el orden
% curricular (orden de declaracion de plan/3).
cinta_avance(Cinta) :-
    findall(Bit,
            ( plan(M, _, _),
              (aprobada(M) -> Bit = 1 ; Bit = 0) ),
            Cinta).

% avance_ordenado(-Cinta, -Resultado): ejecuta la MT sobre la cinta de
% avance. Resultado = ordenado | desordenado.
avance_ordenado(Cinta, Resultado) :-
    cinta_avance(Cinta),
    ( tm_acepta(Cinta) -> Resultado = ordenado
    ;                     Resultado = desordenado ).

% arrastrada(?M): M esta pendiente pero existe una materia POSTERIOR en
% el orden del plan que ya fue aprobada (es exactamente la condicion
% por la que la MT rechaza: un 1 despues de un 0). once/1 evita
% soluciones repetidas sin cortar el backtracking sobre M.
arrastrada(M) :-
    materia(M),
    \+ aprobada(M),
    posicion(M, P),
    once(( aprobada(X), posicion(X, PX), PX > P )).

% CarreraBot - Sistema experto de correlatividades academicas
% Trabajo Final - Algoritmia y Logica Computacional (UCA)
% Alumno: Ignacio Di Bartolo
% Requiere SWI-Prolog. Se consulta desde Python (carrerabot_gui.py).

:- encoding(utf8).

:- dynamic aprobada/1.

% 1) BASE DE CONOCIMIENTO: PLAN DE ESTUDIOS

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

plan(calculo_elemental,       1, 1).
plan(representacion_grafica,  1, 1).
plan(informatica_general,     1, 1).
plan(intro_ingenieria,        1, 1).
plan(filosofia,               1, 1).
plan(complementos_matematica, 1, 1).
plan(algebra_geometria,       1, 2).
plan(fisica1,                 1, 2).
plan(quimica,                 1, 2).
plan(programacion_web,        1, 2).
plan(seminario1,              1, 2).
plan(redes_comunicacion,      2, 1).
plan(calculo_avanzado,        2, 1).
plan(fisica2,                 2, 1).
plan(programacion_estructurada, 2, 1).
plan(administracion,          2, 1).
plan(etica_fundamentos,       2, 1).
plan(poo1,                    2, 2).
plan(fisica3,                 2, 2).
plan(probabilidad,            2, 2).
plan(matematica_superior,     2, 2).
plan(seminario2,              2, 2).
plan(idioma_castellano,       2, 2).
plan(idioma_ingles1,          2, 2).
plan(ingsoft1,                3, 1).
plan(electronica_digital,     3, 1).
plan(metodos_numericos,       3, 1).
plan(protocolos_internet,     3, 1).
plan(matematica_discreta,     3, 1).
plan(intro_teologia,          3, 1).
plan(arquitectura,            3, 2).
plan(estructura_datos,        3, 2).
plan(poo2,                    3, 2).
plan(sistemas_operativos1,    3, 2).
plan(seminario3,              3, 2).
plan(optativa_innovacion,     3, 2).
plan(analisis_economico,      4, 1).
plan(algoritmia,              4, 1).
plan(ingsoft2,                4, 1).
plan(sistemas_operativos2,    4, 1).
plan(redes_area_amplia,       4, 1).
plan(sintesis_teologica,      4, 1).
plan(modelos_simulacion,      4, 2).
plan(base_datos,              4, 2).
plan(apps_moviles,            4, 2).
plan(seguridad_cripto,        4, 2).
plan(macroeconomia,           4, 2).
plan(legislacion,             4, 2).
plan(seminario4,              4, 2).
plan(prog_paralela,           5, 1).
plan(investigacion_operativa, 5, 1).
plan(base_datos_avanzada,     5, 1).
plan(ingsoft3,                5, 1).
plan(seguridad_aplicada,      5, 1).
plan(seminario_tf,            5, 1).
plan(moral_social,            5, 1).
plan(gerenciamiento,          5, 2).
plan(auditoria,               5, 2).
plan(proyecto_integral,       5, 2).
plan(economia_empresa,        5, 2).
plan(seminario5,              5, 2).
plan(optativa_ia,             5, 2).
plan(idioma_ingles2,          5, 2).
plan(pps,                     5, 2).
plan(trabajo_final,           5, 2).

% CORRELATIVIDADES

correlativa(algebra_geometria,          complementos_matematica).
correlativa(fisica1,                    calculo_elemental).
correlativa(programacion_web,           informatica_general).
correlativa(seminario1,                 filosofia).
correlativa(redes_comunicacion,         programacion_web).
correlativa(calculo_avanzado,           calculo_elemental).
correlativa(calculo_avanzado,           algebra_geometria).
correlativa(fisica2,                    fisica1).
correlativa(programacion_estructurada,  informatica_general).
correlativa(administracion,             intro_ingenieria).
correlativa(etica_fundamentos,          seminario1).
correlativa(poo1,                       programacion_estructurada).
correlativa(fisica3,                    fisica1).
correlativa(fisica3,                    calculo_avanzado).
correlativa(probabilidad,               calculo_elemental).
correlativa(matematica_superior,        calculo_avanzado).
correlativa(seminario2,                 etica_fundamentos).
correlativa(ingsoft1,                   administracion).
correlativa(ingsoft1,                   poo1).
correlativa(electronica_digital,        fisica3).
correlativa(metodos_numericos,          matematica_superior).
correlativa(protocolos_internet,        redes_comunicacion).
correlativa(protocolos_internet,        programacion_estructurada).
correlativa(matematica_discreta,        algebra_geometria).
correlativa(intro_teologia,             seminario2).
correlativa(arquitectura,               electronica_digital).
correlativa(estructura_datos,           matematica_discreta).
correlativa(poo2,                       poo1).
correlativa(sistemas_operativos1,       poo1).
correlativa(sistemas_operativos1,       electronica_digital).
correlativa(seminario3,                 intro_teologia).
correlativa(analisis_economico,         calculo_elemental).
correlativa(algoritmia,                 estructura_datos).
correlativa(ingsoft2,                   ingsoft1).
correlativa(ingsoft2,                   poo2).
correlativa(sistemas_operativos2,       sistemas_operativos1).
correlativa(redes_area_amplia,          protocolos_internet).
correlativa(sintesis_teologica,         seminario3).
correlativa(modelos_simulacion,         probabilidad).
correlativa(base_datos,                 estructura_datos).
correlativa(base_datos,                 poo2).
correlativa(apps_moviles,               poo2).
correlativa(seguridad_cripto,           protocolos_internet).
correlativa(seguridad_cripto,           sistemas_operativos2).
correlativa(macroeconomia,              analisis_economico).
correlativa(seminario4,                 sintesis_teologica).
correlativa(prog_paralela,              protocolos_internet).
correlativa(investigacion_operativa,    modelos_simulacion).
correlativa(base_datos_avanzada,        base_datos).
correlativa(ingsoft3,                   ingsoft2).
correlativa(seguridad_aplicada,         seguridad_cripto).
correlativa(moral_social,               seminario4).
correlativa(gerenciamiento,             ingsoft3).
correlativa(auditoria,                  seguridad_cripto).
correlativa(proyecto_integral,          apps_moviles).
correlativa(proyecto_integral,          ingsoft3).
correlativa(economia_empresa,           macroeconomia).
correlativa(seminario5,                 moral_social).

% 2) HISTORIA ACADEMICA DEL ALUMNO

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

% 3) ESTADO DINAMICO (adquisicion de conocimiento)

cargar_historia :-
    forall(historia_academica(M), ignore(cargar_aprobada(M))).

nota_de(M, N) :- ( nota(M, X) -> N = X ; N = -1 ).

promedio(P) :-
    findall(N, (aprobada(M), nota(M, N)), Notas),
    Notas \= [],
    sum_list(Notas, Suma),
    length(Notas, Cantidad),
    P is Suma / Cantidad.

aprobar(M) :-
    materia(M),
    \+ aprobada(M),
    forall(correlativa(M, C), aprobada(C)),
    assertz(aprobada(M)).

cargar_aprobada(M) :-
    materia(M),
    \+ aprobada(M),
    assertz(aprobada(M)).

desaprobar(M) :-
    aprobada(M),
    \+ impide_desaprobar(M, _),
    retract(aprobada(M)).

impide_desaprobar(M, X) :-
    aprobada(X),
    requiere(X, M).

reiniciar :-
    retractall(aprobada(_)).

% 4) MOTOR DE INFERENCIA: REGLAS DE CORRELATIVIDAD

puede_cursar(M) :-
    materia(M),
    \+ aprobada(M),
    forall(correlativa(M, C), aprobada(C)).

falta_para(M, F) :-
    correlativa(M, F),
    \+ aprobada(F).

requiere(M, R) :-
    correlativa(M, R).
requiere(M, R) :-
    correlativa(M, X),
    requiere(X, R).

pendientes_para(Obj, Pendientes) :-
    findall(R, (requiere(Obj, R), \+ aprobada(R)), L),
    sort(L, Pendientes).

camino_para(Obj, Camino) :-
    pendientes_para(Obj, Pendientes),
    findall(P-R, (member(R, Pendientes), posicion(R, P)), Pares),
    keysort(Pares, Ordenados),
    findall(R, member(_-R, Ordenados), Camino).

desbloquea(M, N) :-
    findall(X, requiere(X, M), L),
    sort(L, S),
    length(S, N).

recomendaciones(L) :-
    findall(N-M, (puede_cursar(M), desbloquea(M, N)), Pares),
    sort(0, @>=, Pares, Ordenados),
    findall([N, M], member(N-M, Ordenados), L).

estado_materia(M, aprobada)   :- aprobada(M), !.
estado_materia(M, disponible) :- puede_cursar(M), !.
estado_materia(_, bloqueada).

posicion(M, P) :-
    findall(X, plan(X, _, _), Ms),
    nth1(P, Ms, M).

materias_info(L) :-
    findall([M, Nom, A, C, E, N],
            ( plan(M, A, C),
              nombre(M, Nom),
              estado_materia(M, E),
              nota_de(M, N) ),
            L).

% 5) PROGRESO DE LA CARRERA

progreso(Aprobadas, Total) :-
    aggregate_all(count, aprobada(_), Aprobadas),
    aggregate_all(count, materia(_), Total).

progreso_anio(Anio, Aprobadas, Total) :-
    setof(A, M^C^plan(M, A, C), Anios),
    member(Anio, Anios),
    aggregate_all(count, plan(_, Anio, _), Total),
    aggregate_all(count, (plan(M2, Anio, _), aprobada(M2)), Aprobadas).

% 6) SIMULACION

simular_aprobar(M, Nuevas) :-
    puede_cursar(M),
    findall(X, puede_cursar(X), Antes),
    assertz(aprobada(M)),
    findall(X, puede_cursar(X), Despues),
    retract(aprobada(M)),
    subtract(Despues, Antes, Nuevas).

% 7) SELECCION OPTIMA DE CURSADA

subconjunto_k(0, _, []) :- !.
subconjunto_k(K, [X|Resto], [X|Sub]) :-
    K > 0,
    K1 is K - 1,
    subconjunto_k(K1, Resto, Sub).
subconjunto_k(K, [_|Resto], Sub) :-
    K > 0,
    subconjunto_k(K, Resto, Sub).

valor_seleccion(Sel, Valor) :-
    findall(X, puede_cursar(X), Antes),
    forall(member(M, Sel), assertz(aprobada(M))),
    findall(X, puede_cursar(X), Despues),
    forall(member(M, Sel), retract(aprobada(M))),
    subtract(Despues, Antes, Nuevas),
    length(Nuevas, Valor).

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

% 8) MAQUINA DE TURING: ANALISIS DEL AVANCE

delta(q0, 1, q0,      1, der).
delta(q0, 0, q1,      0, der).
delta(q0, b, qacepta, b, quieto).
delta(q1, 0, q1,      0, der).
delta(q1, b, qacepta, b, quieto).

tm_acepta(Cinta) :-
    tm_paso(q0, [], Cinta), !.

tm_paso(qacepta, _, _) :- !.
tm_paso(Q, Izq, []) :-
    !, tm_paso(Q, Izq, [b]).
tm_paso(Q, Izq, [S|Der]) :-
    delta(Q, S, Q2, S2, Mov),
    mover(Mov, Izq, [S2|Der], Izq2, Cinta2),
    tm_paso(Q2, Izq2, Cinta2).

mover(der,    Izq,      [S|Der], [S|Izq], Der).
mover(quieto, Izq,      Cinta,   Izq,     Cinta).
mover(izq,    [I|Izq],  Cinta,   Izq,     [I|Cinta]).

cinta_avance(Cinta) :-
    findall(Bit,
            ( plan(M, _, _),
              (aprobada(M) -> Bit = 1 ; Bit = 0) ),
            Cinta).

avance_ordenado(Cinta, Resultado) :-
    cinta_avance(Cinta),
    ( tm_acepta(Cinta) -> Resultado = ordenado
    ;                     Resultado = desordenado ).

arrastrada(M) :-
    materia(M),
    \+ aprobada(M),
    posicion(M, P),
    once(( aprobada(X), posicion(X, PX), PX > P )).

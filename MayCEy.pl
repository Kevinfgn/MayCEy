:- use_module(library(persistency)).

avion(cessna,peq,190).
avion(beechcraft,peq,210).
avion(embruerphenom,peq,230).
avion(boeing717,med,240).
avion(embraer190,med,215).
avion(airbusA220,med,225).
avion(boeing747,grnd,230).
avion(airbusA340,grnd,250).
avion(airbusA380,grnd,265).


pista(p21,med,este).
pista(p22,med,oeste).
pista(p21,peq,este).
pista(p1,peq,oeste).
pista(p22,peq,oeste).

pista(p3,peq,norte).
pista(p3,med,norte).
pista(p3,grnd,norte).

pista(p3,peq,sur).
pista(p3,med,sur).
pista(p3,grnd,sur).



pista(p3,peq,este).
pista(p3,med,este).
pista(p3,grnd,este).
pista(p3,peq,oeste).
pista(p3,med,oeste).
pista(p3,grnd,oeste).



emergencia(perdidaDeMotor,bomberos).
emergencia(parto,medicos).
emergencia(paroCardiaco,medicos).
emergencia(secuetro,policia).


atenciones(bomberos).
atenciones(medicos).
atenciones(policia).


condiciones().

:-persistent fact(fact1:any).
:-initialization(init).
init:-absolute_file_name('fact.db',File,[access(write)]),db_attach(File,[]).

% permite guardar la agenda en la lista dinamica
guardar_agenda_dinamica(X):-retractall_fact(_),assert_fact(X).

%Solicitud de inicio de la torre para despegar.
solicitud(M,Agenda):-
    M=despegar,buscar_pista_despegue(_,_,_,_,Vuelo,Agenda),
    torre_libre([Vuelo|Agenda]). %La respuesta retorna la funcion Agenda para que se guarde

%solicitud para aterrizar,
solicitud(N,Agenda):-
    N=aterrizar,buscar_pista_aterrizaje(_,_,_,_,_,Vuelo,Agenda),%llama a la funcion que busca una pista libre
    torre_libre([Vuelo|Agenda]).% libera la torre de control

%solicitud a la torre para terminar el programa
solicitud(G,Agenda):-
    G=terminar,guardar_agenda_dinamica(Agenda).% al terminar el turno, guarda la agenda en memoria

%solicitud a la torre para desplegar la agenda de vuelos
solicitud(N,Agenda):-
    N=agenda,write(Agenda),torre_libre(Agenda).%escribe la agenda en consola

%solicitud de mayday
solicitud(N,Agenda_previa):-
    N=mayday,buscar_pista_emergencia(_,_,_,Agenda_previa,Agenda),%llama a la funcion de emergencias
    torre_libre(Agenda).

%Funcion inicial que se llama guando hay una agenda interna
torre_libre(Agenda):-
    write("---TORRE DE CONTROL A LA ESCUCHA--- Hora de inicio 00:00 \n"),
    read(X),solicitud(X,Agenda). %lee la solicitud y la envia

%funcion inicial cuando no agenda interna pero si dinamica
torre_libre():-
    fact(Ag), % si encuentra algo en la memoria dinamica
    write("---TORRE DE CONTROL A LA ESCUCHA--- Hora de inicio 00:00 \n"),
    read(X), % lee la solicitud
    solicitud(X,Ag). % envia la solicitud con la agenda encontrada en la memoria dinamica

%funcion inicial cuando no agenda interna ni tampoco dinamica
torre_libre():-
    write("---TORRE DE CONTROL A LA ESCUCHA--- Hora de inicio 00:00 \n"),
    read(X), %lee la solicitud
    solicitud(X,[]). % envia la solicitud con una lista vacia ya que no hay agenda

% funcion que despeja una pista solicitada
buscar_pista_emergencia(Id,Avion,Emergencia,Agenda_previa,Agenda):-
    write("Por favor identifiquese"),read(Id),  % se lee la matricula
    write("Indique cual es su emergecnia"),read(Emergencia), % se lee la emergencia
    write("Cual es la Aeronave?"),read(Avion), % se lee el avion.
    avion(Avion,Taman,_),pista(P,Taman,_), %Busca la pista P indiacada
    emergencia(Emergencia,Equipo), % se busca la ayuda necesaria para la emergencia
    posponer_agenda(Agenda_previa,[],Agenda), % se pospone toda la agenda 5 minutos
    write("La pista "),write(P),write(" ya se encuentra despejada y un equipo de "),
    write(Equipo),write(" ya está en camino").

%funcion que busca la pista para despegar
buscar_pista_despegue(Id,Aeronave,Hora,Direccion,Vuelo,Agenda):-
    write("Por favor identifiquese"),read(Id), % se lee la matricula
    write("indique la aeronave"),read(Aeronave), % se lee el avion.
    write("indique su hora de salida"),read(Hora), % se lee la hora
    write("indique su Direccion"),read(Direccion),% se lee la direccion de vuelo
    avion(Aeronave,Taman,_),pista(P,Taman,Direccion), % busca la pista indicada
    revisar_agenda(Agenda,P,Hora,PistaOficial,HoraOficial), % revisa la agenda para comprobar que la pista esta ocupada
    write("su pista es: "),write(PistaOficial), % le indica la pista de despegue
    write(" asignada a las 00:"),write(HoraOficial),write("\n"),
    Vuelo=[Id,PistaOficial,HoraOficial]. % devuelve el vuelo agendado para que se guarde

% Fucion que busca una pista para aterrizar dependiendo de su distancia
buscar_pista_aterrizaje(Id,Aeronave,Velocidad,Distancia,Direccion,Vuelo,Agenda):-
   write("Por favor identifiquese"),read(Id),
   write("indique la aeronave"),read(Aeronave),
   write("indique su velocidad"),read(Velocidad),
   write("Confirme su distancia hasta el aeropuerto"),read(Distancia),
   write("Por ultimo la direccion del vuelo"),read(Direccion),
   velocidadYhora(H,Velocidad,Distancia,Aeronave,V), % mide el tiempo qu tardará en llegar y si sobrepasa la velocidad segura
   avion(Aeronave,Taman,_),pista(P,Taman,Direccion),%busca la pista en la que puede aterrizar
   revisar_agenda(Agenda,P,H,PistaOficial,HoraOficial), %revisa la agenda para confirmar la pista
   write("Su pista asignada es la: "),write(PistaOficial),write("por favor "),write(V),
   write(" su velocidad para poder llegar a las 00:"),write(HoraOficial),write("\n"),
   Vuelo=[Id,PistaOficial,HoraOficial].

% funcion que determina si hay una pista ocupada para el horario
% solicitado,si la agenda es vacia se confirma la pista
revisar_agenda(Agenda,Pista_req,Hora_req,Pista_asig,Hora_asig):-
   Agenda=[],
   Pista_req=Pista_asig,
   Hora_req=Hora_asig.

%revisa la agenda y si encuentra un vuelo, pospone el aterrizaje
revisar_agenda(Agenda,Pista_req,Hora_req,Pista_asig,Hora_asig):-
    Agenda=[Cabeza|_], %busca el primer elemento de la agenda
    Cabeza=[_|K],K=[Pista_ocupada|_], % busca la pista del vuelo seleccionado
    Cabeza=[_|[_|F]],F=[Hora_ocupada|_],% busca la hora del vuelo seleccionado
    Pista_ocupada=Pista_req,
    Hora_ocupada=Hora_req,% se verifica si son iguales las horas y la pista
    NuevaHora is Hora_req+5,% agrega 5 minutos al avion en vuelo
    Agenda=[_|X],% quita un elemento a agenda para continuar revisando
    revisar_agenda(X,Pista_req,NuevaHora,Pista_asig,Hora_asig).% envia nuevamente la funcion.

% revisa la agenda y si no se encuentra un vuelo, continua con el
% siguiente elemento
revisar_agenda(Agenda,Pista_req,Hora_req,Pista_asig,Hora_asig):-
    Agenda=[Cabeza|_],%busca el primer elemento de la agenda
    Cabeza=[_|K],K=[Pista_ocupada|_],% busca la pista del vuelo seleccionado
    Cabeza=[_|[_|F]],F=[Hora_ocupada|_],% busca la hora del vuelo seleccionado
    (Pista_ocupada\=Pista_req; % si uno de los dos elementos coincide, revisa si el otro tambien
    Hora_ocupada\=Hora_req), % si solo uno coindice no se pospone el vuelo
    Agenda=[_|X], % quita el primer elemento a agenda
    revisar_agenda(X,Pista_req,Hora_req,Pista_asig,Hora_asig).

% Funcion que determina el tiempo de llegada y la velocidad segura
velocidadYhora(Hora_llegada,Velocidad,Distancia,Avion,Indicacion_velocidad):-
    Div is Distancia//100,Mult is Div*5,Hora_llegada=Mult,% Cada 100Km son 5 minutos mas para el aterrizaje
    velocidad(Avion,Velocidad,Indicacion_velocidad).% funcion que revisa la velocidad segura de aterrizaje



velocidad(Avion,Velocidad,Indicacion):-
    avion(Avion,_,V_segura),V_segura>Velocidad, % si la velocidad es menor a la segura
    Indicacion=aumente. % inidica que aumente la velocidad.

velocidad(Avion,Velocidad,Indicacion):-
    avion(Avion,_,V_segura),V_segura<Velocidad,% si la velocidad es mayor a la segura
    Indicacion=disminuya.% inidica que disminuya la velocidad.

%funcion que pospone la agenda 5 minutos en caso de emergencia
%si la lista de agenda previa está vacia (condicion de terminacion)
posponer_agenda(Agenda_previa,Agenda_preliminar,Agenda):-
    Agenda_previa=[],
    Agenda_preliminar=Agenda.

%funcion que pospone la agenda 5 minutos en caso de emergencia
posponer_agenda(Agenda_previa,Agenda_preliminar,Agenda):-
    Agenda_previa=[Cabeza|_], %busca el primer elemento de la agenda
    Cabeza=[T|_], % busca el vuelo en la agenda
    Cabeza=[_|K],K=[Pista_ocupada|_], % busca la pista del vuelo seleccionado
    Cabeza=[_|[_|F]],F=[Hora_ocupada|_],% busca la hora del vuelo seleccionado
    Hora_nueva is Hora_ocupada+5, % pospone la hora encontrada 5 minutos
    Vuelo_pospuesto=[T,Pista_ocupada,Hora_nueva], %Concatena la informacion del vuelo
    Agenda_previa=[_|A],% le quita un elemento a la agenda
    X=[Vuelo_pospuesto|Agenda_preliminar], % le agrega el vuelo a la nueva agenda
    posponer_agenda(A,X,Agenda).


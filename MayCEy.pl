avion(cessna,peq,190).
avion(beechcraft,peq,210).
avion(embruerphenom,peq,230).
avion(boeing717,med,240).
avion(embraer190,med,215).
avion(airbusA220,med,225).
avion(boeing747,grnd,230).
avion(airbusA340,grnd,250).
avion(airbusA380,grnd,265).

pista(p1,peq,oeste).
pista(p21,med,este).
pista(p22,med,oeste).
pista(p21,peq,este).
pista(p22,peq,oeste).

pista(p3,peq,nortesur).
pista(p3,med,nortesur).
pista(p3,grnd,nortesur).


emergencia(perdidaDeMotor).
emergencia(parto).
emergencia(paroCardiaco).
emergencia(secuetro).


atenciones(bomberos).
atenciones(medicos).
atenciones(policia).


condiciones().
solicitud(M,Agenda):-M=despegar,buscar_pista_despegue(_,_,_,_,Vuelo,Agenda),torre_libre([Vuelo|Agenda]). %La respuesta retorna la funcion Agenda para que se guarde

solicitud(N,Agenda):-N=aterrizar,buscar_pista_aterrizaje(_,_,_,_,_,Vuelo,Agenda),torre_libre([Vuelo|Agenda]).

solicitud(N,Agenda):-N=agenda,write(Agenda),torre_libre(Agenda).

mensaje(X,Agenda):-split_string(X,"\s","\s",Agenda).
torre_libre(Agenda):-write("---TORRE DE CONTROL A LA ESCUCHA--- Hora de inicio 00:00"),read(X),solicitud(X,Agenda).


buscar_pista_despegue(Id,Aeronave,Hora,Direccion,Vuelo,Agenda):-
    write("Por favor identifiquese"),read(Id),
    write("indique la aeronave"),read(Aeronave),
    write("indique su hora de salida"),read(Hora),
    write("indique su Direccion"),read(Direccion),
    avion(Aeronave,Taman,_),pista(P,Taman,Direccion),
    revisar_agenda(Agenda,P,Hora,PistaOficial,HoraOficial),
    write("su pista es: "),write(PistaOficial),
    write(" asignada a las 00:"),write(HoraOficial),
    Vuelo=[Id,PistaOficial,HoraOficial]. %Oficiales

buscar_pista_aterrizaje(Id,Aeronave,Velocidad,Distancia,Direccion,Vuelo,Agenda):-
   write("Por favor identifiquese"),read(Id),
   write("indique la aeronave"),read(Aeronave),
   write("indique su velocidad"),read(Velocidad),
   write("Confirme su distancia hasta el aeropuerto"),read(Distancia),
   write("Por ultimo la direccion del vuelo"),read(Direccion),
   velocidadYhora(H,Velocidad,Distancia,Aeronave,V),
   avion(Aeronave,Taman,_),pista(P,Taman,Direccion),
   revisar_agenda(Agenda,P,H,PistaOficial,HoraOficial),
   write("Su pista asignada es la: "),write(PistaOficial),write("por favor "),write(V),
   write(" su velocidad para poder llegar a las 00:"),write(HoraOficial),
   Vuelo=[Id,PistaOficial,HoraOficial].


revisar_agenda(Agenda,Pista_req,Hora_req,Pista_asig,Hora_asig):-
   Agenda=[],
   Pista_req=Pista_asig,
   Hora_req=Hora_asig.

revisar_agenda(Agenda,Pista_req,Hora_req,Pista_asig,Hora_asig):-
    Agenda=[Cabeza|_],
    Cabeza=[_|K],K=[Pista_ocupada|_],
    Cabeza=[_|[_|F]],F=[Hora_ocupada|_],
    Pista_ocupada=Pista_req,
    Hora_ocupada=Hora_req,
    NuevaHora is Hora_req+5,
    Agenda=[_|X],
    revisar_agenda(X,Pista_req,NuevaHora,Pista_asig,Hora_asig).


revisar_agenda(Agenda,Pista_req,Hora_req,Pista_asig,Hora_asig):-
    Agenda=[Cabeza|_],
    Cabeza=[_|K],K=[Pista_ocupada|_],
    Cabeza=[_|[_|F]],F=[Hora_ocupada|_],
    write(Pista_ocupada),
    write("hora :"),write(Hora_ocupada),
    (Pista_ocupada\=Pista_req;
    Hora_ocupada\=Hora_req),
    Agenda=[_|X],
    write(X),
    revisar_agenda(X,Pista_req,Hora_req,Pista_asig,Hora_asig).

velocidadYhora(Hora_llegada,Velocidad,Distancia,Avion,Indicacion_velocidad):-
    Div is Distancia//100,Mult is Div*5,Hora_llegada=Mult,
    velocidad(Avion,Velocidad,Indicacion_velocidad).



velocidad(Avion,Velocidad,Indicacion):-avion(Avion,_,V_segura),V_segura>Velocidad,
    Indicacion=aumente.
velocidad(Avion,Velocidad,Indicacion):-avion(Avion,_,V_segura),V_segura<Velocidad,
    Indicacion=disminuya.



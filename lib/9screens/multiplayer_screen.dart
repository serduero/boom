import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:buscaminas/0varios/constantes.dart';
import 'package:buscaminas/2clases/zclases.dart';
import 'package:buscaminas/5providers/zproviders.dart';
import 'package:buscaminas/6views/zviews.dart';

class MultiJugador extends StatelessWidget {
  const MultiJugador({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Provider.of<VariablesEntorno>(context, listen: false).setEntornoApp =
          Entorno(monoSettings: false);
    });

    return ColoredBox(
      color: CANVASCOLOR,
      child: const MapaMulti(),
    );
  }
}

class MapaMulti extends StatefulWidget {
  const MapaMulti({super.key});

  @override
  State<MapaMulti> createState() => _MapaMultiState();
}

class _MapaMultiState extends State<MapaMulti> with TickerProviderStateMixin {
  late AnimationController _contrModo;
  late ValueNotifier<bool> pulsadaBandera;
  late ValueNotifier<bool> pulsadaAyuda;

  @override
  Widget build(BuildContext context) {
    final Size espacioMax = AppLayout.getSize(context);

    // control de temporizador por fuera ya que puede no estar mostrandose
    // la pantalla del juego y tiene que pararse igualmente
    if (Provider.of<MultiminasProv>(context).finTimer) {
      Provider.of<ContadorProv>(context, listen: false).closeTemporizador();
      Provider.of<MultiminasProv>(context, listen: false).setFinTimer = false;
    }

    return Provider.of<MultiminasProv>(context).conectado != EstadoWS.jugando
        // Si no jugando mostramos diferentes mensajes/acciones
        ? ListView(children: [
            SizedBox(
              height: espacioMax.height * .3,
            ),
            const BotonConexion(),
          ])

        // Si conectado mostramos tablero, núm jugadores y botón de salir
        : Consumer<MultiminasProv>(
            builder: (_, minas, __) {
              final double tamCelda = (espacioMax.width * .9) / minas.totX;

              if (minas.initTimer) {
                // para iniciar contador cuando no es mi turno tras lanzar partida
                // o cuando se ha producido un movimiento
                Provider.of<ContadorProv>(context, listen: false)
                    .initTemporizador();
                minas.setInitTimer = false;
              }

              // print('en multiply1 x dentro ${minas.finTimer}');
              // if (minas.finTimer) {
              //   print('en multiply1 dentro fin timer true');
              //   Provider.of<ContadorProv>(context, listen: false)
              //       .closeTemporizador();
              //   minas.setFinTimer = false;
              // }

              final SizedBox tablero = SizedBox(
                width: TAMCELDA * minas.totX,
                height: TAMCELDA * minas.totY,
                child: Table(
                  children: List<TableRow>.generate(
                    minas.totY,
                    (j) => TableRow(
                      children: List<InkWell>.generate(
                        minas.totX,
                        (i) => InkWell(
                          onLongPress: minas.getMapa[i][j].estado !=
                                      EstadoCelda.destapada &&
                                  (minas.estado == Estado.enCurso ||
                                      minas.estado == Estado.sinIniciar)
                              ? () {
                                  final bool sonido = minas.longPress(i, j);
                                  if (sonido) {
                                    Provider.of<VariablesEntorno>(context,
                                            listen: false)
                                        .emiteSonido(sonido: Sonido.flag);
                                  }
                                }
                              : null,
                          onTap: minas.getMapa[i][j].estado !=
                                      EstadoCelda.destapada &&
                                  (minas.estado == Estado.enCurso ||
                                      minas.estado == Estado.sinIniciar)
                              ? () {
                                  // Si bandera simula una pulsación continua
                                  if (pulsadaBandera.value) {
                                    final bool sonido = minas.longPress(i, j);
                                    if (sonido) {
                                      Provider.of<VariablesEntorno>(context,
                                              listen: false)
                                          .emiteSonido(sonido: Sonido.flag);
                                    }
                                    // sólo desmarcamos automáticamente si no activada
                                    if (!Provider.of<VariablesEntorno>(context,
                                            listen: false)
                                        .getEntornoApp
                                        .mostrarFlag!) {
                                      pulsadaBandera.value = false;
                                    }
                                  } else {
                                    if (minas.miTurno &&
                                        minas.getMapa[i][j].estado !=
                                            EstadoCelda.bandera) {
                                      final Estado est = minas.click(i, j);
                                      minas.clickWS(x: i, y: j, resultado: est);
                                      if (est == Estado.enCurso) {
                                        Provider.of<VariablesEntorno>(context,
                                                listen: false)
                                            .emiteSonido(sonido: Sonido.click);
                                      }
                                    }
                                  }
                                }
                              : null,
                          child: Celda(
                            totalEspacio: tamCelda,
                            miTurno: minas.miTurno,
                            numero: minas.getMapa[i][j].numero,
                            estado: minas.getMapa[i][j].estado,
                            estadoPartida: minas.estado,
                            celdaErronea: minas.getMapa[i][j].estado ==
                                    EstadoCelda.destapada &&
                                minas.getMapa[i][j].numero == -1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );

              if (minas.estado == Estado.fiko || minas.estado == Estado.fiok) {
                _contrModo.animateTo(0);
              } else {
                _contrModo
                  ..forward()
                  ..repeat(
                      reverse: true, period: const Duration(milliseconds: 600));
              }

              final double espacio =
                  // minas.help ? espacioMax.width * .02 :
                  espacioMax.width * .05;

              return Stack(
                children: [
                  ListView(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          minas.miTurno
                              ? botonAnimado(
                                  circular: false,
                                  color: Colors.red[200],
                                  animacion: _contrModo,
                                  child: tablero)
                              : tablero,

                          // Entre tablero y parte inferior
                          const SizedBox(height: 3),
                        ],
                      ),
                      const SizedBox(height: 124),
                    ],
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 68,
                    child: Column(
                      children: [
                        //
                        // mensaje que nos han enviado
                        //
                        if (minas.mensaje.isNotEmpty)
                          Center(
                            child: AnimatedOpacity(
                              opacity: minas.msjOpacity,
                              duration:
                                  const Duration(milliseconds: TTRANSMENSAJE),
                              child: Cajetin(
                                maxWidth: true,
                                pressed: true,
                                child: Text.rich(
                                  TextSpan(
                                      text: minas.msjNick,
                                      style: TextStyle(
                                        fontSize: TAMMSGS - 14,
                                        color: PRINCOLOR,
                                        fontFamily: 'Digit',
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' ${minas.mensaje}',
                                          style: const TextStyle(
                                              fontSize: TAMMSGS - 12,
                                              color: Colors.black,
                                              fontFamily: 'Digit',
                                              fontWeight: FontWeight.normal),
                                        )
                                      ]),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            SizedBox(width: espacio),
                            Column(children: [
                              //
                              // Número de bombas restantes
                              //
                              Cajetin(
                                  pressed: true,
                                  min: false,
                                  child: Text(
                                    Fun.colocaEspacioSi1(minas.pendientes),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Digit',
                                        fontSize: TAMARCADOR),
                                  )),
                              if (minas.timer) const SizedBox(height: 8),
                              //
                              // Contador de tiempo
                              //
                              if (minas.timer)
                                MuestraContador(
                                    miTurno: minas.miTurno,
                                    estado: minas.estado),
                            ]),
                            SizedBox(width: espacio / 2),
                            Column(children: [
                              //
                              // botón de ayuda
                              //
                              if (minas.help &&
                                  (minas.estado == Estado.enCurso ||
                                      minas.estado == Estado.sinIniciar))
                                ValueListenableBuilder(
                                  valueListenable: pulsadaAyuda,
                                  builder:
                                      (final _, final bool puls, final __) =>
                                          InkWell(
                                    onTap: minas.miTurno
                                        ? () {
                                            pulsadaAyuda.value = true;
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 300), () {
                                              pulsadaAyuda.value = false;
                                            });
                                            minas.ayudado();
                                            Provider.of<VariablesEntorno>(
                                                    context,
                                                    listen: false)
                                                .emiteSonido(
                                                    sonido: Sonido.click);
                                          }
                                        : null,
                                    child: Cajetin(
                                      pressed: puls,
                                      child: Text(minas.vecesHelp.toString(),
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Mines',
                                              fontSize: TAMCELDA - 14)),
                                    ),
                                  ),
                                ),
                              if (minas.help &&
                                  (minas.estado == Estado.enCurso ||
                                      minas.estado == Estado.sinIniciar))
                                const SizedBox(height: 8),
                              //
                              // Bandera: simular pulsación larga
                              //
                              InkWell(
                                onTap: (minas.estado == Estado.enCurso ||
                                        minas.estado == Estado.sinIniciar)
                                    ? () {
                                        pulsadaBandera.value =
                                            !pulsadaBandera.value;
                                      }
                                    : null,
                                child: ValueListenableBuilder(
                                  valueListenable: pulsadaBandera,
                                  builder:
                                      (final _, final bool pulsada, final __) {
                                    return Cajetin(
                                        pressed: pulsada,
                                        child: Icon(
                                          pulsada && minas.pendientes > 0
                                              ? Icons.flag_outlined
                                              : Icons.flag,
                                          color: minas.pendientes > 0
                                              ? PRINCOLOR
                                              : pulsada
                                                  ? Colors.black
                                                  : Colors.grey,
                                        ));
                                  },
                                ),
                              ),
                            ]),
                            const Spacer(),
                            const BotonConexion(),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Serpentina en caso de ganada
                  if ((minas.estado == Estado.fiok && minas.miTurno) ||
                      (minas.estado == Estado.fiko && !minas.miTurno))
                    LanzaConfeti(random: Random().nextInt(5)),

                  // Bomba en caso de perdida
                  if (((minas.estado == Estado.fiko && minas.miTurno) ||
                          (minas.estado == Estado.fiok && !minas.miTurno)) &&
                      !minas.mostradoKO)
                    const MuestraFallo2(),
                ],
              );
            },
          );
  }

  @override
  void initState() {
    // lo inicializamos aquí para que los setstate no inicialicen su valor
    pulsadaBandera = ValueNotifier(false);
    pulsadaAyuda = ValueNotifier(false);

    // animaciones del jugador que le toca el turno
    _contrModo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..forward()
      ..repeat(reverse: true, period: const Duration(milliseconds: 600));

    super.initState();
  }

  @override
  void dispose() {
    pulsadaBandera.dispose();
    pulsadaAyuda.dispose();
    _contrModo.dispose();
    super.dispose();
  }
}

class BotonConexion extends StatefulWidget {
  const BotonConexion({super.key});

  @override
  State<BotonConexion> createState() => _BotonConexionState();
}

class _BotonConexionState extends State<BotonConexion>
    with TickerProviderStateMixin {
  late bool seleccionadoInicio;
  late bool seleccionadoStop;
  late bool muestraBotonPlay;
  late bool muestraBotonStop;
  late bool muestraBotonInicio;
  late AnimationController _contrModo;

  @override
  Widget build(BuildContext context) {
    final MultiminasProv provM = Provider.of<MultiminasProv>(context);
    final EstadoWS estado = provM.conectado;
    final int numUsuarios = provM.numUsuarios;
    final String nickTurno = provM.nickTurno;
    final bool miTurno = provM.miTurno;
    final String nick =
        Provider.of<VariablesEntorno>(context).getEntornoApp.nickname!;

    final Widget nickText = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        nickTurno,
        style: TextStyle(
          fontSize: TAMMSGS - 6,
          color: PRINCOLOR,
          fontFamily: 'Digit',
        ),
      ),
    );

    // print('en botón conexión $estado $numUsuarios $nick');
    return Center(
      child:
          //
          //  No hay nickname, lo indicamos para que se corrija
          nick == ''
              ? Text(
                  'No nickname',
                  style: TextStyle(
                    fontSize: TAMMSGS,
                    color: PRINCOLOR,
                    fontFamily: 'Digit',
                  ),
                )
              //
              // Si lo hay, y está iniciada ya lapartida
              : estado == EstadoWS.ocupado
                  ? Text(
                      'Busy ..\nWait a minute',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: TAMMSGS,
                        color: PRINCOLOR,
                        fontFamily: 'Digit',
                      ),
                    )
                  //
                  // Si lo hay, si no estamos conectados mostramos botón de conectarse
                  : estado == EstadoWS.noConectado
                      ? InkWell(
                          onTap: _conectaServidor,
                          child: botonPantalla(
                            grande: true,
                            icono: Icons.cloud_upload,
                            muestra: muestraBotonPlay,
                            color: Colors.green,
                            seleccionado: seleccionadoInicio,
                          ),
                        )
                      //
                      // Esperando a que nos conectemos
                      : estado == EstadoWS.esperando
                          ? Text(
                              'Waiting ..',
                              style: TextStyle(
                                fontSize: TAMMSGS,
                                color: PRINCOLOR,
                                fontFamily: 'Digit',
                              ),
                            )
                          //
                          // Si estamos conectados, pero aún no iniciada partida
                          : estado == EstadoWS.conectado
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Mostramos siempre el número de jugadores
                                    Text(
                                      numUsuarios == 1
                                          ? '1  Player'
                                          : '$numUsuarios  Players',
                                      style: TextStyle(
                                        fontSize: TAMMSGS,
                                        color: PRINCOLOR,
                                        fontFamily: 'Digit',
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Botón de desconectar siempre también
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: _desconectaServidor,
                                            child: botonPantalla(
                                              icono: Icons.cancel,
                                              muestra: muestraBotonStop,
                                              color: Colors.red,
                                              seleccionado: seleccionadoStop,
                                            ),
                                          ),
                                          if (numUsuarios > 1)
                                            InkWell(
                                              onTap: _iniciaPartida,
                                              child: botonPantalla(
                                                icono: Icons.play_arrow,
                                                muestra: muestraBotonInicio,
                                                color: Colors.green,
                                                seleccionado:
                                                    seleccionadoInicio,
                                              ),
                                            )
                                        ]),
                                  ],
                                )
                              :
                              //
                              // En otro caso será jugando
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Mostramos el jugador que tiene el turno
                                    InkWell(
                                      onTap: () {
                                        _enviaMensaje(context);
                                      },
                                      child: miTurno
                                          ? nickText
                                          : botonAnimado(
                                              circular: false,
                                              animacion: _contrModo,
                                              child: nickText),
                                    ),
                                    // const SizedBox(height: 6),
                                    // Botón de desconectar
                                    InkWell(
                                      onTap: _desconectaServidor,
                                      child: botonPantalla(
                                        icono: Icons.cancel,
                                        muestra: muestraBotonStop,
                                        color: Colors.red,
                                        seleccionado: seleccionadoStop,
                                      ),
                                    ),
                                  ],
                                ),
    );
  }

  Future<void> _enviaMensaje(BuildContext context) async {
    final String nickName =
        Provider.of<VariablesEntorno>(context, listen: false)
            .getEntornoApp
            .nickname!;

    return Dialogo.capturaTexto(
      context: context,
      tittle: 'Message',
      retorno: (final texto) {
        // enviamos el texto
        Provider.of<MultiminasProv>(context, listen: false)
            .sendMsg(nickName, msg: texto);
      },
      maxlenght: 24,
    );
  }

  Widget botonPantalla({
    required bool muestra,
    required bool seleccionado,
    required IconData icono,
    required Color color,
    bool grande = false,
  }) {
    final Widget interno = AnimatedOpacity(
      opacity: muestra ? 1.0 : 0.0,
      duration: TBOTON,
      child: BotonNeumorfico(
        circular: true,
        color: color,
        colorFondo: CANVASCOLOR,
        seleccionado: seleccionado,
        icono: icono,
        padding: !grande ? const EdgeInsets.all(3) : null,
        margin: !grande ? EdgeInsets.zero : const EdgeInsets.all(24),
      ),
    );
    return grande
        ? SizedBox(
            height: 130,
            child: interno,
          )
        : interno;
  }

  // Nos conectamos al servidor
  Future<void> _conectaServidor() async {
    // por si se pulsa varias veces sólo envíe 1 al servidor
    if (!muestraBotonPlay) {
      return;
    }
    // animación del botón
    setState(() {
      muestraBotonPlay = false;
      seleccionadoInicio = true;
    });
    // Para que la siguiente vez vuelva a hacer animación
    Future.delayed(TBOTON, () {
      inicializaVariables();
    });
    // damos tiempo a que se realice toda la animación
    await Future.delayed(TBOTON, () {});

    final VariablesEntorno entorno =
        Provider.of<VariablesEntorno>(context, listen: false);

    // Enviamos a servidor petición de conexión
    unawaited(Provider.of<MultiminasProv>(context, listen: false)
        .initWS(nickname: entorno.getEntornoApp.nickname!));
  }

  // Desconexión del servidor
  Future<void> _desconectaServidor() async {
    // animación del botón
    // print('entra desconecta servidor');
    setState(() {
      muestraBotonStop = false;
      seleccionadoStop = true;
    });
    Future.delayed(TBOTON, () {
      inicializaVariables();
    });
    await Future.delayed(TBOTON, () {});

    // nos desconactamos
    final MultiminasProv provM =
        Provider.of<MultiminasProv>(context, listen: false);
    provM.closeConnection();

    // tratamiento del temporizador
    if (provM.timer) {
      Provider.of<ContadorProv>(context, listen: false).closeTemporizador();
    }
  }

  Future<void> _iniciaPartida() async {
    final MultiminasProv provM =
        Provider.of<MultiminasProv>(context, listen: false);

    // animación del botón
    setState(() {
      muestraBotonInicio = false;
      seleccionadoInicio = true;
    });

    final VariablesEntorno entorno =
        Provider.of<VariablesEntorno>(context, listen: false);

    Future.delayed(TBOTON, () {
      inicializaVariables();
    });

    // iniciamos partida
    await Future.delayed(TBOTON, () {});

    // genera tablero nuevo
    await provM.initPartidaMulti();

    // envia al servidor
    provM.iniciaPartida(
      x: provM.totX,
      y: provM.totY,
      mapa: provM.getMapa,
      timer: entorno.getEntornoApp.conTiempo!,
      help: entorno.getEntornoApp.conAyuda!,
    );
  }

  // inicializar variables para animación
  void inicializaVariables() {
    seleccionadoInicio = false;
    seleccionadoStop = false;
    muestraBotonPlay = true;
    muestraBotonStop = true;
    muestraBotonInicio = true;
  }

  // Inicio -------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    // animaciones del jugador que no le toca el turno
    _contrModo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..forward()
      ..repeat(reverse: true, period: const Duration(milliseconds: 600));

    inicializaVariables();
  }

  @override
  void dispose() {
    _contrModo.dispose();
    super.dispose();
  }
}

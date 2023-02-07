import 'package:buscaminas/2clases/zclases.dart';
import 'package:flutter/material.dart';

import 'package:buscaminas/0varios/constantes.dart';
import 'package:buscaminas/5providers/zproviders.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen() : super();

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _contrModo;
  late Animation<double> animation;
  late TextEditingController contrTextNick;

  late bool permiteModif;

  late VariablesEntorno _entorno;
  late BuscaminasProv _provider;
  late MultiminasProv _providerM;

  @override
  Widget build(BuildContext context) {
    final Size espacioMax = AppLayout.getSize(context);
    final double espaciadoV = espacioMax.height * .005;
    final double espaciadoH = espacioMax.width * .005;

    return ColoredBox(
      color: CANVASCOLOR,
      child: ListView(
        children: [
          // Margen superior
          SizedBox(height: espaciadoV * 05),

          Row(
            children: [
              SizedBox(width: espacioMax.width * .12),
              //
              // Eje X
              //
              Column(
                children: [
                  Contador(
                    accionUp: permiteModif && Temp.totX < MAXIMOS[0]
                        ? () {
                            setState(() {
                              Temp.totX++;
                              _entorno.setEntornoApp =
                                  Entorno(algunCambio: algunCambio());
                            });
                          }
                        : null,
                    accionDown: permiteModif &&
                            Temp.totX > MINIMOS[0] &&
                            ((Temp.totX - 1) * Temp.totY > Temp.bombas)
                        ? () {
                            setState(() {
                              Temp.totX--;
                              _entorno.setEntornoApp =
                                  Entorno(algunCambio: algunCambio());
                            });
                          }
                        : null,
                    numero: Temp.totX.toString(),
                  ),
                  SizedBox(height: espaciadoV * 7),

                  // ladrillos horizontales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ladrillos(),
                  ),
                ],
              ),
              const Spacer(),
              //
              // Modo settings: mono o multi
              //
              botonAnimado(
                animacion: _contrModo,
                child: botonAccion(
                    imagen: Provider.of<VariablesEntorno>(context)
                            .getEntornoApp
                            .monoSettings!
                        ? 'assets/images/ic_bomba.png'
                        : 'assets/images/ic_bomba2.png',
                    colorFondo: const Color.fromARGB(255, 255, 199, 164),
                    accion: () {
                      Provider.of<VariablesEntorno>(context, listen: false)
                          .toggleModo();
                      inicializaVars(esInicial: false);
                    }),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: espaciadoV * 10),

          //
          // Eje Y + Número de minas
          //
          Row(
            children: [
              SizedBox(width: espaciadoH * 15),
              // ladrillos verticales
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ladrillos(),
              ),
              SizedBox(width: espaciadoH * 15),

              // contador
              Contador(
                  horizontal: false,
                  accionUp: permiteModif && Temp.totY < MAXIMOS[1]
                      ? () {
                          setState(() {
                            Temp.totY++;
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null,
                  accionDown: permiteModif &&
                          Temp.totY > MINIMOS[1] &&
                          ((Temp.totY - 1) * Temp.totX > Temp.bombas)
                      ? () {
                          setState(() {
                            Temp.totY--;
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null,
                  numero: Temp.totY.toString()),
              const Spacer(),
              //
              // Número de minas
              //
              Contador(
                  horizontal: false,
                  accionUp: permiteModif &&
                          Temp.bombas < MAXIMOS[2] &&
                          (Temp.totX * Temp.totY > Temp.bombas + INTERBOMB)
                      ? () {
                          setState(() {
                            Temp.bombas += INTERBOMB;
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null,
                  accionDown: permiteModif &&
                          Temp.bombas > MINIMOS[2] &&
                          Temp.bombas > INTERBOMB
                      ? () {
                          setState(() {
                            Temp.bombas -= INTERBOMB;
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null,
                  imagen: 'assets/images/mina.png',
                  numero: Temp.bombas.toString()),
              SizedBox(width: espaciadoH * 15),
            ],
          ),
          SizedBox(height: espaciadoV * 8),

          //
          // Emoticonos con los Modos standard
          //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              emoticono(
                  seleccionable: permiteModif,
                  seleccionado: Temp.totX == FACIL[0] &&
                      Temp.totY == FACIL[1] &&
                      Temp.bombas == FACIL[2],
                  imagen: 'assets/images/facil.png',
                  accion: permiteModif
                      ? () {
                          setState(() {
                            Temp.totX = FACIL[0];
                            Temp.totY = FACIL[1];
                            Temp.bombas = FACIL[2];
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null),
              emoticono(
                  seleccionable: permiteModif,
                  seleccionado: Temp.totX == MEDIO[0] &&
                      Temp.totY == MEDIO[1] &&
                      Temp.bombas == MEDIO[2],
                  imagen: 'assets/images/medio.png',
                  accion: permiteModif
                      ? () {
                          setState(() {
                            Temp.totX = MEDIO[0];
                            Temp.totY = MEDIO[1];
                            Temp.bombas = MEDIO[2];
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null),
              emoticono(
                  seleccionable: permiteModif,
                  seleccionado: Temp.totX == DIFIC[0] &&
                      Temp.totY == DIFIC[1] &&
                      Temp.bombas == DIFIC[2],
                  imagen: 'assets/images/dificil.png',
                  accion: permiteModif
                      ? () {
                          setState(() {
                            Temp.totX = DIFIC[0];
                            Temp.totY = DIFIC[1];
                            Temp.bombas = DIFIC[2];
                            _entorno.setEntornoApp =
                                Entorno(algunCambio: algunCambio());
                          });
                        }
                      : null),

              //
              // Bandera: mostrar o no esta opción en el juego
              //
              InkWell(
                onTap: () {
                  setState(() {
                    Temp.flag = !Temp.flag;
                    _entorno.setEntornoApp =
                        Entorno(algunCambio: algunCambio());
                  });
                },
                child: Column(
                  children: [
                    Icon(Temp.flag ? Icons.flag_sharp : Icons.flag_outlined,
                        color: Temp.flag ? PRINCOLOR : Colors.grey,
                        size: TAMICSET),
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Temp.flag
                            ? Icon(Icons.toggle_on,
                                key: const ValueKey('icon1'),
                                size: TAMICSET,
                                color: PRINCOLOR)
                            : const Icon(
                                Icons.toggle_off,
                                key: ValueKey('icon2'),
                                size: TAMICSET,
                                color: Colors.grey,
                              )),
                  ],
                ),
              ),
              //
              // Con o sin sonido
              //
              botonAccion(
                  icono: Temp.sonido
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  mini: true,
                  accion: () {
                    setState(() {
                      Temp.sonido = !Temp.sonido;
                      _entorno.setEntornoApp =
                          Entorno(algunCambio: algunCambio());
                    });
                  }),
            ],
          ),
          SizedBox(height: espaciadoV * 6),
          if (!_entorno.getEntornoApp.monoSettings!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //
                // Con o sin tiempo
                //
                botonAccion(
                    icono: Temp.conTiempo
                        ? Icons.timer_outlined
                        : Icons.timer_off_outlined,
                    mini: true,
                    accion: permiteModif
                        ? () {
                            setState(() {
                              Temp.conTiempo = !Temp.conTiempo;
                              _entorno.setEntornoApp =
                                  Entorno(algunCambio: algunCambio());
                            });
                          }
                        : null),
                //
                // Nickname
                //
                SizedBox(
                  width: 170,
                  child: InputButton(
                      onFieldSubmitted: (str) {
                        if (str != null) {
                          Temp.nick = str.trim();
                          _entorno.setEntornoApp =
                              Entorno(algunCambio: algunCambio());
                        } else {
                          Temp.nick = '';
                        }
                      },
                      hintText: 'Nickname',
                      textoMax: 10,
                      lineasMax: 1,
                      controlador: contrTextNick,
                      opcional: false,
                      gestionable: permiteModif),
                ),
                //
                // Con o sin ayuda de un movimiento
                //
                botonAccion(
                    icono: Icons.question_mark_outlined,
                    mini: true,
                    colorFondo: Temp.conAyuda ? null : Colors.grey[400],
                    accion: permiteModif
                        ? () {
                            setState(() {
                              Temp.conAyuda = !Temp.conAyuda;
                              _entorno.setEntornoApp =
                                  Entorno(algunCambio: algunCambio());
                            });
                          }
                        : null),
              ],
            ),
        ],
      ),
    );
  }

  // Si hay algún cambio respecto al actual
  bool algunCambio() {
    final bool comunes = Temp.totX != Temp.ini_totX ||
        Temp.totY != Temp.ini_totY ||
        Temp.bombas != Temp.ini_bombas ||
        Temp.flag != Temp.ini_flag ||
        Temp.sonido != Temp.ini_sonido;

    return _entorno.getEntornoApp.monoSettings!
        ? comunes
        : comunes ||
            Temp.ini_nick != Temp.nick ||
            Temp.conTiempo != Temp.ini_conTiempo ||
            Temp.conAyuda != Temp.ini_conAyuda;
  }

  // inicializa todas las variables de la pantalla
  void inicializaVars({bool esInicial = true}) {
    _entorno = Provider.of<VariablesEntorno>(context, listen: false);

    if (_entorno.getEntornoApp.monoSettings!) {
      _provider = Provider.of<BuscaminasProv>(context, listen: false);

      Temp.bombas = _provider.bombas;
      Temp.totX = _provider.totX;
      Temp.totY = _provider.totY;

      // en mono dejamos jugar mientras no esté en curso
      permiteModif = _provider.estado != Estado.enCurso;
    } else {
      _providerM = Provider.of<MultiminasProv>(context, listen: false);

      Temp.bombas = _providerM.bombas;
      Temp.totX = _providerM.totX;
      Temp.totY = _providerM.totY;

      // en multi sólo dejamos modif si no conectado
      permiteModif = _providerM.conectado == EstadoWS.noConectado;

      Temp.nick = _entorno.getEntornoApp.nickname!;
      contrTextNick.text = Temp.nick;
      Temp.ini_nick = Temp.nick;
    }

    // inicializamos todo
    Temp.ini_bombas = Temp.bombas;
    Temp.ini_totX = Temp.totX;
    Temp.ini_totY = Temp.totY;

    // sólo cargamos si no viene de cambio mono-multi
    if (esInicial) {
      Temp.flag = _entorno.getEntornoApp.mostrarFlag!;
      Temp.ini_flag = Temp.flag;

      Temp.sonido = _entorno.getEntornoApp.sonido!;
      Temp.ini_sonido = Temp.sonido;

      Temp.conTiempo = _entorno.getEntornoApp.conTiempo!;
      Temp.ini_conTiempo = Temp.conTiempo;

      Temp.conAyuda = _entorno.getEntornoApp.conAyuda!;
      Temp.ini_conAyuda = Temp.conAyuda;

      // inicializa a no hay cambios
      Future.delayed(RETARDOESTADO, () => _entorno.setCambio(notifica: true));
    } else {
      _entorno.setEntornoApp = Entorno(algunCambio: algunCambio());
    }
  }

  // Inicio -------------------------------------------------------------
  @override
  void initState() {
    // entrada de texto nickname
    contrTextNick = TextEditingController();

    // animaciones en pantalla
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    // animaciones del botón del mono/multi
    _contrModo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..forward()
      ..repeat(reverse: true, period: const Duration(milliseconds: 600));

    // inicializamos las variables de pantalla
    inicializaVars();

    super.initState();
  }

  @override
  void dispose() {
    _entorno.setCambio();
    _controller.dispose();
    _contrModo.dispose();
    super.dispose();
  }
}

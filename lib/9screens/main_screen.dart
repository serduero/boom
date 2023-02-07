import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:buscaminas/0varios/constantes.dart';
import 'package:buscaminas/2clases/clases.dart';
import 'package:buscaminas/5providers/zproviders.dart';
import 'package:buscaminas/9screens/zscreens.dart';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  // Juntar/separar menú del botón central (y bordes del menú)
  late AnimationController borderRadiusAnimationController;
  late Animation<double> borderRadiusAnimation;
  // ocultar el menú
  late AnimationController hideBottomBarAnimationController;
  late TextEditingController contrTextNick;
  late bool menuOn;

  int bottomNavIndex = 0; //índice de la pantalla

  final List<Pantalla> pantallas = [
    Pantalla(
      imagen: 'assets/images/ic_bomba.png',
      pantalla: const JuegoScreen(),
      actionBttn: 'assets/images/play.png',
      tipo: TipoPantalla.JuegoMono,
    ),
    Pantalla(
      imagen: 'assets/images/ic_bomba2.png',
      pantalla: const MultiJugador(),
      actionBttn: 'assets/images/play.png',
      tipo: TipoPantalla.JuegoMulti,
    ),
    Pantalla(), // debe ser número par de pantallas siempre
    Pantalla(
      imagen: 'assets/images/ic_settings.png',
      pantalla: const ProfileScreen(),
      actionBttn: 'assets/images/ok.png',
      tipo: TipoPantalla.Settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> floatActButVisible = ValueNotifier(false);

    // ocultamos floating action button cuando salga el teclado
    if (MediaQuery.of(context).viewInsets.bottom > 200) {
      floatActButVisible.value = false;
    } else {
      floatActButVisible.value = true;
    }

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: onScrollNotification,
        child: pantallas[bottomNavIndex].pantalla!,
      ),

      //
      // botón central
      //
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: mostrarFloating()
          ? ValueListenableBuilder(
              valueListenable: floatActButVisible,
              builder: (final _, final bool visible, final __) => Visibility(
                visible: visible,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 500),
                  padding: menuOn
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(bottom: 6),
                  child: FloatingActionButton(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.green.withOpacity(.3),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Image.asset(
                      pantallas[bottomNavIndex].actionBttn!,
                      fit: BoxFit.contain,
                      width: TAMRESTART,
                      height: TAMRESTART,
                    ),
                    onPressed: () {
                      final VariablesEntorno entorno =
                          Provider.of<VariablesEntorno>(context, listen: false);

                      //
                      // Guardar en SETTINGS
                      //
                      if (pantallas[bottomNavIndex].tipo ==
                          TipoPantalla.Settings) {
                        // guardamos según sea los monojugador o los multi
                        if (entorno.getEntornoApp.monoSettings!) {
                          final BuscaminasProv prov =
                              Provider.of<BuscaminasProv>(context,
                                  listen: false);

                          prov.setMapa(Temp.totX, Temp.totY, Temp.bombas);

                          // Reiniciamos con lo existente en el estado con el cambio
                          if (prov.estado != Estado.enCurso) {
                            prov.initPartidaMono();

                            entorno.setEntornoApp = Entorno(
                              monoX: Temp.totX,
                              monoY: Temp.totY,
                              monoB: Temp.bombas,
                              mostrarFlag: Temp.flag,
                              sonido: Temp.sonido,
                              algunCambio: false, // para que quite el check
                            );
                          } else {
                            entorno.setEntornoApp = Entorno(
                              mostrarFlag: Temp.flag,
                              sonido: Temp.sonido,
                              algunCambio: false, // para que quite el check
                            );
                          }
                        } else {
                          // En multijugador
                          final MultiminasProv provM =
                              Provider.of<MultiminasProv>(context,
                                  listen: false);

                          provM.setMapaMulti(Temp.totX, Temp.totY, Temp.bombas);

                          // Reiniciamos con lo existente ya que algo habrá cambiado
                          // pero sólo si no se ha conectado
                          if (provM.conectado == EstadoWS.noConectado) {
                            provM.initPartidaMulti();
                          }

                          entorno.setEntornoApp = Entorno(
                            nickname: Temp.nick, conTiempo: Temp.conTiempo,
                            conAyuda: Temp.conAyuda,
                            multiX: Temp.totX,
                            multiY: Temp.totY,
                            multiB: Temp.bombas,
                            mostrarFlag: Temp.flag,
                            sonido: Temp.sonido,
                            algunCambio: false, // para que quite el check
                          );

                          // tratamiento temporizador
                          if (!Temp.conTiempo) {
                            Provider.of<ContadorProv>(context, listen: false)
                                .closeTemporizador();
                          }
                        }

                        // Mientras estemos en settings debemos actualizar ini
                        // para que no salga el check ante cambio de mono a multi
                        Temp.ini_flag = Temp.flag;
                        Temp.ini_sonido = Temp.sonido;
                        Temp.ini_conAyuda = Temp.conAyuda;
                        Temp.ini_conTiempo = Temp.conTiempo;
                      }

                      //
                      // Play en MONOJUGADOR
                      //
                      if (pantallas[bottomNavIndex].tipo ==
                          TipoPantalla.JuegoMono) {
                        final BuscaminasProv prov =
                            Provider.of<BuscaminasProv>(context, listen: false);

                        // Reiniciamos partida
                        if (prov.estado != Estado.enCurso) {
                          prov.initPartidaMono();
                        }
                      }

                      //
                      // Play en MULTIJUGADOR
                      //
                      if (pantallas[bottomNavIndex].tipo ==
                          TipoPantalla.JuegoMulti) {
                        final MultiminasProv provM =
                            Provider.of<MultiminasProv>(context, listen: false);

                        // Reiniciamos partida
                        provM.initPartidaMulti();

                        // tratamiento temporizador
                        final bool timer = entorno.getEntornoApp.conTiempo!;
                        final bool help = entorno.getEntornoApp.conAyuda!;

                        if (timer) {
                          Provider.of<ContadorProv>(context, listen: false)
                              .initTemporizador();
                        }

                        if (provM.numUsuarios > 1) {
                          // se puede reiniciar otra
                          provM.iniciaPartida(
                              x: provM.totX,
                              y: provM.totY,
                              timer: timer,
                              help: help,
                              mapa: provM.getMapa);
                        } else {
                          // si no hay suficientes jugadores cerramos conexión
                          provM.closeConnection();
                        }
                      }

                      borderRadiusAnimationController.reset();
                      borderRadiusAnimationController.forward();
                    },
                  ),
                ),
              ),
            )
          : null,

      // bottom menu
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        // elementos a mostrar
        itemCount: pantallas.length,

        // seleccionado un icono
        onTap: (index) {
          if (pantallas[index].pantalla != null) {
            setState(() => bottomNavIndex = index);
          }
        },
        activeIndex: bottomNavIndex,

        // iconos de cada elemento
        tabBuilder: (int index, bool isActive) {
          return pantallas[index].pantalla != null
              ? Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: pantallas[index].icono != null
                        ? Icon(
                            pantallas[index].icono,
                            size: TAMICONO,
                            // color: color,
                          )
                        : pantallas[index].imagen2 != null
                            ? dibujoDoble(
                                pantallas[index].imagen!,
                                pantallas[index].imagen2!,
                              )
                            : Image.asset(
                                pantallas[index].imagen!,
                                fit: BoxFit.contain,
                              ),
                  ),
                )
              : const SizedBox.shrink();
        },

        // características del menú
        backgroundColor: MENUCOLOR,
        splashColor: PRINCOLOR,
        notchAndCornersAnimation: borderRadiusAnimation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        hideAnimationController: hideBottomBarAnimationController,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 12,
          spreadRadius: 0.5,
        ),
      ),
    );
  }

  // muestra 2 imagenes
  Widget dibujoDoble(String s, String ss) {
    return Stack(
      children: [
        Image.asset(
          ss,
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              s,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  // en caso de hacer scroll vertical: ocultamos/mostramos el menú
  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          setState(() {
            menuOn = true;
          });

          hideBottomBarAnimationController.reverse();
          break;
        case ScrollDirection.forward:
          setState(() {
            menuOn = false;
          });

          hideBottomBarAnimationController.forward();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  // si mostrar o no el floating action button
  bool mostrarFloating() {
    // se muestra en pantalla del juego si se ha finalizado ok o no ok
    return (pantallas[bottomNavIndex].tipo == TipoPantalla.Settings &&
            Provider.of<VariablesEntorno>(context)
                .getEntornoApp
                .algunCambio!) ||
        ((Provider.of<BuscaminasProv>(context).estado == Estado.fiko ||
                Provider.of<BuscaminasProv>(context).estado == Estado.fiok) &&
            pantallas[bottomNavIndex].tipo == TipoPantalla.JuegoMono) ||
        ((Provider.of<MultiminasProv>(context).estado == Estado.fiko ||
                Provider.of<MultiminasProv>(context).estado == Estado.fiok) &&
            pantallas[bottomNavIndex].tipo == TipoPantalla.JuegoMulti);
  }

  // Inicio -------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    contrTextNick = TextEditingController(); // nickname en multijugador
    menuOn = true;
    late CurvedAnimation borderRadiusCurve;

    // animación del menú principal: juntarse / separarse
    borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    borderRadiusCurve = CurvedAnimation(
      parent: borderRadiusAnimationController,
      curve: const Interval(0.5, 1, curve: Curves.fastOutSlowIn),
    );
    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    // animación de ocultar o mostrar el menú
    hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // hace que el menú rodee el botón circular inferior
    Future.delayed(
      const Duration(seconds: 1),
      () => borderRadiusAnimationController.forward(),
    );
  }

  @override
  void dispose() {
    borderRadiusAnimationController.dispose();
    hideBottomBarAnimationController.dispose();
    super.dispose();
  }
}

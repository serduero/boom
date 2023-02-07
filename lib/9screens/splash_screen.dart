import 'package:flutter/material.dart';
import 'dart:async';

import 'package:buscaminas/0varios/zvarios.dart';
import 'package:buscaminas/2clases/zclases.dart';
import 'package:buscaminas/5providers/zproviders.dart';
import 'package:buscaminas/6views/animacion_splash.dart';
import 'package:buscaminas/9screens/zscreens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool muestraBoton = false, seleccionado = false;

  @override
  Widget build(final BuildContext context) {
    final Size espacioMax = AppLayout.getSize(context);

    return Scaffold(
      body: ColoredBox(
        color: CANVASCOLOR,
        child: Stack(
          children: [
            // animación de la pantalla
            AnimacionSplash(
              controller: _controller.view,
              colorPrincipal: PRINCOLOR,
              elemento: Image.asset(
                'assets/images/portada.png',
                fit: BoxFit.contain,
              ),
            ),
            // mostramos el botón con fade in
            Positioned.fill(
                bottom: -espacioMax.height * .8,
                child: Align(
                    child: InkWell(
                  onTap: _tapped,
                  child: AnimatedOpacity(
                    opacity: muestraBoton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: BotonNeumorfico(
                      circular: true,
                      color: PRINCOLOR,
                      colorFondo: CANVASCOLOR,
                      seleccionado: seleccionado,
                      icono: Icons.play_arrow,
                    ),
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  // Animaciones iniciales de la pantalla
  Future<void> _lanzarAnimaciones(final BuildContext context) async {
    Future.delayed(const Duration(microseconds: 100), () async {
      if (mounted) {
        // iniciamos las partidas
        unawaited(Provider.of<BuscaminasProv>(context, listen: false)
            .initPartidaMono(notifica: false));
        unawaited(Provider.of<MultiminasProv>(context, listen: false)
            .initPartidaMulti(notifica: false));
      }
      try {
        // mostramos el botón de continuar al cambo de un tiempo
        unawaited(Future.delayed(const Duration(milliseconds: 1700), () async {
          if (mounted) {
            setState(() {
              muestraBoton = true;
            });
          }
        }));

        // hacemos animación
        await _controller.forward().orCancel;
      } on TickerCanceled {
        // Animación cancelada
      }
    });
  }

  // Acciones tras pulsar el botón de iniciar
  Future<void> _tapped() async {
    try {
      // marcamos botón como pulsado
      setState(() {
        seleccionado = true;
      });

      // lo ocultamos tras un tiempo...
      unawaited(Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          setState(() {
            muestraBoton = false;
          });
        }
      }));

      // ..a la vez que iniciamos la animación inversa
      await _controller.reverse().orCancel;

      // y lanzamos la página principal
      await transicionPagina(context, pagina: const MainPage());
    } on TickerCanceled {
      // Animación cancelada
    }
  }

  // Inicio -------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: TIEMPOANIMAC, vsync: this);

    // Iniciamos la app
    Provider.of<ManejadorApp>(context, listen: false).iniciaApp(context);

    // cargamos la animación de la pantalla
    _lanzarAnimaciones(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

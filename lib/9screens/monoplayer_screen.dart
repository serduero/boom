import 'package:flutter/material.dart';
import 'dart:math';

import 'package:buscaminas/0varios/zvarios.dart';
import 'package:buscaminas/2clases/zclases.dart';
import 'package:buscaminas/5providers/zproviders.dart';
import 'package:buscaminas/6views/zviews.dart';

class JuegoScreen extends StatelessWidget {
  const JuegoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Provider.of<VariablesEntorno>(context, listen: false).setEntornoApp =
          Entorno(monoSettings: true);
    });

    return ColoredBox(
      color: CANVASCOLOR,
      child: const Mapa(),
    );
  }
}

final ValueNotifier<bool> pulsadaBandera = ValueNotifier(false);

class Mapa extends StatelessWidget {
  const Mapa({super.key});

  @override
  Widget build(BuildContext context) {
    final Size espacioMax = AppLayout.getSize(context);

    return Consumer<BuscaminasProv>(
      builder: (_, minas, __) {
        final double tamCelda = (espacioMax.width * .9) / minas.totX;

        return Stack(
          children: [
            ListView(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
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
                                        final bool sonido =
                                            minas.longPress(i, j);
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
                                          final bool sonido =
                                              minas.longPress(i, j);
                                          if (sonido) {
                                            Provider.of<VariablesEntorno>(
                                                    context,
                                                    listen: false)
                                                .emiteSonido(
                                                    sonido: Sonido.flag);
                                          }

                                          // sólo desmarcamos automáticamente si no activada
                                          if (!Provider.of<VariablesEntorno>(
                                                  context,
                                                  listen: false)
                                              .getEntornoApp
                                              .mostrarFlag!) {
                                            pulsadaBandera.value = false;
                                          }
                                        } else {
                                          if (minas.getMapa[i][j].estado !=
                                              EstadoCelda.bandera) {
                                            final Estado est =
                                                minas.click(i, j);
                                            if (est == Estado.enCurso) {
                                              Provider.of<VariablesEntorno>(
                                                      context,
                                                      listen: false)
                                                  .emiteSonido(
                                                      sonido: Sonido.click);
                                            }
                                          }
                                        }
                                      }
                                    : null,
                                child: Celda(
                                  totalEspacio: tamCelda,
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
                    ),
                  ],
                ),
                const SizedBox(height: 92),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //
                  // Número de bombas restantes
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
                  //
                  // Bandera: simular pulsación larga
                  InkWell(
                    onTap: (minas.estado == Estado.enCurso ||
                            minas.estado == Estado.sinIniciar)
                        ? () {
                            pulsadaBandera.value = !pulsadaBandera.value;
                          }
                        : null,
                    child: ValueListenableBuilder(
                      valueListenable: pulsadaBandera,
                      builder: (final _, final bool pulsada, final __) {
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
                ],
              ),
            ),

            // Serpentina en caso de ganar
            if (minas.estado == Estado.fiok)
              LanzaConfeti(random: Random().nextInt(5)),

            // Bomba en caso de perder
            if (minas.estado == Estado.fiko && !minas.mostradoKO)
              const MuestraFallo2(),
          ],
        );
      },
    );
  }
}

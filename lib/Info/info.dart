import 'package:flutter/material.dart';
import 'package:ocr/Tools/util.dart';

class Info extends StatefulWidget {
  const Info({Key? key}) : super(key: key);

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.fondo, // Fondo como los otros widgets
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(// Alinear el texto a la izquierda
              children: [
            Text(
              'Gestión de documentos de la Aldea de Niños Cristo Rey.',
              style: TextStyle(
                fontSize: 24.0, // Tamaño de fuente
                color: AppColors.negro,
                // Color del texto
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inicio',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'En esta sección, los usuarios pueden realizar búsquedas de documentos específicos. Esto facilita la localización rápida de información relevante sin necesidad de navegar manualmente por las carpetas.',
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carpetas',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aquí se visualiza la información individual de cada niño, organizada en carpetas que llevan el nombre del menor. Dentro de cada una de estas carpetas, se encuentran subcarpetas con información específica como escolaridad, salud, datos personales, y datos familiares. Esto permite una organización clara y estructurada de toda la información relacionada con cada niño.',
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Herramientas',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta sección está dedicada a funciones adicionales, como la conversión de documentos. Sin embargo, esta sección de herramientas estará disponible únicamente en la versión móvil de la aplicación, ofreciendo flexibilidad y accesibilidad en dispositivos móviles.',
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión de usuarios',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Esta opción es exclusiva para el administrador del sistema. Desde aquí, el administrador puede crear nuevas cuentas de usuario, editar perfiles y gestionar el acceso de los usuarios. Además, los "Managers" también tiene acceso a esta sección, permitiéndole visualizar los perfiles de los usuarios, aunque no podrá realizar cambios significativos.'),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

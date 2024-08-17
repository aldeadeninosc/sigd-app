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
        padding: EdgeInsets.all(16.0), // Espaciado alrededor del texto
        child: Column(// Alinear el texto a la izquierda
            children: [
          Text(
            'Información',
            style: TextStyle(
              fontSize: 24.0, // Tamaño de fuente
              color: AppColors.negro, // Color del texto
            ),
          ),
        ]),
      ),
    );
  }
}

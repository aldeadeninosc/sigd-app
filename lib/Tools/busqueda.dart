import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Set<String> nombres = {};
Set<String> apellidos = {};
final Set<String> _irrelevantWords = {
  "LA",
  "DEL",
  "EL",
  "Y",
  "EN",
  "A",
  "AL",
  "LAS",
  "POR",
  "CON",
  "PARA",
  "SE",
  "DE",
  "LOS",
  "QUE",
  "LEY",
  "SU",
  "USO",
  "O",
  "A",
  "BACHILLER",
  "GRADO"
};

List<Map<String, dynamic>> documentosData = [];

Future<void> cargarDatos() async {
  // Cargar los datasets de nombres y apellidos
  String nombresData =
      await rootBundle.loadString('assets/resources/nombres.csv');
  String apellidosData =
      await rootBundle.loadString('assets/resources/apellidos.csv');
  _processNames(nombresData);
  _processSurnames(apellidosData);

  // Cargar el dataset JSON de documentos y subcarpetas
  String documentosDataString = await rootBundle
      .loadString('assets/resources/combined_document_list.json');
  var jsonData = json.decode(documentosDataString);

  // Asegúrate de que jsonData sea una lista
  if (jsonData is List) {
    documentosData = jsonData.map((item) {
      // Asegúrate de que estás accediendo a los campos correctos
      return {
        'subcarpeta': item['output']['subcarpeta'],
        'documento': item['output']['documento'],
      };
    }).toList();
  } else {
    throw Exception('Formato de datos inesperado');
  }
}

void _processNames(String csvData) {
  final rows = LineSplitter.split(csvData);
  for (final row in rows) {
    final name = row.trim().toUpperCase();
    if (name.isNotEmpty && !_irrelevantWords.contains(name)) {
      nombres.add(name);
    }
  }
}

void _processSurnames(String csvData) {
  final rows = LineSplitter.split(csvData);
  for (final row in rows) {
    final surname = row.trim().toUpperCase();
    if (surname.isNotEmpty && !_irrelevantWords.contains(surname)) {
      apellidos.add(surname);
    }
  }
}

Map<String, dynamic> identificarDocumentoYCarpeta(String consulta) {
  List<String> palabras = consulta.toUpperCase().split(RegExp(r"\s+"));
  List<String> posiblesNombres = [];
  List<String> posiblesApellidos = [];
  List<String> documentoText = [];

  // Identificar nombres y apellidos en la consulta
  posiblesNombres =
      palabras.where((palabra) => nombres.contains(palabra)).toList();
  posiblesApellidos =
      palabras.where((palabra) => apellidos.contains(palabra)).toList();

  for (String palabra in palabras) {
    if (!nombres.contains(palabra) && !apellidos.contains(palabra)) {
      documentoText.add(palabra);
    }
  }

  // Definir el nombre completo como 'carpeta'
  String carpeta = (posiblesApellidos + posiblesNombres).join(' ');

  // Definir el texto restante como potencial 'documento'
  String textoDocumento = documentoText.join(' ');

  // Buscar el documento y la subcarpeta en el dataset
  String subcarpeta = 'Desconocida';
  String documento = 'Desconocido';
  for (Map<String, dynamic> item in documentosData) {
    String docText = item['documento'].toUpperCase();
    if (docText.contains(textoDocumento)) {
      subcarpeta = item['subcarpeta'];
      documento = item['documento'];
      break;
    }
  }

  // Retornar el resultado como un mapa
  return {
    'carpeta': carpeta
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' '),
    'subcarpeta': subcarpeta,
    'documento': documento
  };
}

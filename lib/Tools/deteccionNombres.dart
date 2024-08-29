import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class DeteccionNombres {
  static final Set<String> _irrelevantWords = {
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

  static Set<String> _namesSet = {};
  static Set<String> _surnamesSet = {};

  static Future<void> loadNames() async {
    final csvData = await rootBundle.loadString('assets/resources/nombres.csv');
    _processNames(csvData);
  }

// Procesar los nombres del CSV
  static void _processNames(String csvData) {
    final rows = LineSplitter.split(csvData);
    for (final row in rows) {
      final name = row.trim().toUpperCase();
      if (name.isNotEmpty && !_irrelevantWords.contains(name)) {
        _namesSet.add(name);
      }
    }
  }

  // Método para cargar los apellidos desde un archivo CSV
  static Future<void> loadSurnames() async {
    final csvData =
        await rootBundle.loadString('assets/resources/apellidos.csv');
    _processSurnames(csvData);
  }

// Método privado para procesar los apellidos del CSV
  static void _processSurnames(String csvData) {
    final rows = LineSplitter.split(csvData);
    for (final row in rows) {
      final surname = row.trim().toUpperCase();
      if (surname.isNotEmpty && !_irrelevantWords.contains(surname)) {
        _surnamesSet.add(surname);
      }
    }
  }

  // Detectar nombres en un texto dado --------------
  static List<String> detectNames(String text) {
    final cleanText = text.replaceAll(RegExp(r"[^\w\s]"), "").toUpperCase();
    final words = cleanText.split(RegExp(r"\s+"));
    return words.where((word) => _namesSet.contains(word)).toList();
  }

// Detectar apellidos en un texto dado----------------
  static List<String> detectSurnames(String text) {
    final cleanText = text.replaceAll(RegExp(r"[^\w\s]"), "").toUpperCase();
    final words = cleanText.split(RegExp(r"\s+"));
    return words.where((word) => _surnamesSet.contains(word)).toList();
  }
}

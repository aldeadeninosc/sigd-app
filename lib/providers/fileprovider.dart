import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileProvider with ChangeNotifier {
  final String baseUrl = 'https://aldeacristorey.com/api';
  List<dynamic> file = [];
  int totalItems = 0;
  String? token;
  bool expiredToken = false;

  void setToken(String? newToken) {
    token = newToken;
    fetchDocuments();
  }

  // Obtener Documents
  Future<void> fetchDocuments(
      {int? subfolderId,
      String? typeFile,
      bool? dateAsc = false,
      bool? dateDesc = false,
      bool? nameAsc = false,
      bool? nameDesc = false,
      String? q}) async {
    var queryParameters = {
      'subfolder_id': subfolderId?.toString(),
      'type_file': typeFile,
      'date_asc': dateAsc?.toString(),
      'date_desc': dateDesc?.toString(),
      'name_asc': nameAsc?.toString(),
      'name_desc': nameDesc?.toString(),
      'q': q,
    };

    queryParameters.removeWhere((key, value) => value == null);

    final uri = Uri.parse('$baseUrl/documents')
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      expiredToken = false;
      var jsonResponse = json.decode(response.body);
      file = jsonResponse['items'];
      totalItems = jsonResponse['totalCounts'];
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
    }
  }

  // Agregar Document
  Future<void> addDocument(dynamic file, String userId, int subFolderId) async {
    final uri = Uri.parse('$baseUrl/documents');
    var request = http.MultipartRequest('POST', uri)
      ..fields['id_user'] = userId.toString()
      ..fields['id_subfolder'] = subFolderId.toString()
      ..fields['document_name'] = file['name'];

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
          'document_content', file['bytes'] as Uint8List,
          filename: file['name']));
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('document_content', file));
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final response = await request.send();

    if (response.statusCode == 201) {
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = false;
      token = null;
    } else {
      if (kDebugMode) {
        print(await response.stream.bytesToString());
        print(response.reasonPhrase);
      }
    }
    notifyListeners();
  }

  //Agregar Documento movil
  Future<bool> addDocumentM(
      dynamic file, String userId, int subFolderId) async {
    final uri = Uri.parse('$baseUrl/documents');
    var request = http.MultipartRequest('POST', uri)
      ..fields['id_user'] = userId.toString()
      ..fields['id_subfolder'] = subFolderId.toString()
      ..fields['document_name'] = file['name'];

    String filePath = file['path']; // Ruta del archivo
    String newFileName = file['name']; // Nuevo nombre para el archivo

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes(
          'document_content', file['bytes'] as Uint8List,
          filename: file['name']));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'document_content',
        filePath,
        filename: newFileName, // Cambiamos el nombre aquí
      ));
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final response = await request.send();

    if (response.statusCode == 201) {
      notifyListeners();
      return true;
    } else if (response.statusCode == 401) {
      expiredToken = false;
      token = null;
      return false;
    } else {
      if (kDebugMode) {
        print(await response.stream.bytesToString());
        print(response.reasonPhrase);
        return false;
      }
      return false;
    }
  }

  // Actualizar Document
  Future<void> updateDocument(int documentId, String documentName, dynamic file,
      int userId, int subFolderId) async {
    final uri = Uri.parse('$baseUrl/documents/$documentId');

    if (!documentName.contains('.')) {
      documentName = '$documentName.${file['document_type']}';
    }

    var request = http.MultipartRequest('POST', uri)
      ..fields['id_user'] = userId.toString()
      ..fields['id_subfolder'] = subFolderId.toString()
      ..fields['document_name'] = documentName;

    if (kIsWeb) {
      if (file is Map &&
          file.containsKey('bytes') &&
          file.containsKey('name')) {
        request.files.add(http.MultipartFile.fromBytes(
            'document_content', file['bytes'] as Uint8List,
            filename: documentName));
      } else {
        //Uint8List contenido = Uint8List.fromList(utf8.encode(file['document_content']));
        Uint8List contenido = base64.decode(file['document_content']);
        request.files.add(http.MultipartFile.fromBytes(
            'document_content', contenido as Uint8List,
            filename: documentName));
      }
    } else {
      if (file is Map && file.containsKey('path') && file.containsKey('name')) {
        request.files.add(await http.MultipartFile.fromPath(
          'document_content',
          file['path'],
          filename: documentName,
        ));
      } else {
        try {
          String filePath =
              await saveBase64ToFile(file['document_content'], documentName);

          request.files.add(await http.MultipartFile.fromPath(
              'document_content', filePath,
              filename: documentName));
        } catch (e) {
          print('Error al guardar el archivo: $e');
        }

        /*request.files.add(await http.MultipartFile.fromPath(
          'document_content',
          file['document_content'],
          filename: documentName,
        ));*/
      }
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = false;
      token = null;
    }
    notifyListeners();
  }

  Future<String> saveBase64ToFile(String base64Content, String fileName) async {
    // Obtiene el directorio de documentos de la aplicación
    final directory = await getApplicationDocumentsDirectory();

    // Crea la ruta completa del archivo
    final filePath = '${directory.path}/$fileName';

    // Decodifica el contenido base64 y guarda el archivo
    final bytes = base64Decode(base64Content);
    final file = File(filePath);

    // Escribe los bytes en el archivo
    await file.writeAsBytes(bytes);

    // Retorna la ruta del archivo
    return file.path;
  }

  // Eliminar Document
  Future<void> deleteDocument(int documentId) async {
    final uri = Uri.parse('$baseUrl/documents/$documentId');
    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      notifyListeners();
    } else {
      expiredToken = false;
      token = null;
    }

    notifyListeners();
  }

  void handleTokenExpiration() {
    expiredToken = false;
    token = null;
    notifyListeners();
  }

  // Buscar Document
  Future<List<dynamic>> searchDocuments(String document) async {
    final uri = Uri.parse(
        '$baseUrl/search-documents?query=${Uri.encodeComponent(document)}');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':
            'application/json', // Asegúrate de establecer el tipo de contenido
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['items'] ??
          []; // Asumiendo que 'items' contiene el listado de documentos
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
      throw Exception('Token expirado');
    } else if (response.statusCode == 404) {
      notifyListeners();
      throw Exception('No se encontro documento');
    }
    {
      throw Exception('Error al buscar documentos: ${response.reasonPhrase}');
    }
  }

  /* Future<List<dynamic>> searchDocuments(
      String nameChild, String subfolder, String document) async {
    final uri = Uri.parse('$baseUrl/search-documents');
    final body = jsonEncode({
      "child_name": nameChild,
      "subfolder_name": subfolder,
      "document_name": document
    });
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':
            'application/json', // Asegúrate de establecer el tipo de contenido
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse[
          'items']; // Asumiendo que 'items' contiene el listado de documentos
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
      throw Exception('Token expirado');
    } else if (response.statusCode == 404) {
      fetchDocuments(q: document);
      notifyListeners();
      throw Exception('No se encontro documento');
    }
    {
      throw Exception('Error al buscar documentos: ${response.reasonPhrase}');
    }
  }*/
}

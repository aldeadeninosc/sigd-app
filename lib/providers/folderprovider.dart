import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FolderProvider with ChangeNotifier {
  final String baseUrl = 'http://aldeacristorey.com/api';
  List<dynamic> folders = [];
  int totalItems = 0;
  String? token;
  bool expiredToken = false;

  void setToken(String? newToken) {
    token = newToken;
    fetchFolders();
  }

  Future<void> fetchFolders({int? folderId}) async {
    var queryParameters = {'folder_id': folderId?.toString()};
    final uri =
        Uri.parse('$baseUrl/folder').replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      expiredToken = false;
      var jsonResponse = json.decode(response.body);
      folders = jsonResponse['items'];
      totalItems = jsonResponse['totalCounts'];
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
    }
  }

  // Agregar Folder
  Future<void> addFolder(String folderName, int userId) async {
    final uri = Uri.parse('$baseUrl/folder');
    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'folder_name': folderName, 'id_user': userId}));

    if (response.statusCode == 201) {
      expiredToken = false;
      fetchFolders();
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
    }
  }

  // Actualizar Folder
  Future<void> updateFolder(int folderId, String folderName, int userId) async {
    final uri = Uri.parse('$baseUrl/folder/$folderId');
    final response = await http.put(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'folder_name': folderName, 'id_user': userId}));

    if (response.statusCode == 200) {
      expiredToken = false;
      fetchFolders();
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
    }
  }

  // Eliminar Folder
  Future<void> deleteFolder(int folderId) async {
    final uri = Uri.parse('$baseUrl/folder/$folderId');
    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      expiredToken = false;
      folders.removeWhere((folder) => folder['id'] == folderId);
      notifyListeners();
    } else if (response.statusCode == 401) {
      expiredToken = true;
      token = null;
      notifyListeners();
    }
  }

  void handleTokenExpiration() {
    expiredToken = false;
    token = null;
    notifyListeners();
  }
}

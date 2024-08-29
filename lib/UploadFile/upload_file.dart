import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:ocr/Tools/PdfPreviewPage.dart';
import 'package:ocr/providers/auth_provider.dart';
import 'package:ocr/providers/folderprovider.dart';
import 'package:ocr/providers/subfolderprovider.dart';
import 'package:ocr/providers/fileprovider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:universal_html/html.dart' as html;
import 'package:ocr/Tools/util.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'dart:io';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  bool showingSubFolders = false;
  bool showingDocuments = false;
  int? currentFolderId;
  int? currentSubFolderId;
  bool isLoading = false;
  //dynamic selectedFile;
  dynamic selectedFile2;
  bool fileSelected = false;

  String? userType;
  Map<String, String>? user;
  AuthProvider? authProvider;
  FolderProvider? folderProvider;
  SubFolderProvider? subFolderProvider;
  FileProvider? fileProvider;

  String nameDocument = "";
  String? filterOption = 'name_asc';
  String _titulo = "Carpetas";
  String folder_name = "";
  String subfolder_name = "";
  String docm_name = "";

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    folderProvider = Provider.of<FolderProvider>(context, listen: false);
    subFolderProvider = Provider.of<SubFolderProvider>(context, listen: false);
    fileProvider = Provider.of<FileProvider>(context, listen: false);
    folderProvider?.setToken(authProvider!.token);
    subFolderProvider?.setToken(authProvider!.token);
    fileProvider?.setToken(authProvider!.token);
    initializeResources();

    if (!kIsWeb) {
      _requestPermissions();
    }
  }

  void initializeResources() async {
    ////
    setState(() => isLoading = true);
    await _initializeUser();
    await _fetchData();
    setState(() => isLoading = false);
  }

  Future<void> _initializeUser() async {
    await authProvider?.getCurrentUser();
    user = authProvider?.currentUser;
    if (user != null) {
      if (mounted) {
        setState(() {
          userType = user?['user_type'];
        });
      }
      await _fetchData();
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
  }

  Future<void> _fetchData({bool reset = false}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    await folderProvider?.fetchFolders();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    checkTokenExpiration(folderProvider);
  }

  Future _fetchSubFolders(int folderId, {bool reset = false}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    _titulo = folder_name;
    await subFolderProvider?.fetchSubFolders(
        folderId: folderId); // Fetch all subfolders
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    checkTokenExpiration(subFolderProvider);
  }

  Future<void> _fetchDocuments(int subfolderId, {bool reset = false}) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    _titulo = '$folder_name/$subfolder_name';

    String? typeFile;
    bool? dateAsc;
    bool? dateDesc;
    bool? nameAsc;
    bool? nameDesc;

    switch (filterOption) {
      case 'pdf':
      case 'docx':
      case 'png':
      case 'jpg':
      case 'jpeg':
        typeFile = filterOption;
        break;
      case 'date_asc':
        dateAsc = true;
        break;
      case 'date_desc':
        dateDesc = true;
        break;
      case 'name_asc':
        nameAsc = true;
        break;
      case 'name_desc':
        nameDesc = true;
        break;
    }

    await fileProvider?.fetchDocuments(
      subfolderId: subfolderId,
      typeFile: typeFile,
      dateAsc: dateAsc,
      dateDesc: dateDesc,
      nameAsc: nameAsc,
      nameDesc: nameDesc,
      q: null,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    checkTokenExpiration(fileProvider);
  }

  void _updateView({bool resetPage = false}) {
    if (showingDocuments && currentSubFolderId != null) {
      _fetchDocuments(currentSubFolderId!, reset: resetPage);
    } else if (showingSubFolders && currentFolderId != null) {
      _fetchSubFolders(currentFolderId!, reset: resetPage);
    } else {
      _fetchData(reset: resetPage);
    }
  }

  void checkTokenExpiration(dynamic provider) {
    if (provider.expiredToken) {
      provider.handleTokenExpiration();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _requestPermissions() async {
    if (!io.Platform.isAndroid || !io.Platform.isIOS) {
      return;
    }

    var storageStatus = await Permission.storage.request();
    var cameraStatus = await Permission.camera.request();

    if (storageStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color(0xFFFFF3F8),
        content: Text(
            'Permiso de almacenamiento denegado. Por favor, permita el acceso a almacenamiento para continuar.',
            style: TextStyle(color: Color(0xC3000022))),
      ));
    } else if (storageStatus.isPermanentlyDenied) {
      openAppSettings();
    }

    if (cameraStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color(0xFFFFF3F8),
        content: Text(
            'Permiso de cámara denegado. Por favor, permita el acceso a la cámara para continuar.',
            style: TextStyle(color: Color(0xC3000022))),
      ));
    } else if (cameraStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = showingDocuments
        ? fileProvider?.file
        : showingSubFolders
            ? subFolderProvider?.subFolders
            : folderProvider?.folders;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xC3000022),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(children: [
                    if (showingDocuments)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xC3000022),
                        ),
                        onPressed: () {
                          setState(() {
                            showingDocuments = false;
                            currentSubFolderId = null;
                            _titulo = subfolder_name ?? "Subcarpeta";
                          });
                          _fetchSubFolders(currentFolderId!, reset: true);
                        },
                      ),
                    if (showingSubFolders && !showingDocuments)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xC3000022),
                        ),
                        onPressed: () {
                          setState(() {
                            showingSubFolders = false;
                            currentFolderId = null;
                            _titulo = "Carpeta";
                          });
                          _fetchData(reset: true);
                        },
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _titulo,
                      style: const TextStyle(
                          color: AppColors.negro,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  if (showingDocuments) _buildFilterOptions(),
                  const SizedBox(height: 8),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Color(0xC3000022),
                        ))
                      : Expanded(
                          child: buildGridView(items!),
                        ),
                  const SizedBox(height: 8),
                ],
              )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.naranja,
        onPressed: () {
          _showAddItemDialog();
        },
        child: const Icon(Icons.add, color: AppColors.blanco, size: 30.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String getFileExtension(String fileName) {
    List<String> parts = fileName.split('.');
    return parts.isNotEmpty
        ? parts.last
        : ''; // Retorna la última parte si existe
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    String extencion = getFileExtension(photo!.name);
    nameDocument = "$nameDocument.$extencion";

    if (photo != null) {
      Map<String, String> selectedFileMap = {
        'name': nameDocument, // Usar el nuevo nombre del documento
        'path': photo.path, // Ruta del archivo
      };

      bool shouldCrop = await _confirmImage(photo.path);

      if (shouldCrop) {
        dynamic croppedFile = await ImageCropper().cropImage(
          sourcePath: photo.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Recortar Imagen',
            toolbarColor: Color(0xFFFFF3F8),
            toolbarWidgetColor: Color(0xC3000022),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        );

        if (croppedFile != null) {
          selectedFileMap['path'] = croppedFile.path;
        }
      }

      setState(() {
        this.selectedFile2 = selectedFileMap;
        fileSelected = true;
      });
    }
  }

  Future<bool> _confirmImage(String imagePath) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF3F8),
          title: const Text("Confirmar Imagen"),
          content: Image.file(io.File(imagePath)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Recortar",
                  style: TextStyle(color: Color(0xC3000022))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Usar Imagen",
                  style: TextStyle(color: Color(0xC3000022))),
            ),
          ],
        );
      },
    );
  }

  Widget buildGridView(List<dynamic> items) {
    return RefreshIndicator(
      color: AppColors.naranja,
      backgroundColor: const Color(0xC3000022),
      onRefresh: () => _fetchData(reset: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 1 / 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index != items.length) {
            return buildItemCard(items[index]);
          }
          //return _buildAddNewItemCard();
        },
      ),
    );
  }

  Widget buildListView(List<dynamic> items) {
    return RefreshIndicator(
      color: const Color(0xFFFFF3F8),
      backgroundColor: const Color(0xC3000022),
      onRefresh: () => _fetchData(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index != items.length) {
            return buildItemCard(items[index]);
          }
          //return _buildAddNewItemCard();
        },
      ),
    );
  }

  Widget buildItemCard(dynamic item) {
    return InkWell(
      onTap: () async {
        if (!showingSubFolders && item.containsKey('folder_name')) {
          setState(() {
            showingSubFolders = true;
            currentFolderId = item['id'];
            folder_name = item['folder_name'];
          });
          await _fetchSubFolders(item['id'], reset: true);
        } else if (!showingDocuments && item.containsKey('subfolder_name')) {
          setState(() {
            showingDocuments = true;
            currentSubFolderId = item['id'];
            subfolder_name = item['subfolder_name'];
          });
          await _fetchDocuments(item['id']);
        } else if (showingDocuments && item.containsKey('document_name')) {
          _previewDocument(item);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: AppColors.blanco,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getDocumentIcon(item['document_type'] ?? 'folder'),
                  Text(
                    item['folder_name'] ??
                        item['subfolder_name'] ??
                        item['document_name'],
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.negro,
                    ),
                  ),
                  SizedBox(height: 15.0),
                ],
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: PopupMenuButton<String>(
                color: const Color(0xFFFFF3F8),
                onSelected: (value) => _handleItemMenuAction(value, item),
                itemBuilder: (BuildContext context) {
                  List<String> choices = ['Editar', 'Borrar'];
                  if (item.containsKey('document_name')) {
                    choices.add('Descargar');
                  }
                  if (userType == 'Manager') {
                    choices.remove('Editar');
                    choices.remove('Borrar');
                  }
                  return choices.map((String choice) {
                    return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice,
                            style: const TextStyle(color: Color(0xC3000022))));
                  }).toList();
                },
                icon: const Icon(Icons.more_vert, color: Color(0xC3000022)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'pdf':
        return const Image(
          image: AssetImage('assets/images/pdf.png'),
          height: 80,
        );
      case 'png':
        return const Image(
          image: AssetImage('assets/images/png.png'),
          height: 80,
        );
      case 'jpg':
        return const Image(
          image: AssetImage('assets/images/jpg.png'),
          height: 80,
        );
      case 'jpeg':
        return const Image(
          image: AssetImage('assets/images/jpeg.png'),
          height: 80,
        );
      case 'docx':
        return const Image(
          image: AssetImage('assets/images/docx.png'),
          height: 80,
        );
      case 'doc':
        return const Image(
          image: AssetImage('assets/images/doc.png'),
          height: 80,
        );
      case 'xlsx':
        return const Image(
          image: AssetImage('assets/images/xlsx.png'),
          height: 80,
        );
      case 'xls':
        return const Image(
          image: AssetImage('assets/images/xls.png'),
          height: 80,
        );
      default:
        return const Image(
          image: AssetImage('assets/images/carpeta.png'),
          height: 75,
        );
    }
  }

  void _showAddItemDialog() {
    if (showingDocuments) {
      _showAddDocumentDialog();
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            String itemName = "";
            return AlertDialog(
              backgroundColor: AppColors.blanco,
              title: Text(
                  showingSubFolders
                      ? "Añadir nueva subcarpeta"
                      : "Añadir nueva carpeta",
                  style: const TextStyle(color: AppColors.negro)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nombre:"),
                  const SizedBox(height: 8),
                  TextField(
                      onChanged: (value) => itemName = value,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Nombre",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )),
                ],
              ),
              actions: [
                /*ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar",
                      style: TextStyle(color: Color(0xC3000022))),
                ),*/
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (itemName.isNotEmpty) {
                        if (showingSubFolders) {
                          await subFolderProvider?.addSubFolder(
                              itemName, currentFolderId!);
                        } else {
                          await folderProvider?.addFolder(itemName, 1);
                        }

                        if (mounted) {
                          Navigator.of(context).pop();
                          _updateView(resetPage: true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranja,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Bordes redondeados
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32), // Aumenta el padding
                        minimumSize: const Size(200, 50)),
                    child: const Text("Crear",
                        style: TextStyle(color: AppColors.blanco)),
                  ),
                ),
              ],
            );
          });
    }
  }

  Future<dynamic> _selectFile() async {
    if (nameDocument != "") {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          if (result.files.first.bytes != null) {
            return {
              'bytes': result.files.first.bytes,
              'name': '$nameDocument.${result.files.first.extension}',
              //'type': result.files.first.extension,
            };
          }
        } else {
          if (result.files.single.path != null) {
            return {
              //io.File(result.files.single.path!)
              'path': result.files.single.path,
              'name': '$nameDocument.${result.files.first.extension}',
              //'type': result.files.first.extension,
            };
          }
        }
        fileSelected = true;
      }
    } else {
      _showSnackBar(
          "Ingresar primero el nombre del documento", AppColors.mensajError);
    }
    return null;
  }

  Future<dynamic> _selectFileEditar(nameController) async {
    if (nameController.text != null && nameController.text!.isNotEmpty) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        String fileName = nameController.text;
        if (kIsWeb) {
          if (!fileName.contains('.')) {
            return {
              'bytes': result.files.first.bytes,
              'name': '${nameController.text}.${result.files.first.extension}',
            };
          } else {
            return {
              'bytes': result.files.first.bytes,
              'name': '${nameController.text}',
            };
          }
        } else {
          if (result.files.single.path != null) {
            if (!fileName.contains('.')) {
              return {
                //io.File(result.files.single.path!)
                'path': result.files.single.path,
                'name': nameController.text,
              };
            } else {
              return {
                'path': result.files.first.path,
                'name':
                    '${nameController.text}.${result.files.first.extension}',
              };
            }
          }
        }
        fileSelected = true;
      }
    } else {
      _showSnackBar(
          "Ingresar primero el nombre del documento", AppColors.mensajError);
    }
    return null;
  }

  void _showAddDocumentDialog() async {
    final userId = user?['id'];
    bool isLoadFile = false;

    if (userId == null) {
      _showSnackBar(
          'No se pudo obtener el usuario actual', AppColors.mensajError);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(
            backgroundColor: AppColors.blanco,
            title: const Text("Añadir nuevo documento",
                style: TextStyle(color: AppColors.negro)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nombre",
                ),
                const SizedBox(height: 8),
                _buildDocumentNameField(),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  selectedFile2 = await _selectFile();
                  if (selectedFile2 != null) {
                    setState(() {
                      fileSelected = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      fileSelected ? AppColors.azul : AppColors.naranja,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                    fileSelected
                        ? "Archivo Seleccionado"
                        : "Seleccionar Archivo",
                    style: const TextStyle(color: AppColors.blanco)),
              ),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () {
                    _takePhoto();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: AppColors.blanco,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.azul,
                    size: 20,
                  ),
                ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Subir",
                      style: TextStyle(color: AppColors.blanco)),
                  onPressed: () async {
                    if (nameDocument.isNotEmpty) {
                      if (selectedFile2 != null) {
                        if (kIsWeb) {
                          await fileProvider?.addDocument(
                              selectedFile2, userId, currentSubFolderId!);
                          if (mounted) {
                            setState(() {
                              selectedFile2 = null;
                              isLoadFile = false;
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: AppColors.mensajExito,
                                content: Text('Documento subido correctamente',
                                    style: TextStyle(color: AppColors.negro))),
                          );
                          setState(() {
                            selectedFile2 = null;
                            fileSelected = false;
                            nameDocument = "";
                          });
                          Navigator.of(context).pop();
                          await _fetchDocuments(currentSubFolderId!);
                        } else {
                          bool? uploadSuccess =
                              await fileProvider?.addDocumentM(
                                  selectedFile2, userId, currentSubFolderId!);
                          if (uploadSuccess == true) {
                            if (mounted) {
                              setState(() {
                                selectedFile2 = null;
                                isLoadFile = false;
                              });
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: AppColors.mensajExito,
                                  content: Text(
                                      'Documento subido correctamente',
                                      style:
                                          TextStyle(color: AppColors.negro))),
                            );
                            setState(() {
                              selectedFile2 = null;
                              fileSelected = false;
                              nameDocument = "";
                            });
                            Navigator.of(context).pop();
                            await _fetchDocuments(currentSubFolderId!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.mensajError,
                                content: Text(
                                  'Error al subir el documento. Inténtalo de nuevo.',
                                  style: TextStyle(color: AppColors.negro),
                                ),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: AppColors.mensajError,
                              content: Text('Por favor seleccione un archivo',
                                  style: TextStyle(color: AppColors.negro))),
                        );
                      }
                    } else {
                      _showSnackBar('Por favor ingrese el nombre del archivo',
                          AppColors.mensajError);
                      return;
                    }
                    nameDocument = "";
                  }),
            ],
          );
        });
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content:
            Text(message, style: const TextStyle(color: Color(0xC3000022))),
      ),
    );
  }

  Widget _buildDocumentNameField() {
    return TextField(
      onChanged: (value) => nameDocument = value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.blanco,
        hintText: "Ingresar nombre del archivo",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _handleItemMenuAction(String choice, dynamic item) {
    if (choice == 'Editar' && userType != 'Manager') {
      _showEditItemDialog(item);
    } else if (choice == 'Borrar' && userType != 'Manager') {
      _showDeleteConfirmationDialog(item['id']);
    } else if (choice == 'Descargar') {
      _downloadDocument(item);
    }
  }

  void _showEditItemDialog(dynamic item) {
    if (showingDocuments) {
      _showEditDocumentDialog(item);
    } else {
      String itemName = item['folder_name'] ?? item['subfolder_name'] ?? '';
      TextEditingController nameController =
          TextEditingController(text: itemName);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.blanco,
              title: Text(
                  showingSubFolders ? "Editar Subcarpeta" : "Editar Carpeta",
                  style: const TextStyle(color: AppColors.negro)),
              content: TextField(
                controller: nameController,
                onChanged: (value) => itemName = value,
                decoration: const InputDecoration(hintText: "Nombre"),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (itemName.isNotEmpty) {
                      try {
                        if (showingSubFolders) {
                          await subFolderProvider?.updateSubFolder(
                              item['id'], itemName, currentFolderId!);
                        } else {
                          await folderProvider?.updateFolder(
                              item['id'], itemName, 1);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: AppColors.mensajExito,
                                content: Text(
                                  'Actualizado correctamente',
                                  style: TextStyle(color: Color(0xC3000022)),
                                )),
                          );
                          Navigator.of(context).pop();
                          _updateView(resetPage: true);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.mensajError,
                              content: Text(
                                'Error al actualizar',
                                style: TextStyle(color: Color(0xC3000022)),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Guardar",
                      style: TextStyle(color: AppColors.blanco)),
                ),
              ],
            );
          });
        },
      );
    }
  }

  void _showEditDocumentDialog(dynamic item) async {
    final documentId = item['id'];
    final userId = user?['id'];
    selectedFile2 = item;
    bool isLoadFile = true;
    String currentDocumentName = item['document_name'];
    TextEditingController nameController =
        TextEditingController(text: currentDocumentName);

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Color(0xFFFFF3F8),
            content: Text('No se pudo obtener el usuario actual',
                style: TextStyle(color: Color(0xC3000022)))),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF3F8),
              title: const Text("Actualizar Documento",
                  style: TextStyle(color: AppColors.negro)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Nombre",
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ingrese el nuevo nombre del documento",
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      selectedFile2 = await _selectFileEditar(nameController);
                      setState(() {
                        fileSelected = selectedFile2 != null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          fileSelected ? AppColors.azul : AppColors.naranja,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Seleccionar Archivo",
                        style: TextStyle(color: AppColors.blanco)),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final int parsedUserId = int.parse(userId);
                    if (nameController.text.isNotEmpty) {
                      isLoadFile = true;
                      try {
                        if (selectedFile2 != null) {
                          if (kIsWeb) {
                            await fileProvider?.updateDocument(
                              documentId,
                              nameController.text,
                              selectedFile2,
                              parsedUserId,
                              currentSubFolderId!,
                            );
                          } else {
                            await fileProvider?.updateDocument(
                              documentId,
                              nameController.text,
                              selectedFile2,
                              parsedUserId,
                              currentSubFolderId!,
                            );
                          }
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: AppColors.mensajExito,
                                content: Text(
                                  'Documento actualizado correctamente',
                                  style: TextStyle(color: Color(0xC3000022)),
                                )),
                          );
                          Navigator.of(context).pop();
                          await _fetchDocuments(currentSubFolderId!);
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error al actualizar documento: $e');
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: AppColors.mensajError,
                                content: Text(
                                  'Error al actualizar el documento',
                                  style: TextStyle(color: Color(0xC3000022)),
                                )),
                          );
                          setState(() {
                            isLoadFile = false;
                          });
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Color(0xFFFFF3F8),
                            content: Text(
                              'Por favor seleccione un archivo',
                              style: TextStyle(color: Color(0xC3000022)),
                            )),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Actualizar",
                    style: TextStyle(color: AppColors.blanco),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF3F8),
          title: const Text(
            "Confirmar Eliminación",
            style: TextStyle(color: Color(0xC3000022)),
          ),
          content: const Text(
            "¿Está seguro de que quiere borrar esta carpeta/subcarpeta/documento?",
            style: TextStyle(color: Color(0xC3000022)),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (showingDocuments) {
                  await fileProvider?.deleteDocument(itemId);
                  _updateView(resetPage: true);
                } else if (showingSubFolders) {
                  await subFolderProvider?.deleteSubFolder(
                      itemId, currentFolderId!);
                  _updateView(resetPage: true);
                } else {
                  await folderProvider?.deleteFolder(itemId);
                  _updateView(resetPage: true);
                }
                Navigator.of(context).pop();
                _updateView(resetPage: true);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Bordes redondeados
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 32), // Aumenta el padding
                  minimumSize: const Size(200, 50)),
              child: const Text("Borrar",
                  style: TextStyle(color: AppColors.blanco)),
            ),
          ],
        );
      },
    );
  }

  void _previewDocument(dynamic document) {
    String documentType = document['document_type'];
    String documentContentBase64 = document['document_content'];

    switch (documentType) {
      case 'pdf':
        _showPdfPreview(documentContentBase64);
        break;
      case 'png':
      case 'jpeg':
      case 'jpg':
        _showImagePreview(documentContentBase64);
        break;
      case 'docx':
      case 'xlsx':
        _showOfficePreview(documentContentBase64, documentType);
        break;
      default:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.blanco,
            title: const Text(
              'Vista previa no disponible',
              style: TextStyle(color: Color(0xC30050022)),
            ),
            content: const Text(
              'Vista previa no compatible para este tipo de documento',
              style: TextStyle(color: Color(0xC3000022)),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: AppColors.negro),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32), // Aumenta el padding
                    minimumSize: const Size(200, 50)),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _showPdfPreview(String documentContentBase64) async {
    try {
      Uint8List bytes = base64Decode(documentContentBase64);
      String path = '';

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        path = '${directory.path}/document.pdf';
        File file = File(path);
        await file.writeAsBytes(bytes);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: kIsWeb
                    ? PdfPreviewPage(bytes: bytes)
                    : SfPdfViewer.memory(bytes),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cerrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xC3000022),
          title: const Text(
            'Error',
            style: TextStyle(color: Color(0xC3000022)),
          ),
          content: const Text(
            'No se pudo mostrar la vista previa del PDF.',
            style: TextStyle(color: Color(0xC3000022)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xC3000022)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showImagePreview(String documentContentBase64) {
    try {
      Uint8List bytes = base64Decode(documentContentBase64.split(',').last);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Image.memory(bytes),
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFF3F8),
          title: const Text(
            'Error',
            style: TextStyle(color: Color(0xC3000022)),
          ),
          content: const Text(
            'No se pudo mostrar la vista previa de la imagen.',
            style: TextStyle(color: Color(0xC3000022)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xC3000022)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void _showOfficePreview(String documentContentBase64, String documentType) {
    Uint8List bytes = base64Decode(documentContentBase64);
    String fileName = 'document.$documentType';

    if (kIsWeb) {
      final blob = html.Blob([
        bytes
      ], 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      _saveAndOpenFile(bytes, fileName);
    }
  }

  Future<void> _saveAndOpenFile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = io.File(filePath);

    await file.writeAsBytes(bytes);
    OpenFile.open(filePath);
  }

  Future<void> _downloadDocument(dynamic document) async {
    String documentName = document['document_name'];
    String documentType = document['document_type'];
    String documentContentBase64 = document['document_content'];
    Uint8List bytes = base64Decode(documentContentBase64.split(',').last);

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "$documentName.$documentType")
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Color(0xFFFFF3F8),
            content: Text(
              'Archivo descargado correctamente',
              style: TextStyle(color: Color(0xC3000022)),
            )),
      );
    } else {
      if (await Permission.storage.request().isGranted) {
        io.Directory? directory;
        if (io.Platform.isAndroid) {
          directory = io.Directory('/storage/emulated/0/Download');
        } else if (io.Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          String filePath =
              path.join(directory.path, '$documentName.$documentType');
          final file = await io.File(filePath).writeAsBytes(bytes);
          OpenFile.open(file.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Color(0xFFFFF3F8),
                content: Text(
                  'Archivo descargado correctamente',
                  style: TextStyle(color: Color(0xC3000022)),
                )),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFFFFF3F8),
              title: const Text(
                'Error',
                style: TextStyle(color: Color(0xC3000022)),
              ),
              content: const Text(
                'No se pudo acceder a la carpeta de Descargas.',
                style: TextStyle(color: Color(0xC3000022)),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: Color(0xC3000022)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFF3F8),
            title: const Text(
              'Permiso Denegado',
              style: TextStyle(color: Color(0xC3000022)),
            ),
            content: const Text(
              'No se puede guardar el archivo sin permisos de almacenamiento.',
              style: TextStyle(color: Color(0xC3000022)),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Color(0xC3000022)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            dropdownColor: const Color(0xFFFFF3F8),
            hint: const Text(
              "Ordenar por",
              style: TextStyle(color: Color(0xC3000022)),
            ),
            value: filterOption,
            onChanged: (String? newValue) {
              setState(() {
                filterOption = newValue;
              });
              _fetchDocuments(currentSubFolderId!);
            },
            items: <String>[
              'name_asc',
              'name_desc',
              'date_asc',
              'date_desc',
              'pdf',
              'docx',
              'png',
              'jpg',
              'jpeg'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  _getFilterText(value),
                  style: const TextStyle(color: Color(0xC3000022)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getFilterText(String value) {
    switch (value) {
      case 'name_asc':
        return 'Nombre Ascendente';
      case 'name_desc':
        return 'Nombre Descendente';
      case 'date_asc':
        return 'Fecha Ascendente';
      case 'date_desc':
        return 'Fecha Descendente';
      case 'pdf':
        return 'PDF';
      case 'docx':
        return 'DOCX';
      case 'png':
        return 'PNG';
      case 'jpg':
        return 'JPG';
      case 'jpeg':
        return 'JPEG';
      default:
        return value;
    }
  }
}

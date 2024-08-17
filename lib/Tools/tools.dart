import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ocr/Tools/util.dart';
import 'package:ocr/providers/convert_provider.dart';
import 'package:ocr/providers/ocr_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io' as io;

class Tools extends StatelessWidget {
  const Tools({super.key});

  @override
  Widget build(BuildContext context) {
    String variableFechaCaducacion = "30/12/2024";
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Herramientas",
              style: TextStyle(
                  color: AppColors.negro,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            /* const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _showAPIDialog(context); // Función para mostrar el diálogo
              },
              child: Card(
                color: AppColors.blanco,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "API",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Caduca el: $variableFechaCaducacion",
                              style: TextStyle(color: AppColors.negro),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.settings,
                        color: AppColors.azul,
                        size: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),*/
            Consumer<ConversionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                      child: Column(
                    children: [
                      const CircularProgressIndicator(
                        backgroundColor: AppColors.blanco,
                      ),
                      Text(provider.message),
                    ],
                  ));
                }
                return buildConversionButtons(provider);
              },
            ),
            const SizedBox(height: 10),
            Consumer<OCRConversionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                      child: Column(
                    children: [
                      const CircularProgressIndicator(
                        backgroundColor: Color(0xC3000022),
                      ),
                      Text(provider.message),
                    ],
                  ));
                }
                return buildOCRButtons(provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConversionButtons(ConversionProvider provider) {
    final List<Map<String, dynamic>> conversionOptions = [
      {
        'icon': Icons.file_copy,
        'imag': 'assets/images/pdfTOword.png',
        'text': 'Convertir PDF a Word',
        'format': 'docx',
        'color': AppColors.azul
      },
      {
        'icon': Icons.grid_on,
        'imag': 'assets/images/pdfTOxls.png',
        'text': 'Convertir PDF a Excel',
        'format': 'xlsx',
        'color': AppColors.verde
      },
      {
        'icon': Icons.slideshow,
        'imag': 'assets/images/pdfTOppx.png',
        'text': 'Convertir PDF a PowerPoint',
        'format': 'pptx',
        'color': AppColors.rojo
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1 / 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: conversionOptions.length,
      itemBuilder: (context, index) {
        var item = conversionOptions[index];
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blanco,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () async {
            var selectedFile = await _selectFile();
            if (selectedFile != null) {
              if (kIsWeb) {
                provider.convertFile(selectedFile, item['format']);
              } else {
                provider.convertFile(
                    (selectedFile as io.File).path, item['format']);
              }
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item['imag'], // Usar Image.asset para mostrar la imagen
                width: 90, // Ancho de la imagen
                height: 90, // Color si es necesario
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  item['text'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildOCRButtons(OCRConversionProvider ocrProvider) {
    final List<Map<String, dynamic>> ocrOptions = [
      {
        'imag': 'assets/images/imgTOword.png',
        'text': 'Convertir Foto a Texto (Word)',
        'format': 'docx',
        'color': AppColors.azul
      },
      {
        'imag': 'assets/images/imgTOexls.png',
        'text': 'Convertir Foto a Texto (Excel)',
        'format': 'xlsx',
        'color': AppColors.verde
      },
      {
        'imag': 'assets/images/imgTOpdf.png',
        'text': 'Convertir Foto a Texto (PDF)',
        'format': 'pptx',
        'color': AppColors.rojo
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1 / 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: ocrOptions.length,
      itemBuilder: (context, index) {
        var item = ocrOptions[index];
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blanco,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () => !kIsWeb
              ? _takePhotoAndConvert(ocrProvider, item['format'], context)
              : _takePhotoandConvertFile(ocrProvider, item['format']),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                item['imag'], // Usar Image.asset para mostrar la imagen
                width: 90, // Ancho de la imagen
                height: 90, // Color si es necesario
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  item['text'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhotoandConvertFile(
      OCRConversionProvider ocrProvider, String extensionFile) async {
    var selectedFile = await _selectFile(isOCR: true);
    if (selectedFile != null) {
      ocrProvider.performOCR(selectedFile, extensionFile);
    }
  }

  Future<dynamic> _selectFile({bool isOCR = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: !isOCR ? ['pdf'] : ['png', 'jpeg', 'jpg'],
    );
    if (result != null) {
      if (kIsWeb) {
        if (result.files.first.bytes != null) {
          return {
            'bytes': result.files.first.bytes,
            'name': result.files.first.name,
          };
        }
      } else {
        if (result.files.single.path != null) {
          return io.File(result.files.single.path!);
        }
      }
    }
    return null;
  }

  Future<void> _takePhotoAndConvert(OCRConversionProvider ocrProvider,
      String format, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
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
        try {
          await ocrProvider.performOCR(croppedFile.path, format);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    }
  }
}

void _showAPIDialog(BuildContext context) {
  String apiName = '';
  String apiDetails = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Detalles del API"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nombre de la API"),
            TextField(
              onChanged: (value) {
                apiName = value;
              },
              decoration: InputDecoration(hintText: "Ingrese el nombre"),
            ),
            const SizedBox(height: 10),
            const Text("Detalles de la API"),
            TextField(
              onChanged: (value) {
                apiDetails = value;
              },
              decoration: InputDecoration(hintText: "Ingrese detalles"),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Aquí puedes manejar la lógica para guardar los datos
                  Navigator.of(context).pop(); // Cerrar el diálogo
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
          ),
        ],
      );
    },
  );
}

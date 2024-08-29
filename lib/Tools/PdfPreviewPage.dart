import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:html' as html;

class PdfPreviewPage extends StatelessWidget {
  final Uint8List bytes;

  const PdfPreviewPage({Key? key, required this.bytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear un Blob y un enlace para descargar el PDF
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Haz clic en el botón para descargar el PDF.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Descargar el PDF
            final anchor = html.AnchorElement(href: url)
              ..setAttribute('download', 'document.pdf')
              ..click();
            html.Url.revokeObjectUrl(
                url); // Liberar la URL después de la descarga
          },
          child: const Text('Descargar PDF'),
        ),
      ],
    );
  }
}

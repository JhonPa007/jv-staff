import 'dart:io';
import 'package:flutter/foundation.dart'; // Necesario para kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadEvidenceScreen extends StatefulWidget {
  const UploadEvidenceScreen({super.key});

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  XFile? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // En Web esto abre el explorador de archivos, en Móvil la galería
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _handleUpload() async {
    if (_image == null) return;
    
    setState(() => _isUploading = true);

    // SIMULACIÓN DE SUBIDA (Para evitar errores de CORS/Backend por ahora)
    // Aquí es donde normalmente enviarías el archivo a tu servidor Python.
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Retornamos una URL de ejemplo para que el Dashboard pueda mostrar algo
      // (En un caso real, el servidor te devolvería la URL de la imagen guardada)
      const fakeUrl = "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=1000&auto=format&fit=crop";
      
      Navigator.pop(context, fakeUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Subir Evidencia'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 60, color: Color(0xFFD4AF37)),
                          const SizedBox(height: 20),
                          const Text("Toca para seleccionar foto", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Seleccionar de Galería"),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            // SOLUCIÓN MÁGICA: En Web usamos NetworkImage con la ruta blob
                            ? Image.network(
                                _image!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            // En Móvil usamos FileImage
                            : Image.file(
                                File(_image!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Botón de Confirmar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_image != null && !_isUploading) ? _handleUpload : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey[800],
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)),
                          SizedBox(width: 15),
                          Text("Subiendo..."),
                        ],
                      )
                    : const Text(
                        "CONFIRMAR EVIDENCIA",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

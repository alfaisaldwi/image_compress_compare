import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FilePickerDemo(),
    );
  }
}

class FilePickerDemo extends StatefulWidget {
  const FilePickerDemo({super.key});

  @override
  _FilePickerDemoState createState() => _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  File? _originalFile;
  File? _compressedFile;

  Future<void> _pickAndCompressFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      dialogTitle: 'Title',
      allowCompression: true,
      allowMultiple: false,
      onFileLoading: (p0) => FilePickerStatus.values,
      allowedExtensions: ['jpg', 'png'],
      lockParentWindow: true,
    );

    if (result == null) {
      return;
    }

    File originalFile = File(result.files.first.path!);
    int sizeInBytes = originalFile.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb > 10) {
      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text(
                'The file you are trying to upload is too large. Please ensure your file size is below 10MB.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final compressedFilePath =
        '${tempDir.path}/compressed_${result.files.first.name}';

    var resultCompress = await FlutterImageCompress.compressAndGetFile(
      originalFile.path,
      compressedFilePath,
      quality: 20,
      minWidth: 800,
      minHeight: 600,
    );

    setState(() {
      _originalFile = originalFile;
      _compressedFile = resultCompress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compress Compare'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _pickAndCompressFile,
                child: const Text('Pick and Compress File'),
              ),
              const SizedBox(height: 20),
              _originalFile != null
                  ? Column(
                      children: [
                        const Text('Original File'),
                        Image.file(_originalFile!),
                        Text(
                            'Size: ${(_originalFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB'),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),
              _compressedFile != null
                  ? Column(
                      children: [
                        const Text('Compressed File'),
                        Image.file(_compressedFile!),
                        Text(
                            'Size: ${(_compressedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB'),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class TextScreen extends StatefulWidget {
  final Book book;

  const TextScreen({super.key, required this.book});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final pdfUrl = widget.book.pdfUrl?.trim();
      if (pdfUrl == null || pdfUrl.isEmpty) {
        await _loadAssetPdf(); // Загружаем из assets
      } else {
        await _downloadPdfFromUrl(pdfUrl); // Загружаем с интернета
      }
    } catch (e) {
      print('Ошибка: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAssetPdf() async {
    final bytes = await rootBundle.load('pdfs/test.pdf');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/test.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    localPath = file.path;
  }

  Future<void> _downloadPdfFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.book.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      localPath = file.path;
    } else {
      throw Exception('Не удалось загрузить PDF с $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (localPath == null) {
      return const Scaffold(
        body: Center(child: Text('Ошибка при загрузке PDF')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: PDFView(
        filePath: localPath!,
        autoSpacing: true,
        enableSwipe: true,
        swipeHorizontal: false,
        pageSnap: true,
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/book.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../services/local_storage_service.dart';

class TextScreen extends StatefulWidget {
  final Book book;

  const TextScreen({super.key, required this.book});

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  String? localPath;
  bool isLoading = true;
  bool isOffline = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkConnectivityAndLoadPdf();
  }

  Future<void> _checkConnectivityAndLoadPdf() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final connectivity = await Connectivity().checkConnectivity();
      setState(() {
        isOffline = connectivity == ConnectivityResult.none;
      });

      await _loadPdf();
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context).errorLoadingPdf(e.toString());
        isLoading = false;
      });
    }
  }

  Future<void> _loadPdf() async {
    try {
      // Check for cached PDF
      localPath = await LocalStorageService.getCachedPdfPath(widget.book.title);
      if (localPath != null && File(localPath!).existsSync()) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (isOffline) {
        // Try asset PDF as fallback
        await _loadAssetPdf();
        return;
      }

      // Download and cache PDF
      final pdfUrl = widget.book.pdfUrl?.trim();
      if (pdfUrl == null || pdfUrl.isEmpty) {
        await _loadAssetPdf();
      } else {
        localPath = await LocalStorageService.cachePdf(pdfUrl, widget.book.title);
        if (localPath == null) {
          throw Exception('Failed to download PDF from $pdfUrl');
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context).errorLoadingPdf(e.toString());
        isLoading = false;
      });
    }
  }

  Future<void> _loadAssetPdf() async {
    final bytes = await rootBundle.load('pdfs/test.pdf');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/pdfs/test.pdf');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes.buffer.asUint8List());
    localPath = file.path;
    await LocalStorageService.cachePdf('pdfs/test.pdf', widget.book.title);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final settings = Provider.of<SettingsProvider>(context);

    // Apply font size as a scale factor
    final scaleFactor = settings.fontSize == 'small'
        ? 0.8
        : settings.fontSize == 'medium'
        ? 1.0
        : 1.2;

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (errorMessage != null || localPath == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            widget.book.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppTextStyles.albraFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: theme.colorScheme.background,
        ),
        body: Center(
          child: Text(
            errorMessage ?? loc.errorLoadingPdf('Unknown error'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
              fontFamily: AppTextStyles.albraFontFamily,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: AppTextStyles.albraFontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: theme.colorScheme.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Transform.scale(
            scale: scaleFactor,
            child: PDFView(
              filePath: localPath!,
              autoSpacing: true,
              enableSwipe: true,
              swipeHorizontal: false,
              pageSnap: true,
            ),
          ),
          if (isOffline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: theme.colorScheme.error.withOpacity(0.9),
                padding: const EdgeInsets.all(8),
                child: Text(
                  loc.offlineMode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/book.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';
import '../services/local_storage_service.dart';
import '../services/api_servive.dart';

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
  int currentPage = 0;
  int totalPages = 0;
  bool hasProgress = false;
  PDFViewController? pdfController;

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
      await _loadProgress();
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context).errorLoadingPdf(e.toString());
        isLoading = false;
      });
    }
  }

  Future<void> _loadPdf() async {
    try {
      localPath = await LocalStorageService.getCachedPdfPath(widget.book.title);
      if (localPath != null && File(localPath!).existsSync()) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (isOffline) {
        throw Exception('No cached PDF available in offline mode');
      }

      final pdfUrl = widget.book.pdfUrl?.trim();
      if (pdfUrl == null || pdfUrl.isEmpty) {
        throw Exception('No PDF URL provided for this book');
      }

      localPath = await LocalStorageService.cachePdf(pdfUrl, widget.book.title);
      if (localPath == null) {
        throw Exception('Failed to download PDF from $pdfUrl');
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

  Future<void> _loadProgress() async {
    try {
      // Prioritize progress map
      final progress = await LocalStorageService.getProgress();
      if (progress.containsKey(widget.book.id) && (progress[widget.book.id] ?? 0) > 0) {
        setState(() {
          currentPage = progress[widget.book.id] ?? 0;
          hasProgress = true;
        });
        return;
      }

      // Fallback to book object
      final book = await LocalStorageService.getBook(widget.book.id);
      if (book != null && book.progressPage != null && book.progressPage! > 0) {
        setState(() {
          currentPage = book.progressPage!;
          hasProgress = true;
        });
        return;
      }

      if (isOffline) {
        setState(() {
          currentPage = 1;
          hasProgress = true;
        });
        return;
      }

      // Try server progress
      try {
        final userProfile = await ApiService.getUserProfile();
        final serverProgress = userProfile['progress'] as Map<String, int>?;
        final page = serverProgress != null && serverProgress.containsKey(widget.book.id)
            ? serverProgress[widget.book.id] ?? 1
            : 1;
        final updatedBook = widget.book.copyWith(progressPage: page);
        await LocalStorageService.updateBook(updatedBook);
        await LocalStorageService.saveProgress({widget.book.id: page});
        setState(() {
          currentPage = page;
          hasProgress = true;
        });
      } catch (e) {
        print('⚠️ Error fetching server progress: $e');
        setState(() {
          currentPage = 1;
          hasProgress = true;
        });
      }
    } catch (e) {
      print('⚠️ Error loading progress: $e');
      setState(() {
        currentPage = 1;
        hasProgress = true;
      });
    }
  }

  Future<void> _saveProgress() async {
    try {
      if (currentPage <= 0) return; // Don't save invalid progress

      // Save to book object
      final updatedBook = widget.book.copyWith(progressPage: currentPage);
      await LocalStorageService.updateBook(updatedBook);

      // Save to progress map
      final progress = await LocalStorageService.getProgress();
      progress[widget.book.id] = currentPage;
      await LocalStorageService.saveProgress(progress);

      if (!isOffline) {
        try {
          await ApiService.updateProgress(widget.book.id, currentPage);
          print('📄 Progress saved: page $currentPage for book ${widget.book.id}');
        } catch (e) {
          print('⚠️ Server error updating progress (saved locally): $e');
          // Mark book as unsynced for later sync
          final unsyncedBook = updatedBook.copyWith(isSynced: false);
          await LocalStorageService.updateBook(unsyncedBook);
        }
      } else {
        // Mark book as unsynced when offline
        final unsyncedBook = updatedBook.copyWith(isSynced: false);
        await LocalStorageService.updateBook(unsyncedBook);
      }
    } catch (e) {
      print('⚠️ Error saving progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorSavingProgress(e.toString()),
            style: TextStyle(
              fontFamily: AppTextStyles.albraGroteskFontFamily,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _updateProgress(int positionSec) async {
    try {
      final success = await ApiService.updateProgress(widget.book.id, positionSec);
      if (!success) {
        throw Exception('Failed to update progress');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _saveProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final settings = Provider.of<SettingsProvider>(context);

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
          onPressed: () {
            _saveProgress();
            Navigator.pop(context);
          },
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
              defaultPage: hasProgress ? currentPage : 1,
              onViewCreated: (controller) {
                pdfController = controller;
              },
              onPageChanged: (page, total) {
                setState(() {
                  currentPage = page ?? 1;
                  totalPages = total ?? 1;
                });
                _saveProgress();
              },
              onError: (error) {
                setState(() {
                  errorMessage = loc.errorLoadingPdf(error.toString());
                });
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = loc.errorLoadingPdf(error.toString());
                });
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
                    onPressed: () async {
                      if (currentPage > 1) {
                        await pdfController?.setPage(currentPage - 1);
                      }
                    },
                  ),
                  Text(
                    loc.pageXofY(currentPage, totalPages),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: AppTextStyles.albraGroteskFontFamily,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onSurface),
                    onPressed: () async {
                      if (currentPage < totalPages) {
                        await pdfController?.setPage(currentPage + 1);
                      }
                    },
                  ),
                ],
              ),
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
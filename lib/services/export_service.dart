import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for exporting and sharing audio files.
class ExportService {
  ExportService._();

  /// Share an audio file using the system share sheet.
  static Future<void> shareAudioFile(String filePath, {String? text}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $filePath');
    }

    await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
      subject: 'Eleven Studio - Audio Export',
    );
  }

  /// Save an audio file to the device's downloads/documents directory.
  static Future<String> saveAudioFile(String sourcePath, String fileName) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file not found: $sourcePath');
    }

    // Try to get external storage directory (Downloads on Android)
    Directory? targetDir;
    try {
      targetDir = await getExternalStorageDirectory();
    } catch (_) {
      // Fallback to app documents directory
      targetDir = await getApplicationDocumentsDirectory();
    }

    if (targetDir == null) {
      throw Exception('Could not access storage directory');
    }

    // Create Eleven Studio subdirectory
    final exportDir = Directory('${targetDir.path}/ElevenStudio');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    // Copy file with timestamp to avoid overwrites
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = sourcePath.split('.').last;
    final destPath = '${exportDir.path}/${fileName}_$timestamp.$ext';
    await sourceFile.copy(destPath);

    return destPath;
  }

  /// Get the file extension from a path.
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Check if the file is a supported audio format.
  static bool isSupportedAudioFormat(String filePath) {
    final ext = getFileExtension(filePath);
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext);
  }
}

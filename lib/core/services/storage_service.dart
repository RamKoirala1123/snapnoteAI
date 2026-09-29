import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService instance = StorageService._internal();
  static const _uuid = Uuid();

  StorageService._internal();

  Future<Directory> getAppDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDocDir.path, 'SnapNoteAI'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> getScreenshotsDirectory() async {
    final appDir = await getAppDirectory();
    final screenshotsDir = Directory(p.join(appDir.path, 'screenshots'));
    if (!await screenshotsDir.exists()) {
      await screenshotsDir.create(recursive: true);
    }
    return screenshotsDir;
  }

  /// Save raw bytes as a new screenshot image file and return the saved absolute path
  Future<String> saveScreenshotBytes(Uint8List bytes, {String extension = 'png'}) async {
    final screenshotsDir = await getScreenshotsDirectory();
    final filename = 'snap_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}.$extension';
    final filePath = p.join(screenshotsDir.path, filename);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Copy an existing file (e.g. from file picker import) into local app storage
  Future<String> importImageFile(File sourceFile) async {
    final bytes = await sourceFile.readAsBytes();
    final ext = p.extension(sourceFile.path).replaceAll('.', '');
    return await saveScreenshotBytes(bytes, extension: ext.isEmpty ? 'png' : ext);
  }

  /// Delete a stored screenshot file
  Future<void> deleteImageFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

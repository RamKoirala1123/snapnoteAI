import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../database/database_helper.dart';
import '../models/capture_item.dart';
import 'storage_service.dart';

class ExportImportService {
  static final ExportImportService instance = ExportImportService._internal();

  ExportImportService._internal();

  /// Export all captures as a single JSON file
  Future<String?> exportToJson() async {
    final captures = await DatabaseHelper.instance.getAllCaptures();
    final settings = await DatabaseHelper.instance.getSettings();

    final exportData = {
      'app': 'SnapNote AI',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'settings': settings.toMap(),
      'captures': captures.map((e) => e.toMap()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export SnapNote Data to JSON',
      fileName: 'snapnote_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(jsonString);
      return outputFile;
    }
    return null;
  }

  /// Export notes and items as organized Markdown files in a chosen directory
  Future<String?> exportToMarkdownFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Folder for Markdown Export',
    );

    if (selectedDirectory == null) return null;

    final captures = await DatabaseHelper.instance.getAllCaptures();
    final baseDir = Directory(selectedDirectory);

    for (var capture in captures) {
      final categoryFolder = Directory(p.join(baseDir.path, capture.category));
      if (!await categoryFolder.exists()) {
        await categoryFolder.create(recursive: true);
      }

      final safeTitle = capture.title
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          .trim();
      final filename = '${safeTitle.isEmpty ? "capture" : safeTitle}_${capture.id.substring(0, 6)}.md';
      final mdFile = File(p.join(categoryFolder.path, filename));

      final mdBuffer = StringBuffer();
      mdBuffer.writeln('# ${capture.title}');
      mdBuffer.writeln('');
      mdBuffer.writeln('**Category**: ${capture.category.toUpperCase()}  ');
      mdBuffer.writeln('**Date**: ${capture.createdAt.toLocal().toString()}  ');
      if (capture.tags.isNotEmpty) {
        mdBuffer.writeln('**Tags**: ${capture.tags.map((t) => "#$t").join(' ')}  ');
      }
      if (capture.url != null && capture.url!.isNotEmpty) {
        mdBuffer.writeln('**Source**: [${capture.url}](${capture.url})  ');
      }
      mdBuffer.writeln('');
      mdBuffer.writeln('---');
      mdBuffer.writeln('');
      mdBuffer.writeln('## Summary');
      mdBuffer.writeln(capture.summary);
      mdBuffer.writeln('');
      mdBuffer.writeln('## Content');
      mdBuffer.writeln(capture.content);

      if (capture.programmingLanguage != null) {
        mdBuffer.writeln('');
        mdBuffer.writeln('```${capture.programmingLanguage}');
        mdBuffer.writeln(capture.content);
        mdBuffer.writeln('```');
      }

      await mdFile.writeAsString(mdBuffer.toString());
    }

    return selectedDirectory;
  }

  /// Create a complete ZIP backup containing database file and all screenshot images
  Future<String?> createZipBackup() async {
    final appDir = await StorageService.instance.getAppDirectory();
    final screenshotsDir = await StorageService.instance.getScreenshotsDirectory();
    final dbFile = File(p.join(appDir.path, 'snap_note.db'));

    final outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save SnapNote Full Zip Backup',
      fileName: 'snapnote_full_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (outputFile == null) return null;

    final encoder = ZipFileEncoder();
    encoder.create(outputFile);

    if (await dbFile.exists()) {
      encoder.addFile(dbFile, 'snap_note.db');
    }

    if (await screenshotsDir.exists()) {
      await encoder.addDirectory(screenshotsDir, includeDirName: true);
    }

    encoder.close();
    return outputFile;
  }

  /// Restore from a complete ZIP backup
  Future<bool> restoreFromZipBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select SnapNote Zip Backup to Restore',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) return false;

    final zipFile = File(result.files.single.path!);
    final appDir = await StorageService.instance.getAppDirectory();

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (var file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(p.join(appDir.path, filename));
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(data);
      }
    }

    return true;
  }
}

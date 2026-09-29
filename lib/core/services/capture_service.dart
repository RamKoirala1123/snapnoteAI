import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'storage_service.dart';

enum ScreenCaptureType {
  region,
  fullScreen,
  activeWindow,
  clipboard,
  fileImport,
}

class CaptureService {
  static final CaptureService instance = CaptureService._internal();

  CaptureService._internal();

  /// Captures screen or imports image based on [type] and returns local image file path
  Future<String?> captureImage(ScreenCaptureType type) async {
    switch (type) {
      case ScreenCaptureType.region:
        return await _captureScreen(CaptureMode.region);

      case ScreenCaptureType.fullScreen:
        return await _captureScreen(CaptureMode.screen);

      case ScreenCaptureType.activeWindow:
        return await _captureScreen(CaptureMode.window);

      case ScreenCaptureType.clipboard:
      case ScreenCaptureType.fileImport:
        return await _importFromFile();
    }
  }

  Future<String?> _captureScreen(CaptureMode mode) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = p.join(tempDir.path, 'temp_capture_${DateTime.now().millisecondsSinceEpoch}.png');

      if (Platform.isWindows) {
        print('Clearing clipboard before capture...');
        await Process.run('powershell', ['-Sta', '-Command', 'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::Clear()']);
      }

      print('Starting ScreenCapturer to path: $tempPath');
      final CapturedData? data = await ScreenCapturer.instance.capture(
        mode: mode,
        imagePath: tempPath,
        copyToClipboard: true,
        silent: false,
      );

      print('ScreenCapturer returned: ${data?.imagePath}');

      if (data != null && data.imageBytes != null && data.imageBytes!.isNotEmpty) {
        return await StorageService.instance.saveScreenshotBytes(data.imageBytes!);
      }

      if (data != null && data.imagePath != null && data.imagePath!.isNotEmpty) {
        final sourceFile = File(data.imagePath!);
        if (await sourceFile.exists()) {
          return await StorageService.instance.importImageFile(sourceFile);
        }
      }

      // Windows Fallback: The screen_capturer plugin often returns null on Windows, 
      // but the image is successfully placed on the clipboard. We poll the clipboard.
      if (Platform.isWindows) {
        print('Falling back to PowerShell clipboard polling...');
        for (int i = 0; i < 15; i++) { // Wait up to 7.5 seconds for user to draw region
          await Future.delayed(const Duration(milliseconds: 500));
          final psScript = '''
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
    \$image = [System.Windows.Forms.Clipboard]::GetImage()
    \$image.Save('$tempPath', [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "SUCCESS"
} else {
    Write-Output "NO_IMAGE"
}
''';
          final result = await Process.run('powershell', ['-Sta', '-Command', psScript]);
          if (result.stdout.toString().contains('SUCCESS')) {
            print('Successfully saved image from clipboard via PowerShell!');
            break;
          }
        }

        final sourceFile = File(tempPath);
        if (await sourceFile.exists()) {
          return await StorageService.instance.importImageFile(sourceFile);
        }
      }
    } catch (e, stackTrace) {
      print('Capture Error: $e');
      print(stackTrace);
    }
    return null;
  }

  Future<String?> _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp', 'bmp'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await StorageService.instance.importImageFile(file);
      }
    } catch (_) {}
    return null;
  }
}

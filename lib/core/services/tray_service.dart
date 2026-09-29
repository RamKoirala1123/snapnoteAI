import 'dart:io';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService with TrayListener {
  static final TrayService instance = TrayService._internal();

  Function()? _onCapture;
  Function()? _onOpenApp;
  Function()? _onOpenSearch;
  Function()? _onOpenSettings;
  Function(bool paused)? _onTogglePauseAI;
  bool _isAiPaused = false;

  TrayService._internal();

  bool get isAiPaused => _isAiPaused;

  Future<void> init({
    required Function() onCapture,
    required Function() onOpenApp,
    required Function() onOpenSearch,
    required Function() onOpenSettings,
    required Function(bool paused) onTogglePauseAI,
  }) async {
    _onCapture = onCapture;
    _onOpenApp = onOpenApp;
    _onOpenSearch = onOpenSearch;
    _onOpenSettings = onOpenSettings;
    _onTogglePauseAI = onTogglePauseAI;

    trayManager.addListener(this);

    try {
      if (Platform.isWindows) {
        await trayManager.setIcon('assets/app_icon.ico');
      }
    } catch (_) {}

    await updateTrayMenu();
  }

  Future<void> updateTrayMenu() async {
    List<MenuItem> items = [
      MenuItem(
        key: 'capture',
        label: '📷 Capture (Ctrl+Shift+Space)',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'open',
        label: '🏠 Open SnapNote AI',
      ),
      MenuItem(
        key: 'search',
        label: '🔍 Search Captures',
      ),
      MenuItem(
        key: 'settings',
        label: '⚙️ Settings',
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'pause_ai',
        label: '⏸️ Pause AI Processing',
        checked: _isAiPaused,
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit',
        label: '❌ Exit SnapNote AI',
      ),
    ];

    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'capture':
        if (_onCapture != null) _onCapture!();
        break;
      case 'open':
        windowManager.show();
        windowManager.focus();
        if (_onOpenApp != null) _onOpenApp!();
        break;
      case 'search':
        windowManager.show();
        windowManager.focus();
        if (_onOpenSearch != null) _onOpenSearch!();
        break;
      case 'settings':
        windowManager.show();
        windowManager.focus();
        if (_onOpenSettings != null) _onOpenSettings!();
        break;
      case 'pause_ai':
        _isAiPaused = !_isAiPaused;
        if (_onTogglePauseAI != null) _onTogglePauseAI!(_isAiPaused);
        updateTrayMenu();
        break;
      case 'exit':
        trayManager.destroy();
        exit(0);
    }
  }
}

import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyService {
  static final HotkeyService instance = HotkeyService._internal();
  
  Function()? _onRegionCapture;
  Function()? _onMenuCapture;

  HotkeyService._internal();

  Future<void> init({
    required Function() onRegionCapture,
    required Function() onMenuCapture,
    String regionShortcut = 'Ctrl + Shift + Space',
    String menuShortcut = 'Ctrl + Alt + Space',
  }) async {
    _onRegionCapture = onRegionCapture;
    _onMenuCapture = onMenuCapture;
    
    await hotKeyManager.unregisterAll();
    
    await registerShortcut(regionShortcut, isRegion: true);
    await registerShortcut(menuShortcut, isRegion: false);
  }

  Future<void> registerShortcut(String shortcutString, {required bool isRegion}) async {
    final parts = shortcutString.split('+').map((e) => e.trim().toLowerCase()).toList();
    List<HotKeyModifier> modifiers = [];
    PhysicalKeyboardKey key = PhysicalKeyboardKey.space;

    for (var part in parts) {
      if (part == 'ctrl' || part == 'control') modifiers.add(HotKeyModifier.control);
      else if (part == 'shift') modifiers.add(HotKeyModifier.shift);
      else if (part == 'alt') modifiers.add(HotKeyModifier.alt);
      else if (part == 'meta' || part == 'win' || part == 'windows') modifiers.add(HotKeyModifier.meta);
      else if (part == 'space') key = PhysicalKeyboardKey.space;
      else if (part == 's') key = PhysicalKeyboardKey.keyS;
      else if (part == 'c') key = PhysicalKeyboardKey.keyC;
      else if (part == 'x') key = PhysicalKeyboardKey.keyX;
    }

    final hotKey = HotKey(
      key: key,
      modifiers: modifiers,
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        if (isRegion && _onRegionCapture != null) {
          _onRegionCapture!();
        } else if (!isRegion && _onMenuCapture != null) {
          _onMenuCapture!();
        }
      },
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/models/app_settings.dart';
import 'core/models/capture_item.dart';
import 'core/services/ai_service.dart';
import 'core/services/capture_service.dart';
import 'core/services/hotkey_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/tray_service.dart';
import 'core/utils/constants.dart';
import 'core/utils/duplicate_detector.dart';

import 'ui/dialogs/capture_detail_dialog.dart';
import 'ui/dialogs/capture_overlay.dart';
import 'ui/dialogs/duplicate_alert_dialog.dart';
import 'ui/layout/sidebar.dart';

import 'ui/views/code_view.dart';
import 'ui/views/dashboard_view.dart';
import 'ui/views/events_view.dart';
import 'ui/views/ideas_view.dart';
import 'ui/views/inbox_view.dart';
import 'ui/views/notes_view.dart';
import 'ui/views/places_view.dart';
import 'ui/views/read_later_view.dart';
import 'ui/views/reminders_view.dart';
import 'ui/views/search_view.dart';
import 'ui/views/settings_view.dart';
import 'ui/views/shopping_view.dart';
import 'ui/views/tags_view.dart';
import 'ui/views/tasks_view.dart';
import 'ui/views/timeline_view.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool isHidden = args.contains('--hidden');

  // Initialize SQLite FFI on Windows
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Package Info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName.isNotEmpty ? packageInfo.appName : 'SnapNote AI',
    appPath: Platform.resolvedExecutable,
    args: ['--hidden'],
  );

  // Initialize Desktop Window Manager
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 840),
    minimumSize: Size(960, 640),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: AppConstants.appName,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (!isHidden) {
      await windowManager.show();
      await windowManager.focus();
    }
  });

  // Initialize Local Notifications
  await NotificationService.instance.init();

  runApp(const SnapNoteApp());
}

class SnapNoteApp extends StatefulWidget {
  const SnapNoteApp({super.key});

  @override
  State<SnapNoteApp> createState() => _SnapNoteAppState();
}

class _SnapNoteAppState extends State<SnapNoteApp> with WindowListener {
  AppSettings _settings = AppSettings();
  List<CaptureItem> _captures = [];
  bool _isLoading = true;
  String _activeView = 'dashboard';
  final CustomAIApiService _aiService = CustomAIApiService();
  final Uuid _uuid = const Uuid();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initializeApp();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (_settings.minimizeToTray) {
      await windowManager.hide();
    } else {
      await windowManager.destroy();
    }
  }

  Future<void> _initializeApp() async {
    try {
      await windowManager.setPreventClose(true);
      
      final settings = await DatabaseHelper.instance.getSettings();
      final captures = await DatabaseHelper.instance.getAllCaptures();

      setState(() {
        _settings = settings;
        _captures = captures;
        _isLoading = false;
      });

      // Initialize System Tray
      await TrayService.instance.init(
        onCapture: _startCaptureOverlay,
        onOpenApp: () async {
          await windowManager.show();
          await windowManager.focus();
          setState(() => _activeView = 'dashboard');
        },
        onOpenSearch: () async {
          await windowManager.show();
          await windowManager.focus();
          setState(() => _activeView = 'search');
        },
        onOpenSettings: () async {
          await windowManager.show();
          await windowManager.focus();
          setState(() => _activeView = 'settings');
        },
        onTogglePauseAI: (paused) {},
      );

      // Register Global Keyboard Shortcuts
      await HotkeyService.instance.init(
        onRegionCapture: _startRegionCaptureDirectly,
        onMenuCapture: _startCaptureOverlay,
        regionShortcut: _settings.globalShortcut, // Ctrl + Shift + Space
        menuShortcut: 'Ctrl + Alt + Space',
      );
      
      if (_settings.startWithWindows) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    setState(() => _settings = newSettings);
    await DatabaseHelper.instance.saveSettings(newSettings);
    
    // We re-init to apply the new setting
    await HotkeyService.instance.init(
      onRegionCapture: _startRegionCaptureDirectly,
      onMenuCapture: _startCaptureOverlay,
      regionShortcut: newSettings.globalShortcut,
      menuShortcut: 'Ctrl + Alt + Space',
    );
    
    if (newSettings.startWithWindows) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }
  
  Future<void> _startRegionCaptureDirectly() async {
    final imagePath = await CaptureService.instance.captureImage(ScreenCaptureType.region);
    if (imagePath != null && imagePath.isNotEmpty) {
      await _processNewScreenshot(imagePath);
    }
  }

  Future<void> _startCaptureOverlay() async {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    
    final captureType = await CaptureOverlayDialog.show(ctx);
    if (captureType == null) return;

    // Small delay to ensure the dialog is fully hidden before taking the screenshot
    await Future.delayed(const Duration(milliseconds: 300));
    
    final imagePath = await CaptureService.instance.captureImage(captureType);
    if (imagePath != null && imagePath.isNotEmpty) {
      await _processNewScreenshot(imagePath);
    }
  }

  /// Fast unobtrusive capture processing pipeline
  Future<void> _processNewScreenshot(String imagePath) async {
    final newItemId = _uuid.v4();
    final now = DateTime.now();

    // 1. Create immediate local CaptureItem with 'processing' status
    final pendingItem = CaptureItem(
      id: newItemId,
      createdAt: now,
      updatedAt: now,
      imagePath: imagePath,
      category: AppConstants.catNote,
      originalCategory: AppConstants.catNote,
      title: 'Capturing Screenshot...',
      summary: 'Processing visual content with AI...',
      content: '',
      tags: ['capturing'],
      status: 'processing',
    );

    await DatabaseHelper.instance.insertCapture(pendingItem);
    await _refreshCaptures();

    if (!_settings.enableAi || TrayService.instance.isAiPaused) {
      // AI disabled: keep as pending note
      final offlineItem = pendingItem.copyWith(
        title: 'Screen Capture Note (${now.hour}:${now.minute})',
        summary: 'Saved locally without AI processing.',
        status: 'completed',
      );
      await DatabaseHelper.instance.updateCapture(offlineItem);
      await _refreshCaptures();
      return;
    }

    // 2. Process with Gemini AI asynchronously
    try {
      final aiRes = await _aiService.analyzeScreenshot(
        imagePath: imagePath,
        apiKey: _settings.geminiApiKey,
        modelName: _settings.aiModel,
      );

      final processedItem = pendingItem.copyWith(
        category: aiRes.category,
        title: aiRes.title,
        summary: aiRes.summary,
        content: aiRes.content,
        tags: aiRes.tags,
        confidence: aiRes.confidence,
        isUncertain: aiRes.isUncertain,
        status: aiRes.isUncertain ? 'needs_review' : 'completed',
        aiJsonPayload: aiRes.rawJson,
        date: aiRes.date,
        time: aiRes.time,
        endDate: aiRes.endDate,
        endTime: aiRes.endTime,
        location: aiRes.location,
        address: aiRes.address,
        city: aiRes.city,
        country: aiRes.country,
        url: aiRes.url,
        people: aiRes.people,
        productName: aiRes.productName,
        price: aiRes.price,
        currency: aiRes.currency,
        store: aiRes.store,
        programmingLanguage: aiRes.programmingLanguage,
        priority: aiRes.priority,
        dueDate: aiRes.dueDate,
      );

      // Check Duplicate Detection
      final potentialDuplicate = DuplicateDetector.findPotentialDuplicate(processedItem, _captures);

      await DatabaseHelper.instance.updateCapture(processedItem);
      await _refreshCaptures();

      // Show Notification
      if (_settings.enableNotifications && _settings.captureNotifications) {
        final catLabel = AppConstants.getCategoryLabel(processedItem.category);
        NotificationService.instance.showCaptureNotification(
          title: '✓ Saved to $catLabel',
          body: processedItem.title,
        );
      }

      // Handle duplicate alert modal if duplicate found
      final ctx = _navigatorKey.currentContext;
      if (potentialDuplicate != null && ctx != null && ctx.mounted) {
        final action = await DuplicateAlertDialog.show(
          ctx,
          newItem: processedItem,
          existingItem: potentialDuplicate,
        );

        if (action == DuplicateAction.deleteNew) {
          await _deleteCapture(processedItem.id);
        } else if (action == DuplicateAction.openExisting) {
          _openCaptureDetail(potentialDuplicate);
        }
      }
    } catch (e) {
      // AI processing failed (e.g. invalid API key or offline)
      final failedItem = pendingItem.copyWith(
        title: 'Screen Capture (Needs Review)',
        summary: 'AI processing failed: ${e.toString()}',
        status: 'failed',
        errorMessage: e.toString(),
      );
      await DatabaseHelper.instance.updateCapture(failedItem);
      await _refreshCaptures();
    }
  }

  Future<void> _refreshCaptures() async {
    final updatedList = await DatabaseHelper.instance.getAllCaptures();
    setState(() => _captures = updatedList);
  }

  Future<void> _deleteCapture(String id) async {
    await DatabaseHelper.instance.deleteCapture(id);
    await _refreshCaptures();
  }

  Future<void> _updateCaptureItem(CaptureItem item) async {
    await DatabaseHelper.instance.updateCapture(item);
    await _refreshCaptures();
  }

  void _openCaptureDetail(CaptureItem item) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    
    CaptureDetailDialog.show(
      ctx,
      item: item,
      onSave: _updateCaptureItem,
      onDelete: () => _deleteCapture(item.id),
      onRetryAI: () => _processNewScreenshot(item.imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _settings.themeMode == 'light'
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;

    final inboxCount = _captures.where((e) => e.status != 'completed' || e.isUncertain).length;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  // Desktop Navigation Rail Sidebar
                  Sidebar(
                    activeView: _activeView,
                    onSelectView: (view) => setState(() => _activeView = view),
                    onQuickCapture: _startCaptureOverlay,
                    inboxCount: inboxCount,
                  ),

                  // Main View Content Area
                  Expanded(
                    child: _buildActiveView(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActiveView() {
    switch (_activeView) {
      case 'dashboard':
        return DashboardView(
          captures: _captures,
          onQuickCapture: _startCaptureOverlay,
          onNavigateToView: (view) => setState(() => _activeView = view),
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'inbox':
        return InboxView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'notes':
        return NotesView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'events':
        return EventsView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'reminders':
        return RemindersView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'tasks':
        return TasksView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
          onItemUpdate: _updateCaptureItem,
        );
      case 'read_later':
        return ReadLaterView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
          onItemUpdate: _updateCaptureItem,
        );
      case 'ideas':
        return IdeasView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'shopping':
        return ShoppingView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
          onItemUpdate: _updateCaptureItem,
        );
      case 'code':
        return CodeView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'places':
        return PlacesView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'tags':
        return TagsView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'search':
        return SearchView(
          captures: _captures,
          settings: _settings,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'timeline':
        return TimelineView(
          captures: _captures,
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
      case 'settings':
        return SettingsView(
          settings: _settings,
          onSaveSettings: _saveSettings,
        );
      default:
        return DashboardView(
          captures: _captures,
          onQuickCapture: _startCaptureOverlay,
          onNavigateToView: (view) => setState(() => _activeView = view),
          onItemTap: _openCaptureDetail,
          onItemDelete: _deleteCapture,
        );
    }
  }
}

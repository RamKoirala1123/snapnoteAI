class AppSettings {
  final String geminiApiKey;
  final String aiModel;
  final bool enableAi;
  final bool autoClassification;
  final bool autoTagging;
  final bool autoSummary;
  final double confidenceThreshold;
  final String globalShortcut;
  final bool saveOriginalScreenshots;
  final int imageQuality; // 1 to 100
  final bool enableNotifications;
  final bool captureNotifications;
  final bool reminderNotifications;
  final String themeMode; // 'system', 'dark', 'light'
  final bool startWithWindows;
  final bool minimizeToTray;
  final String dataLocation;

  AppSettings({
    this.geminiApiKey = '',
    this.aiModel = 'gemini-3.6-flash',
    this.enableAi = true,
    this.autoClassification = true,
    this.autoTagging = true,
    this.autoSummary = true,
    this.confidenceThreshold = 0.7,
    this.globalShortcut = 'Ctrl + Shift + Space',
    this.saveOriginalScreenshots = true,
    this.imageQuality = 85,
    this.enableNotifications = true,
    this.captureNotifications = true,
    this.reminderNotifications = true,
    this.themeMode = 'dark',
    this.startWithWindows = false,
    this.minimizeToTray = true,
    this.dataLocation = '',
  });

  AppSettings copyWith({
    String? geminiApiKey,
    String? aiModel,
    bool? enableAi,
    bool? autoClassification,
    bool? autoTagging,
    bool? autoSummary,
    double? confidenceThreshold,
    String? globalShortcut,
    bool? saveOriginalScreenshots,
    int? imageQuality,
    bool? enableNotifications,
    bool? captureNotifications,
    bool? reminderNotifications,
    String? themeMode,
    bool? startWithWindows,
    bool? minimizeToTray,
    String? dataLocation,
  }) {
    return AppSettings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      aiModel: aiModel ?? this.aiModel,
      enableAi: enableAi ?? this.enableAi,
      autoClassification: autoClassification ?? this.autoClassification,
      autoTagging: autoTagging ?? this.autoTagging,
      autoSummary: autoSummary ?? this.autoSummary,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      globalShortcut: globalShortcut ?? this.globalShortcut,
      saveOriginalScreenshots: saveOriginalScreenshots ?? this.saveOriginalScreenshots,
      imageQuality: imageQuality ?? this.imageQuality,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      captureNotifications: captureNotifications ?? this.captureNotifications,
      reminderNotifications: reminderNotifications ?? this.reminderNotifications,
      themeMode: themeMode ?? this.themeMode,
      startWithWindows: startWithWindows ?? this.startWithWindows,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      dataLocation: dataLocation ?? this.dataLocation,
    );
  }

  Map<String, String> toMap() {
    return {
      'geminiApiKey': geminiApiKey,
      'aiModel': aiModel,
      'enableAi': enableAi.toString(),
      'autoClassification': autoClassification.toString(),
      'autoTagging': autoTagging.toString(),
      'autoSummary': autoSummary.toString(),
      'confidenceThreshold': confidenceThreshold.toString(),
      'globalShortcut': globalShortcut,
      'saveOriginalScreenshots': saveOriginalScreenshots.toString(),
      'imageQuality': imageQuality.toString(),
      'enableNotifications': enableNotifications.toString(),
      'captureNotifications': captureNotifications.toString(),
      'reminderNotifications': reminderNotifications.toString(),
      'themeMode': themeMode,
      'startWithWindows': startWithWindows.toString(),
      'minimizeToTray': minimizeToTray.toString(),
      'dataLocation': dataLocation,
    };
  }

  factory AppSettings.fromMap(Map<String, String> map) {
    String loadedModel = map['aiModel'] ?? 'gemini-3.6-flash';
    if (loadedModel == 'gemini-1.5-flash' || loadedModel == 'gemini-2.0-flash') {
      loadedModel = 'gemini-3.6-flash';
    } else if (loadedModel == 'gemini-1.5-pro') {
      loadedModel = 'gemini-3.1-pro';
    }

    return AppSettings(
      geminiApiKey: map['geminiApiKey'] ?? '',
      aiModel: loadedModel,
      enableAi: map['enableAi'] != 'false',
      autoClassification: map['autoClassification'] != 'false',
      autoTagging: map['autoTagging'] != 'false',
      autoSummary: map['autoSummary'] != 'false',
      confidenceThreshold: double.tryParse(map['confidenceThreshold'] ?? '') ?? 0.7,
      globalShortcut: map['globalShortcut'] ?? 'Ctrl + Shift + Space',
      saveOriginalScreenshots: map['saveOriginalScreenshots'] != 'false',
      imageQuality: int.tryParse(map['imageQuality'] ?? '') ?? 85,
      enableNotifications: map['enableNotifications'] != 'false',
      captureNotifications: map['captureNotifications'] != 'false',
      reminderNotifications: map['reminderNotifications'] != 'false',
      themeMode: map['themeMode'] ?? 'dark',
      startWithWindows: map['startWithWindows'] == 'true',
      minimizeToTray: map['minimizeToTray'] != 'false',
      dataLocation: map['dataLocation'] ?? '',
    );
  }
}

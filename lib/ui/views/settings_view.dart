import 'package:flutter/material.dart';
import '../../core/models/app_settings.dart';
import '../dialogs/export_dialog.dart';
import '../widgets/k_components.dart';

class SettingsView extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings newSettings) onSaveSettings;

  const SettingsView({
    super.key,
    required this.settings,
    required this.onSaveSettings,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _apiKeyController;
  late String _aiModel;
  late bool _enableAi;
  late bool _autoClassification;
  late bool _autoTagging;
  late bool _autoSummary;
  late double _confidenceThreshold;

  late TextEditingController _shortcutController;
  late bool _saveOriginalScreenshots;
  late double _imageQuality;

  late bool _enableNotifications;
  late bool _captureNotifications;
  late bool _reminderNotifications;

  late String _themeMode;
  late bool _startWithWindows;
  late bool _minimizeToTray;

  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _apiKeyController = TextEditingController(text: s.geminiApiKey);
    _aiModel = s.aiModel;
    _enableAi = s.enableAi;
    _autoClassification = s.autoClassification;
    _autoTagging = s.autoTagging;
    _autoSummary = s.autoSummary;
    _confidenceThreshold = s.confidenceThreshold;

    _shortcutController = TextEditingController(text: s.globalShortcut);
    _saveOriginalScreenshots = s.saveOriginalScreenshots;
    _imageQuality = s.imageQuality.toDouble();

    _enableNotifications = s.enableNotifications;
    _captureNotifications = s.captureNotifications;
    _reminderNotifications = s.reminderNotifications;

    _themeMode = s.themeMode;
    _startWithWindows = s.startWithWindows;
    _minimizeToTray = s.minimizeToTray;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _shortcutController.dispose();
    super.dispose();
  }

  void _save() {
    final newSettings = widget.settings.copyWith(
      geminiApiKey: _apiKeyController.text.trim(),
      aiModel: _aiModel,
      enableAi: _enableAi,
      autoClassification: _autoClassification,
      autoTagging: _autoTagging,
      autoSummary: _autoSummary,
      confidenceThreshold: _confidenceThreshold,
      globalShortcut: _shortcutController.text.trim(),
      saveOriginalScreenshots: _saveOriginalScreenshots,
      imageQuality: _imageQuality.toInt(),
      enableNotifications: _enableNotifications,
      captureNotifications: _captureNotifications,
      reminderNotifications: _reminderNotifications,
      themeMode: _themeMode,
      startWithWindows: _startWithWindows,
      minimizeToTray: _minimizeToTray,
    );

    widget.onSaveSettings(newSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KScaffold(
      backgroundColor: Colors.transparent,
      title: 'Application Settings',
      subtitle: 'Configure your preferences',
      trailing: KButton.primaryIcon(
        onPressed: _save,
        icon: const Icon(Icons.save_rounded),
        label: const Text('Save Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // AI Configuration Card
            _buildSectionCard(
              theme,
              title: '🤖 Custom AI Provider Configuration',
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _apiKeyController,
                        obscureText: _obscureApiKey,
                        decoration: InputDecoration(
                          labelText: 'API Key (f1arl.com)',
                          hintText: 'Enter your API key...',
                          prefixIcon: const Icon(Icons.key_rounded),
                          suffixIcon: KButton.icon(
                            icon: Icon(_obscureApiKey ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownMenu<String>(
                        initialSelection: _aiModel,
                        label: const Text('AI Model'),
                        expandedInsets: EdgeInsets.zero, // Makes it fill the Expanded width
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 'qwen3.8-27B', label: 'Qwen 3.8-27B (Custom)'),
                          DropdownMenuEntry(value: 'gemini-3.6-flash', label: 'Gemini 3.6 Flash (Fast)'),
                          DropdownMenuEntry(value: 'gemini-3.1-pro', label: 'Gemini 3.1 Pro (Deep)'),
                        ],
                        onSelected: (val) {
                          if (val != null) setState(() => _aiModel = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Enable AI Processing'),
                  subtitle: const Text('Process captured screenshots with Custom AI'),
                  value: _enableAi,
                  onChanged: (val) => setState(() => _enableAi = val),
                ),
                SwitchListTile(
                  title: const Text('Auto Classification'),
                  subtitle: const Text('Automatically organize items into Notes, Events, Tasks, Read Later, etc.'),
                  value: _autoClassification,
                  onChanged: (val) => setState(() => _autoClassification = val),
                ),
                SwitchListTile(
                  title: const Text('Auto Tagging & Summarization'),
                  subtitle: const Text('Extract hashtags and 1-2 sentence executive summary'),
                  value: _autoTagging && _autoSummary,
                  onChanged: (val) => setState(() {
                    _autoTagging = val;
                    _autoSummary = val;
                  }),
                ),
                const SizedBox(height: 8),
                Text('Confidence Review Threshold: ${(_confidenceThreshold * 100).toInt()}%'),
                Slider(
                  value: _confidenceThreshold,
                  min: 0.5,
                  max: 0.95,
                  divisions: 9,
                  label: '${(_confidenceThreshold * 100).toInt()}%',
                  onChanged: (val) => setState(() => _confidenceThreshold = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Screen Capture Settings
            _buildSectionCard(
              theme,
              title: '📷 Screen Capture & Shortcuts',
              children: [
                TextField(
                  controller: _shortcutController,
                  decoration: const InputDecoration(
                    labelText: 'Global Keyboard Shortcut',
                    hintText: 'Ctrl + Shift + Space',
                    prefixIcon: Icon(Icons.keyboard_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Save Original Screenshots'),
                  subtitle: const Text('Always store raw screenshot files on local disk'),
                  value: _saveOriginalScreenshots,
                  onChanged: (val) => setState(() => _saveOriginalScreenshots = val),
                ),
                const SizedBox(height: 8),
                Text('Image Compression Quality: ${_imageQuality.toInt()}%'),
                Slider(
                  value: _imageQuality,
                  min: 50,
                  max: 100,
                  divisions: 10,
                  label: '${_imageQuality.toInt()}%',
                  onChanged: (val) => setState(() => _imageQuality = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Notifications & System Tray
            _buildSectionCard(
              theme,
              title: '🔔 Notifications & Windows System Tray',
              children: [
                SwitchListTile(
                  title: const Text('Enable Windows Notifications'),
                  value: _enableNotifications,
                  onChanged: (val) => setState(() => _enableNotifications = val),
                ),
                SwitchListTile(
                  title: const Text('Capture Completion Notifications'),
                  subtitle: const Text('Show toast when AI finishes classifying a screenshot'),
                  value: _captureNotifications,
                  onChanged: (val) => setState(() => _captureNotifications = val),
                ),
                SwitchListTile(
                  title: const Text('Minimize to System Tray on Close'),
                  subtitle: const Text('Keep app running background listener in taskbar notification tray'),
                  value: _minimizeToTray,
                  onChanged: (val) => setState(() => _minimizeToTray = val),
                ),
                SwitchListTile(
                  title: const Text('Start Automatically with Windows'),
                  value: _startWithWindows,
                  onChanged: (val) => setState(() => _startWithWindows = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Data Ownership & Backup
            _buildSectionCard(
              theme,
              title: '💾 Data Ownership & Export',
              children: [
                const Text(
                  'All your notes and screenshots are saved directly on your local computer. No cloud subscription required.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                KButton.primaryIcon(
                  onPressed: () => ExportDialog.show(context),
                  icon: const Icon(Icons.import_export_rounded),
                  label: const Text('Export Data / Create Backup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(ThemeData theme, {required String title, required List<Widget> children}) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

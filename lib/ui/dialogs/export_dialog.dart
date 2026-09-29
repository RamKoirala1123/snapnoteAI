import 'package:flutter/material.dart';
import '../../core/services/export_import_service.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ExportDialog(),
    );
  }

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _isLoading = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.import_export_rounded, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Export & Backup', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Text('Your data remains 100% locally owned', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildActionTile(
                icon: Icons.code_rounded,
                title: 'Export to JSON',
                subtitle: 'Export entire database and settings to a structured JSON file',
                color: Colors.indigo,
                onTap: () async {
                  setState(() => _isLoading = true);
                  final path = await ExportImportService.instance.exportToJson();
                  setState(() {
                    _isLoading = false;
                    _statusMessage = path != null ? 'JSON exported to $path' : 'Export cancelled';
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.folder_special_rounded,
                title: 'Export to Markdown Folder',
                subtitle: 'Export notes and captures as readable .md files sorted by category',
                color: Colors.blue,
                onTap: () async {
                  setState(() => _isLoading = true);
                  final path = await ExportImportService.instance.exportToMarkdownFolder();
                  setState(() {
                    _isLoading = false;
                    _statusMessage = path != null ? 'Markdown exported to $path' : 'Export cancelled';
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.archive_rounded,
                title: 'Full Zip Backup',
                subtitle: 'Create a zip archive containing database and screenshot files',
                color: const Color(0xFF10B981),
                onTap: () async {
                  setState(() => _isLoading = true);
                  final path = await ExportImportService.instance.createZipBackup();
                  setState(() {
                    _isLoading = false;
                    _statusMessage = path != null ? 'Backup saved to $path' : 'Backup cancelled';
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.unarchive_rounded,
                title: 'Restore from Zip Backup',
                subtitle: 'Restore database and images from a previous zip backup',
                color: Colors.amber,
                onTap: () async {
                  setState(() => _isLoading = true);
                  final ok = await ExportImportService.instance.restoreFromZipBackup();
                  setState(() {
                    _isLoading = false;
                    _statusMessage = ok ? 'Restore complete! Please restart app.' : 'Restore cancelled';
                  });
                },
              ),
            ],

            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusMessage!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

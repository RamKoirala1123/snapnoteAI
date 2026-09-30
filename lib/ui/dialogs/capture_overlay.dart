import 'package:flutter/material.dart';
import '../widgets/k_components.dart';
import '../../core/services/capture_service.dart';

class CaptureOverlayDialog extends StatelessWidget {
  const CaptureOverlayDialog({super.key});

  static Future<ScreenCaptureType?> show(BuildContext context) {
    return showDialog<ScreenCaptureType>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const CaptureOverlayDialog(),
    );
  }

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.crop_free_rounded, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capture Content',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Select screen area or import image to organize with AI',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                KButton.icon(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildOptionTile(
              context,
              icon: Icons.crop_rounded,
              title: 'Select Region (Snipping Tool)',
              subtitle: 'Drag a rectangle around anything on your screen (Ctrl+Shift+Space)',
              color: const Color(0xFF7C3AED),
              onTap: () => Navigator.of(context).pop(ScreenCaptureType.region),
            ),

            const SizedBox(height: 10),

            _buildOptionTile(
              context,
              icon: Icons.desktop_windows_rounded,
              title: 'Full Screen Capture',
              subtitle: 'Capture the entire primary display',
              color: const Color(0xFF3B82F6),
              onTap: () => Navigator.of(context).pop(ScreenCaptureType.fullScreen),
            ),

            const SizedBox(height: 10),

            _buildOptionTile(
              context,
              icon: Icons.window_rounded,
              title: 'Active Window Capture',
              subtitle: 'Capture the active application window',
              color: const Color(0xFF06B6D4),
              onTap: () => Navigator.of(context).pop(ScreenCaptureType.activeWindow),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildOptionTile(
                    context,
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'Paste Image',
                    subtitle: 'From Clipboard',
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.of(context).pop(ScreenCaptureType.clipboard),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOptionTile(
                    context,
                    icon: Icons.folder_open_rounded,
                    title: 'Import File',
                    subtitle: 'From Computer',
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.of(context).pop(ScreenCaptureType.fileImport),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
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

import '../models/capture_item.dart';

class DuplicateDetector {
  /// Check if a newly analyzed item looks like an existing capture.
  /// Returns existing CaptureItem if similarity is high, else null.
  static CaptureItem? findPotentialDuplicate(CaptureItem newItem, List<CaptureItem> existingItems) {
    if (existingItems.isEmpty) return null;

    final newTitleClean = newItem.title.toLowerCase().trim();
    final newSummaryClean = newItem.summary.toLowerCase().trim();

    for (var existing in existingItems) {
      if (existing.id == newItem.id) continue;

      final existingTitleClean = existing.title.toLowerCase().trim();
      final existingSummaryClean = existing.summary.toLowerCase().trim();

      // Direct exact match on title
      if (newTitleClean.length > 5 && newTitleClean == existingTitleClean) {
        return existing;
      }

      // Strong match on summary or content overlap
      if (newSummaryClean.length > 15 && existingSummaryClean.length > 15) {
        if (newSummaryClean.contains(existingSummaryClean) || existingSummaryClean.contains(newSummaryClean)) {
          return existing;
        }
      }

      // Same extracted URL
      if (newItem.url != null && newItem.url!.isNotEmpty && newItem.url == existing.url) {
        return existing;
      }
    }

    return null;
  }
}

import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/k_components.dart';

class ShoppingView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;
  final Function(CaptureItem item)? onItemUpdate;

  const ShoppingView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
    this.onItemUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = captures.where((e) => e.category == AppConstants.catShopping).toList();
    
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final wishlist = items.where((e) => !e.isPurchased).toList();
    final purchased = items.where((e) => e.isPurchased).toList();

    return KScaffold(
      backgroundColor: Colors.transparent,
      title: 'Shopping & Products',
      subtitle: '${items.length} Products',
      body: items.isEmpty
                  ? const Center(child: Text('No products found.', style: TextStyle(color: Colors.grey)))
                  : ListView(
                      children: [
                        if (wishlist.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('Wishlist (${wishlist.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...wishlist.map((item) => _buildProductCard(item, theme)),
                          const SizedBox(height: 16),
                        ],
                        if (purchased.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 8),
                            child: Text('Purchased (${purchased.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...purchased.map((item) => _buildProductCard(item, theme)),
                        ],
                      ],
                    ),
    );
  }

  Widget _buildProductCard(CaptureItem item, ThemeData theme) {
    final isBought = item.isPurchased;
    final priceStr = (item.price != null && item.price!.isNotEmpty) ? '${item.currency ?? ''} ${item.price}'.trim() : 'No price';
    final storeStr = (item.store != null && item.store!.isNotEmpty) ? item.store! : 'Unknown store';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onItemTap(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price Tag Block
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isBought ? Colors.grey.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isBought ? Colors.grey.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sell_rounded, size: 20, color: isBought ? Colors.grey : Colors.green),
                    const SizedBox(height: 4),
                    Text(
                      priceStr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isBought ? Colors.grey : Colors.green[700],
                        decoration: isBought ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName?.isNotEmpty == true ? item.productName! : item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isBought ? TextDecoration.lineThrough : null,
                              color: isBought ? Colors.grey : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        KButton.icon(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onItemDelete(item.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(storeStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ActionChip(
                          avatar: Icon(isBought ? Icons.remove_shopping_cart : Icons.check_circle_outline, size: 16),
                          label: Text(isBought ? 'Mark Unpurchased' : 'Mark Purchased', style: const TextStyle(fontSize: 12)),
                          onPressed: () {
                            if (onItemUpdate != null) {
                              onItemUpdate!(item.copyWith(isPurchased: !isBought));
                            }
                          },
                        ),
                        if (item.url != null && item.url!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.open_in_new_rounded, size: 16),
                            label: const Text('Open Link', style: TextStyle(fontSize: 12)),
                            onPressed: () => onItemTap(item), // Or launch URL directly if preferred
                          ),
                        ]
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

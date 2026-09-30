import 'package:flutter/material.dart';
import '../../core/app_typography.dart';

class KScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? body;
  final EdgeInsetsGeometry padding;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const KScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.body,
    this.padding = const EdgeInsets.all(24),
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body ?? const SizedBox();

    if (title != null) {
      content = Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: context.bodySmall.muted(context),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: body ?? const SizedBox()),
          ],
        ),
      );
    } else if (padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class KAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const KAppBar({super.key, this.title, this.actions, this.leading, this.centerTitle = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? DefaultTextStyle(style: context.titleLarge, child: title!) : null,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class KContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const KContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final container = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: border ?? Border.all(color: theme.dividerColor),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        child: container,
      );
    }
    return container;
  }
}

enum _KButtonType { primary, secondary, outlined, icon, text }

class KButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final _KButtonType _type;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final String? tooltip;
  final bool isIconVariant;

  const KButton.primary({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  }) : _type = _KButtonType.primary, icon = null, label = null, padding = null, isIconVariant = false, constraints = null, tooltip = null;

  const KButton.primaryIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
  }) : _type = _KButtonType.primary, child = null, padding = null, isIconVariant = true, constraints = null, tooltip = null;

  const KButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  }) : _type = _KButtonType.secondary, icon = null, label = null, padding = null, isIconVariant = false, constraints = null, tooltip = null;

  const KButton.secondaryIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
  }) : _type = _KButtonType.secondary, child = null, padding = null, isIconVariant = true, constraints = null, tooltip = null;

  const KButton.outlined({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  }) : _type = _KButtonType.outlined, icon = null, label = null, padding = null, isIconVariant = false, constraints = null, tooltip = null;

  const KButton.outlinedIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
  }) : _type = _KButtonType.outlined, child = null, padding = null, isIconVariant = true, constraints = null, tooltip = null;

  const KButton.text({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
  }) : _type = _KButtonType.text, icon = null, label = null, padding = null, isIconVariant = false, constraints = null, tooltip = null;

  const KButton.textIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color,
  }) : _type = _KButtonType.text, child = null, padding = null, isIconVariant = true, constraints = null, tooltip = null;

  const KButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.padding,
    this.constraints,
    this.tooltip,
  }) : _type = _KButtonType.icon, child = null, label = null, isIconVariant = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (_type) {
      case _KButtonType.primary:
        if (isIconVariant) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon!,
            label: label!,
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: child!,
        );
      case _KButtonType.secondary:
        if (isIconVariant) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon!,
            label: label!,
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: child!,
        );
      case _KButtonType.outlined:
        if (isIconVariant) {
          return OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon!,
            label: label!,
            style: OutlinedButton.styleFrom(
              foregroundColor: color ?? colorScheme.primary,
              side: BorderSide(color: color ?? colorScheme.outline),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? colorScheme.primary,
            side: BorderSide(color: color ?? colorScheme.outline),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: child!,
        );
      case _KButtonType.text:
        if (isIconVariant) {
          return TextButton.icon(
            onPressed: onPressed,
            icon: icon!,
            label: label!,
            style: TextButton.styleFrom(
              foregroundColor: color ?? colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color ?? colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: child!,
        );
      case _KButtonType.icon:
        return IconButton(
          onPressed: onPressed,
          icon: icon!,
          color: color ?? colorScheme.primary,
          padding: padding ?? const EdgeInsets.all(8),
          constraints: constraints,
          tooltip: tooltip,
        );
    }
  }
}

class KDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const KDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
      ),
    );
  }
}

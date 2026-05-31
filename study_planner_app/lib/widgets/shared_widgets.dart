part of '../main.dart';

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SoftIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .12)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0)),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppStyle.line),
        boxShadow: [AppStyle.softShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: FCard.raw(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final bool destructive;

  const AppButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.icon,
      this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size(0, AppStyle.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      backgroundColor: destructive ? AppStyle.danger : AppStyle.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    );

    if (icon == null) {
      return FilledButton(onPressed: onPressed, style: style, child: child);
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: child,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool destructive;
  final Color? color;

  const AppIconButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      this.tooltip,
      this.destructive = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    final isDanger = destructive || icon == Icons.delete_outline_rounded;
    final tone = isDanger ? AppStyle.danger : (color ?? AppStyle.primary);
    final button = SizedBox(
      width: AppStyle.buttonHeight,
      height: AppStyle.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: tone.withValues(alpha: .08),
          foregroundColor: tone,
          side: BorderSide(color: tone.withValues(alpha: .22)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
        ),
        child: Icon(icon, size: 19),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

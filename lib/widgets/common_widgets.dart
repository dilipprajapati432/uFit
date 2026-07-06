// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'package:ufit/theme/theme_ext.dart';

// ─── GRADIENT CARD ───────────────────────────────────────────
class GradientCard extends StatelessWidget {
  final Gradient gradient;
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? height;

  const GradientCard({
    super.key,
    required this.gradient,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

// ─── GLASS CARD ──────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? context.card : AppColors.lightCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? context.border : AppColors.lightBorder,
          ),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ─── CIRCULAR PROGRESS ───────────────────────────────────────
class CircularProgressWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color color;
  final Color bgColor;
  final double strokeWidth;
  final Widget? child;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 100,
    required this.color,
    this.bgColor = Colors.transparent,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

// ─── STAT TILE ───────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color color;
  final IconData icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              action!,
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ─── PREMIUM GATE BANNER ─────────────────────────────────────
class PremiumGateBanner extends StatelessWidget {
  final VoidCallback onUpgrade;
  final String featureName;

  const PremiumGateBanner({
    super.key,
    required this.onUpgrade,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppColors.primaryGradient,
      child: Row(
        children: [
          Text('✨', style: TextStyle(fontSize: 28)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'uFit Pro Feature',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  '$featureName requires Pro',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onUpgrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Upgrade', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }
}

// ─── LOADING SHIMMER ─────────────────────────────────────────
class LoadingShimmerCard extends StatelessWidget {
  final double height;

  const LoadingShimmerCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
      duration: 1500.ms,
      color: context.cardElevated,
    );
  }
}

// ─── ACHIEVEMENT BADGE ───────────────────────────────────────
class AchievementBadge extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isUnlocked;

  const AchievementBadge({
    super.key,
    required this.emoji,
    required this.title,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: isUnlocked ? AppColors.primaryGradient : null,
            color: isUnlocked ? null : context.card,
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? Colors.transparent : context.border,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 24,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? context.text : context.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

// ─── SMOOTH BOTTOM SHEET ─────────────────────────────────────
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

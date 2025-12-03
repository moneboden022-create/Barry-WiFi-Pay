// lib/widgets/stat_card.dart
// 📊 BARRY WI-FI - Stat Card Widget 5G

import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  final Stat stat;
  final Color? color;

  const StatCard({
    super.key,
    required this.stat,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.neonViolet;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(stat.icon ?? stat.name),
              color: cardColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          
          // Valeur
          Text(
            stat.formattedValue,
            style: AppTextStyles.h4.copyWith(
              color: cardColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Titre
          Text(
            stat.title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Changement (si disponible)
          if (stat.change != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    stat.change! >= 0 
                        ? Icons.trending_up 
                        : Icons.trending_down,
                    color: stat.change! >= 0 
                        ? AppColors.neonGreen 
                        : AppColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${stat.change! >= 0 ? '+' : ''}${stat.change!.toStringAsFixed(1)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: stat.change! >= 0 
                          ? AppColors.neonGreen 
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains('user') || lowerName.contains('utilisateur')) {
      return Icons.people_outline;
    } else if (lowerName.contains('voucher') || lowerName.contains('code')) {
      return Icons.confirmation_number_outlined;
    } else if (lowerName.contains('device') || lowerName.contains('appareil')) {
      return Icons.devices;
    } else if (lowerName.contains('connect') || lowerName.contains('session')) {
      return Icons.wifi;
    } else if (lowerName.contains('revenue') || lowerName.contains('money') || 
               lowerName.contains('gnf') || lowerName.contains('franc')) {
      return Icons.payments_outlined;
    } else if (lowerName.contains('active') || lowerName.contains('actif')) {
      return Icons.check_circle_outline;
    } else if (lowerName.contains('new') || lowerName.contains('nouveau')) {
      return Icons.add_circle_outline;
    }
    
    return Icons.analytics_outlined;
  }
}

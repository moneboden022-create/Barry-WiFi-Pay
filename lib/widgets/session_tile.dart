// lib/widgets/session_tile.dart
// 📊 BARRY WI-FI - Session Tile Widget 5G

import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class SessionTile extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionTile({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Icône appareil
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.devices_rounded,
                color: AppColors.neonGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.device,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'IP: ${session.ip}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            // Date et status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (session.isActive ? AppColors.neonGreen : AppColors.textMuted)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.isActive ? 'ACTIVE' : 'TERMINÉE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: session.isActive ? AppColors.neonGreen : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.formattedDate,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

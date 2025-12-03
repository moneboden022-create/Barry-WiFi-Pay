// lib/widgets/connection_tile.dart
// 📡 BARRY WI-FI - Connection Tile Widget 5G

import 'package:flutter/material.dart';
import '../models/connection_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ConnectionTile extends StatelessWidget {
  final ConnectionModel c;
  final VoidCallback? onTap;

  const ConnectionTile({
    super.key,
    required this.c,
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
            // Icône status
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (c.success ? AppColors.neonGreen : AppColors.error)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                c.success ? Icons.wifi : Icons.wifi_off,
                color: c.success ? AppColors.neonGreen : AppColors.error,
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
                    c.deviceName ?? c.deviceId,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'IP: ${c.ip}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            // Durée
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c.formattedDuration,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (c.dataUsed != null)
                  Text(
                    c.formattedDataUsed,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.modernTurquoise,
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

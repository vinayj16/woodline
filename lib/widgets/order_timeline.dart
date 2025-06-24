import 'package:flutter/material.dart';
import 'package:woodline/theme/app_theme.dart';

class OrderTimeline extends StatelessWidget {
  final String status;
  
  const OrderTimeline({
    Key? key,
    required this.status,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    final steps = [
      _TimelineStep(
        title: 'Order Placed',
        isActive: true,
        isCompleted: true,
        icon: Icons.shopping_bag_outlined,
      ),
      _TimelineStep(
        title: 'Processing',
        isActive: status == 'processing',
        isCompleted: status == 'processing' || status == 'shipped' || status == 'delivered',
        icon: Icons.sync,
      ),
      _TimelineStep(
        title: 'Shipped',
        isActive: status == 'shipped',
        isCompleted: status == 'shipped' || status == 'delivered',
        icon: Icons.local_shipping_outlined,
      ),
      _TimelineStep(
        title: 'Delivered',
        isActive: status == 'delivered',
        isCompleted: status == 'delivered',
        icon: Icons.check_circle_outline,
      ),
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildTimeline(steps, theme),
        ],
      ),
    );
  }
  
  List<Widget> _buildTimeline(List<_TimelineStep> steps, ThemeData theme) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final isLast = i == steps.length - 1;
      
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and icon
            Column(
              children: [
                // Top line (only for steps after the first)
                if (i > 0)
                  Container(
                    width: 2,
                    height: 24,
                    color: steps[i-1].isCompleted 
                        ? AppColors.primary 
                        : AppColors.divider,
                  ),
                // Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: step.isCompleted 
                        ? AppColors.primary.withOpacity(0.1) 
                        : (step.isActive 
                            ? AppColors.primary.withOpacity(0.1) 
                            : AppColors.divider.withOpacity(0.3)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step.icon,
                    size: 18,
                    color: step.isCompleted 
                        ? AppColors.primary 
                        : (step.isActive ? AppColors.primary : AppColors.textSecondary),
                  ),
                ),
                // Bottom line (only if not last step)
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: step.isCompleted 
                        ? AppColors.primary 
                        : AppColors.divider,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Step title and description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: step.isActive ? FontWeight.w600 : FontWeight.normal,
                        color: step.isActive || step.isCompleted 
                            ? AppColors.textPrimary 
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (step.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return widgets;
  }
}

class _TimelineStep {
  final String title;
  final String? subtitle;
  final bool isActive;
  final bool isCompleted;
  final IconData icon;
  
  _TimelineStep({
    required this.title,
    this.subtitle,
    required this.isActive,
    required this.isCompleted,
    required this.icon,
  });
}

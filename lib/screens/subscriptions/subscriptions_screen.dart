// lib/screens/subscriptions/subscriptions_screen.dart
// 💳 BARRY WI-FI - Forfaits & Abonnements Premium 5G

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../data/plans.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late TabController _tabController;

  int _selectedPlanIndex = -1;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlansTab(userPlans, 'Particulier'),
                      _buildPlansTab(businessPlans, 'Entreprise'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppGradients.neonRainbow.createShader(bounds),
                  child: Text(
                    'Forfaits',
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  'Choisissez votre abonnement',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.neonVioletGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonViolet.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: AppTextStyles.buttonMedium,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 18),
                SizedBox(width: 8),
                Text('Particulier'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 18),
                SizedBox(width: 8),
                Text('Entreprise'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab(List<WifiPlan> plans, String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: plans.length + 1, // +1 for custom amount
      itemBuilder: (context, index) {
        if (index == plans.length) {
          return _buildCustomAmountCard();
        }
        return _buildPlanCard(plans[index], index);
      },
    );
  }

  Widget _buildPlanCard(WifiPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final colors = [
      AppColors.modernTurquoise,
      AppColors.neonViolet,
      AppColors.electricBlue,
      AppColors.neonGreen,
      AppColors.warning,
      AppColors.neonPink,
    ];
    final color = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => _selectedPlanIndex = index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(isSelected ? 0.15 : 0.08),
                  Colors.white.withOpacity(isSelected ? 0.08 : 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? color : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getPlanIcon(plan.name),
                              color: color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: AppTextStyles.h6.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  plan.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${plan.price}',
                                style: AppTextStyles.h5.copyWith(
                                  color: color,
                                ),
                              ),
                              Text(
                                'GNF',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (isSelected) ...[
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.darkBorder),
                        const SizedBox(height: 16),

                        // Features
                        _buildFeature('Durée', '${plan.durationMinutes} minutes'),
                        _buildFeature('Appareils', '${plan.devices} appareil(s)'),
                        _buildFeature('Vitesse', 'Illimité'),

                        const SizedBox(height: 20),

                        NeonButton(
                          text: 'ACHETER CE FORFAIT',
                          icon: Icons.shopping_cart_outlined,
                          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                          glowColor: color,
                          onPressed: () => _purchasePlan(plan),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.neonGreen,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAmountCard() {
    final controller = TextEditingController();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppGradients.neonRainbow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant personnalisé',
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Payez le montant de votre choix',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: 5000',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.neonViolet,
                    ),
                    suffixText: 'GNF',
                    suffixStyle: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.neonVioletGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonViolet.withOpacity(0.4),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      final amount = int.tryParse(controller.text);
                      if (amount != null && amount >= 500) {
                        _purchaseCustomAmount(amount);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Minimum: 500 GNF',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('starter') || nameLower.contains('débutant')) {
      return Icons.rocket_launch;
    } else if (nameLower.contains('basic') || nameLower.contains('basique')) {
      return Icons.star_outline;
    } else if (nameLower.contains('premium')) {
      return Icons.diamond_outlined;
    } else if (nameLower.contains('ultimate') || nameLower.contains('illimité')) {
      return Icons.all_inclusive;
    } else if (nameLower.contains('business') || nameLower.contains('entreprise')) {
      return Icons.business_center;
    }
    return Icons.wifi;
  }

  void _purchasePlan(WifiPlan plan) {
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {'plan': plan},
    );
  }

  void _purchaseCustomAmount(int amount) {
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {'amount': amount},
    );
  }
}


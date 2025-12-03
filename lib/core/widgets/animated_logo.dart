// lib/core/widgets/animated_logo.dart
// ✨ BARRY WI-FI - Logo Animé Premium

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final bool enableGlow;
  final bool enable3DEffect;
  final Duration animationDuration;

  const AnimatedLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.enableGlow = true,
    this.enable3DEffect = true,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation 3D
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    // Pulsation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animation des ondes
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _rotationController,
            _pulseController,
            _waveController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ondes Wi-Fi animées
                  ...List.generate(3, (index) {
                    final delay = index * 0.3;
                    final animValue =
                        (_waveController.value + delay) % 1.0;
                    return Opacity(
                      opacity: (1 - animValue) * 0.6,
                      child: Container(
                        width: widget.size * (0.8 + animValue * 0.8),
                        height: widget.size * (0.8 + animValue * 0.8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.modernTurquoise,
                            width: 2 * (1 - animValue),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Effet glow
                  if (widget.enableGlow)
                    Container(
                      width: widget.size * 1.3,
                      height: widget.size * 1.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.neonViolet.withOpacity(0.3),
                            AppColors.neonViolet.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                  // Logo principal
                  Transform(
                    transform: widget.enable3DEffect
                        ? (Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_rotationController.value * 0.3 * math.pi)
                          ..rotateX(
                              math.sin(_rotationController.value * math.pi * 2) *
                                  0.1))
                        : Matrix4.identity(),
                    alignment: Alignment.center,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.neonViolet,
                            AppColors.electricBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonViolet.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackLogo();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        if (widget.showText) ...[
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                AppColors.modernTurquoise,
                AppColors.neonViolet,
                AppColors.electricBlue,
              ],
            ).createShader(bounds),
            child: Text(
              'BARRY WI-FI',
              style: AppTextStyles.logoText.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: AppColors.neonViolet.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.wifi,
            size: widget.size * 0.5,
            color: Colors.white,
          ),
          Positioned(
            bottom: widget.size * 0.15,
            child: Container(
              width: widget.size * 0.3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Logo simple avec glow
class GlowingLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const GlowingLogo({
    super.key,
    this.size = 80,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColors.neonViolet,
                AppColors.electricBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonViolet.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.wifi,
                  size: size * 0.5,
                  color: Colors.white,
                );
              },
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'BARRY WI-FI',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

// ⚡ Logo splash avec animation entrée
class SplashLogo extends StatefulWidget {
  final double size;
  final VoidCallback? onAnimationComplete;

  const SplashLogo({
    super.key,
    this.size = 160,
    this.onAnimationComplete,
  });

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _fadeController,
        _glowController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow animé
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: widget.size * (1.4 + _glowController.value * 0.2),
                      height: widget.size * (1.4 + _glowController.value * 0.2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.neonViolet
                                .withOpacity(0.3 * _glowController.value),
                            AppColors.electricBlue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Logo
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.neonViolet,
                        AppColors.electricBlue,
                        AppColors.modernTurquoise,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonViolet.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: widget.size,
                      height: widget.size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.wifi,
                          size: widget.size * 0.5,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// lib/screens/splash/splash_screen.dart
// ✨ BARRY WI-FI - Splash Screen 3D Animé Premium

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Contrôleurs d'animation
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _waveController;
  late AnimationController _particleController;
  late AnimationController _rotationController;
  late AnimationController _glowController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;

  bool _showLoadingBar = false;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Configuration du status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Rotation 3D
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Glow pulsation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Démarrer le logo
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));

    // Démarrer le texte
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));

    // Afficher la barre de chargement
    setState(() => _showLoadingBar = true);

    // Simuler le chargement
    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() => _loadingProgress = i / 100);
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // Naviguer vers la page suivante
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.splashGradient,
        ),
        child: Stack(
          children: [
            // Particules animées
            _buildParticles(),

            // Cercles décoratifs
            _buildDecorativeCircles(),

            // Contenu principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo 3D animé
                  _buildAnimatedLogo(),

                  const SizedBox(height: 32),

                  // Texte animé
                  _buildAnimatedText(),

                  const SizedBox(height: 48),

                  // Barre de chargement
                  if (_showLoadingBar) _buildLoadingBar(),
                ],
              ),
            ),

            // Version en bas
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildVersion(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(
            animation: _particleController.value,
          ),
        );
      },
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        // Cercle supérieur gauche
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonViolet.withOpacity(0.3),
                  AppColors.neonViolet.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Cercle inférieur droit
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.modernTurquoise.withOpacity(0.2),
                  AppColors.modernTurquoise.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _rotationController,
        _glowController,
        _waveController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ondes Wi-Fi
                ...List.generate(3, (index) {
                  final delay = index * 0.33;
                  final animValue = (_waveController.value + delay) % 1.0;
                  return Opacity(
                    opacity: (1 - animValue) * 0.5,
                    child: Container(
                      width: 160 + (animValue * 100),
                      height: 160 + (animValue * 100),
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

                // Glow effect
                Container(
                  width: 180 + (_glowController.value * 20),
                  height: 180 + (_glowController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonViolet.withOpacity(0.4 * _glowController.value),
                        AppColors.neonViolet.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Logo principal avec rotation 3D
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(math.sin(_rotationController.value * math.pi * 2) * 0.2),
                  alignment: Alignment.center,
                  child: Container(
                    width: 140,
                    height: 140,
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
                        width: 140,
                        height: 140,
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
          ),
        );
      },
    );
  }

  Widget _buildFallbackLogo() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.wifi,
            size: 70,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlide.value),
          child: Opacity(
            opacity: _textOpacity.value,
            child: Column(
              children: [
                // Titre principal
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.modernTurquoise,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'BARRY WI-FI',
                    style: AppTextStyles.splash.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppColors.modernTurquoise.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Sous-titre
                Text(
                  'Connexion Ultra-Rapide',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBar() {
    return AnimatedOpacity(
      opacity: _showLoadingBar ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          children: [
            // Barre de progression
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  children: [
                    // Progression
                    FractionallySizedBox(
                      widthFactor: _loadingProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.modernTurquoise,
                              AppColors.neonViolet,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonViolet.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Texte de chargement
            Text(
              'Chargement... ${(_loadingProgress * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Column(
            children: [
              Text(
                'Powered by BARRY Tech',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white38,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 2.0 • 5G Premium',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Painter pour les particules
class _ParticlePainter extends CustomPainter {
  final double animation;
  final List<_Particle> particles;

  _ParticlePainter({required this.animation})
      : particles = List.generate(30, (index) => _Particle(index));

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final progress = (animation + particle.delay) % 1.0;
      final x = particle.x * size.width;
      final y = (particle.startY + progress * 1.5) % 1.0 * size.height;
      final opacity = (1 - progress) * particle.opacity;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

class _Particle {
  final double x;
  final double startY;
  final double size;
  final double opacity;
  final double delay;
  final Color color;

  _Particle(int index)
      : x = (index * 0.1 + math.sin(index * 0.5)) % 1.0,
        startY = (index * 0.15) % 1.0,
        size = 1.0 + (index % 3) * 0.5,
        opacity = 0.2 + (index % 5) * 0.1,
        delay = (index * 0.03) % 1.0,
        color = index % 2 == 0 ? AppColors.modernTurquoise : AppColors.neonViolet;
}


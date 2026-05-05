import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _exitController;

  // --- Animasi Logo ---
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;

  // --- Animasi Teks ---
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _subTaglineSlide;
  late Animation<double> _subTaglineOpacity;

  // --- Animasi Loading ---
  late Animation<double> _loadingOpacity;

  // --- Animasi Exit ---
  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Logo: Muncul dengan efek elastis & sedikit rotasi
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // 2. Teks: Muncul dari bawah secara bertahap (staggered)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _subTaglineSlide = Tween<Offset>(begin: const Offset(0, 15), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _subTaglineOpacity = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // 3. Loading: Fade in
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    // 4. Exit: Zoom out + Fade out
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Tahap 1: Logo muncul
    await _logoController.forward();

    // Tahap 2: Teks muncul
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();

    // Tahap 3: Loading muncul
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingController.forward();

    // Tahap 4: Tunggu proses pengecekan session
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(AppConstants.keyLoggedInUserId);

      if (!mounted) return;

      // Tahap 5: Animasi keluar
      await _exitController.forward();

      if (!mounted) return;

      // Navigasi dengan transisi custom
      Navigator.pushReplacement(
        context,
        SmoothPageTransition(
          userId != null ? const HomeScreen() : const LoginScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await _exitController.forward();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        SmoothPageTransition(const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Transform.scale(
            scale: _exitScale.value,
            child: Opacity(
              opacity: _exitOpacity.value,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0D47A1),
                      const Color(0xFF1565C0),
                      const Color(0xFF1976D2),
                    ],
                  ),
                ),
              ),
            ),

            // Partikel Mengambang
            ..._buildParticles(size),

            // Glow Effect di Belakang Logo
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, _) {
                  return Container(
                    width: 180 * _logoScale.value,
                    height: 180 * _logoScale.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.15 * _logoOpacity.value),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Konten Utama
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: _buildLogoContainer(),
                  ),

                  const SizedBox(height: 28),

                  // JUDUL APLIKASI
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: const Text(
                        'Survey Produk',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TAGLINE UTAMA
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: const Text(
                        'Verifikasi Distribusi',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xB3FFFFFF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // SUB-TAGLINE BADGE
                  FadeTransition(
                    opacity: _subTaglineOpacity,
                    child: SlideTransition(
                      position: _subTaglineSlide,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBadge('Akurat'),
                          const SizedBox(width: 8),
                          _buildDot(),
                          const SizedBox(width: 8),
                          _buildBadge('Cepat'),
                          const SizedBox(width: 8),
                          _buildDot(),
                          const SizedBox(width: 8),
                          _buildBadge('Terpercaya'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),

                  // LOADING INDICATOR
                  FadeTransition(
                    opacity: _loadingOpacity,
                    child: _buildLoadingDots(),
                  ),
                ],
              ),
            ),

            // Versi Aplikasi
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _loadingOpacity,
                child: const Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0x4DFFFFFF),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.assignment_turned_in_rounded,
        size: 50,
        color: Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xB3FFFFFF),
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0x66FFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return _AnimatedDot(index: index);
      }),
    );
  }

  List<Widget> _buildParticles(Size size) {
    final random = Random(42);
    return List.generate(20, (index) {
      return _FloatingParticle(
        size: 2 + random.nextDouble() * 5,
        left: random.nextDouble() * size.width,
        top: random.nextDouble() * size.height,
        duration: Duration(milliseconds: 2000 + random.nextInt(3000)),
        delay: random.nextDouble() * 1500,
      );
    });
  }
}

// ==========================================
// TRANSISI HALUS
// ==========================================
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition(this.page)
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 800),
    reverseTransitionDuration: const Duration(milliseconds: 800),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

// ==========================================
// WIDGET PARTIKEL
// ==========================================
class _FloatingParticle extends StatefulWidget {
  final double size;
  final double left;
  final double top;
  final Duration duration;
  final double delay;

  const _FloatingParticle({
    required this.size,
    required this.left,
    required this.top,
    required this.duration,
    required this.delay,
  });

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.delay.toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Positioned(
          left: widget.left,
          top: widget.top - (value * 30),
          child: Opacity(
            opacity: 0.05 + (sin(value * pi) * 0.15),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// WIDGET LOADING DOTS
// ==========================================
class _AnimatedDot extends StatefulWidget {
  final int index;
  const _AnimatedDot({required this.index});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    Future.delayed(
      Duration(milliseconds: widget.index * 200),
          () {
        if (mounted) _controller.repeat(reverse: true);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = _controller.value;
          return Container(
            width: 8 + (value * 6),
            height: 8,
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.8),
                value,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
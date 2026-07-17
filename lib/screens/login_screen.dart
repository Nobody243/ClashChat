import 'dart:math' as math;
// 'dart:ui' is unnecessary; symbols available via material.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../widgets/app_logo.dart';

//
// Palette  always dark, immune to app ThemeData
//
const _kBg = Color(0xFF0a0a0f);
const _kBorder = Color(0x33FFFFFF);
const _kHint = Color(0x80FFFFFF);
const _kSubtle = Color(0xB3FFFFFF);
const _kPurple = Color(0xFF7B4FA6);
const _kIndigo = Color(0xFF3D4ECA);
const _kGold = Color(0xFFC49A3C);
const _kCyan = Color(0xFF00D2FF);

//
// LOGIN SCREEN
//
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  bool _obscureLogin = true;
  bool _obscureSignup = true;

  final _loginEmail = TextEditingController();
  final _loginPass = TextEditingController();
  final _signupName = TextEditingController();
  final _signupEmail = TextEditingController();
  final _signupPass = TextEditingController();

  // Background blobs
  late final AnimationController _blob1;
  late final AnimationController _blob2;
  late final AnimationController _blob3;
  // Stars / particles
  late final AnimationController _stars;
  // Orbital ring spin
  late final AnimationController _ring;
  // Card gentle float
  late final AnimationController _float;
  // Logo pulse glow
  late final AnimationController _glow;

  late final List<_Star> _starList;

  @override
  void initState() {
    super.initState();

    _blob1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
    _blob2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 13),
    )..repeat(reverse: true);
    _blob3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 17),
    )..repeat(reverse: true);

    _stars = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _ring = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    final rng = math.Random(42);
    _starList = List.generate(60, (i) => _Star(rng));
  }

  @override
  void dispose() {
    _blob1.dispose();
    _blob2.dispose();
    _blob3.dispose();
    _stars.dispose();
    _ring.dispose();
    _float.dispose();
    _glow.dispose();
    _loginEmail.dispose();
    _loginPass.dispose();
    _signupName.dispose();
    _signupEmail.dispose();
    _signupPass.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final error = await AuthService.login(_loginEmail.text, _loginPass.text);
    if (!mounted) return;
    if (error == null) {
      // Create session on successful login
      await SessionService.createSession();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleSignup() async {
    // Validate inputs
    if (_signupEmail.text.isEmpty ||
        _signupPass.text.isEmpty ||
        _signupName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final email = _signupEmail.text.trim();
    final password = _signupPass.text.trim();
    final name = _signupName.text.trim();

    debugPrint('Starting signup for $email');
    final error = await AuthService.signUp(email, password, displayName: name);

    if (!mounted) {
      debugPrint('Widget unmounted, not navigating');
      return;
    }

    debugPrint('Signup result: ${error ?? "Success"}');

    if (error == null) {
      debugPrint('Signup successful, navigating to HomeScreen');
      // Clear the form
      _signupEmail.clear();
      _signupPass.clear();
      _signupName.clear();

      // Create session on successful signup
      await SessionService.createSession();

      // Navigate using pushAndRemoveUntil to ensure clean navigation
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      // Error - show dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _ThemedDialog(
            title: 'Signup Failed',
            content: error,
            actions: [('OK', null)],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _kBg,
          canvasColor: _kBg,
          colorScheme: ColorScheme.dark(
            surface: _kBg,
            onSurface: Colors.white,
            primary: _kPurple,
            onPrimary: Colors.white,
            secondary: _kIndigo,
            tertiary: _kGold,
          ),
        ),
        child: Scaffold(
          backgroundColor: _kBg,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              //  Layer 1: aurora blobs
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_blob1, _blob2, _blob3]),
                  builder: (_, _) => CustomPaint(
                    painter: _BackgroundPainter(
                      t1: _blob1.value,
                      t2: _blob2.value,
                      t3: _blob3.value,
                    ),
                  ),
                ),
              ),

              //  Layer 2: star field
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _stars,
                  builder: (_, _) => CustomPaint(
                    painter: _StarPainter(t: _stars.value, stars: _starList),
                  ),
                ),
              ),

              //  Layer 3: dark tint overlay (no BackdropFilter — breaks on web)
              Positioned.fill(
                child: ColoredBox(
                  color: Color(
                    0x66000000,
                  ), // 40% black tint keeps background dark
                ),
              ),

              //  Layer 4: orbiting ring behind the card
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _ring,
                    builder: (_, _) =>
                        CustomPaint(painter: _RingPainter(t: _ring.value)),
                  ),
                ),
              ),

              //  Layer 5: auth card (floating)
              SafeArea(
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (_, child) {
                    //final dy = math.sin(_float.value * math.pi) * 6.0;
                    final tiltY = math.sin(_float.value * math.pi) * 0.03;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0008)
                        ..rotateX(tiltY),
                      child: child,
                    );
                  },
                  child: Transform.translate(
                    offset: Offset.zero,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 32,
                        ),
                        child: _AuthCard(
                          tab: _tab,
                          onSwitchTab: (i) {
                            if (i != _tab) setState(() => _tab = i);
                          },
                          loginEmail: _loginEmail,
                          loginPass: _loginPass,
                          obscureLogin: _obscureLogin,
                          onToggleLogin: () =>
                              setState(() => _obscureLogin = !_obscureLogin),
                          signupName: _signupName,
                          signupEmail: _signupEmail,
                          signupPass: _signupPass,
                          obscureSignup: _obscureSignup,
                          onToggleSignup: () =>
                              setState(() => _obscureSignup = !_obscureSignup),
                          onLoginTap: _handleLogin,
                          onSignupTap: _handleSignup,
                          glowAnim: _glow,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// Background aurora painter
//
class _BackgroundPainter extends CustomPainter {
  final double t1, t2, t3;
  const _BackgroundPainter({
    required this.t1,
    required this.t2,
    required this.t3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _kBg,
    );

    void blob(double t, Color color, Alignment a, Alignment b, double radius) {
      final lerped = Alignment.lerp(a, b, _ease(t))!;
      final cx = size.width * ((lerped.x + 1) / 2);
      final cy = size.height * ((lerped.y + 1) / 2);
      final r = math.min(size.width, size.height) * radius;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.75),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // Single subtle purple radial glow top-center
    blob(
      t1,
      _kPurple,
      const Alignment(0.0, -0.9),
      const Alignment(0.0, -0.7),
      0.80,
    );
  }

  double _ease(double t) => t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.t1 != t1 || old.t2 != t2 || old.t3 != t3;
}

//
// Star data
//
class _Star {
  final double x, y, size, speed, phase, opacity;
  _Star(math.Random rng)
    : x = rng.nextDouble(),
      y = rng.nextDouble(),
      size = 0.8 + rng.nextDouble() * 2.0,
      speed = 0.3 + rng.nextDouble() * 0.7,
      phase = rng.nextDouble(),
      opacity = 0.3 + rng.nextDouble() * 0.5;
}

//
// Star field painter  twinkle effect
//
class _StarPainter extends CustomPainter {
  final double t;
  final List<_Star> stars;
  const _StarPainter({required this.t, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (final s in stars) {
      final twinkle = (math.sin((t + s.phase) * 2 * math.pi * s.speed) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: s.opacity * twinkle);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size * twinkle + 0.3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}

//
// Orbiting ring painter  drawn centred on screen
//
class _RingPainter extends CustomPainter {
  final double t;
  const _RingPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer slow ring
    _drawEllipseRing(
      canvas,
      cx,
      cy,
      rx: size.width * 0.62,
      ry: size.height * 0.22,
      tilt: -0.30,
      angle: t * 2 * math.pi,
      color: _kPurple.withValues(alpha: 0.20),
      strokeW: 1.0,
    );

    // Inner faster ring
    _drawEllipseRing(
      canvas,
      cx,
      cy,
      rx: size.width * 0.45,
      ry: size.height * 0.16,
      tilt: 0.20,
      angle: -t * 2 * math.pi * 1.4,
      color: _kIndigo.withValues(alpha: 0.20),
      strokeW: 0.8,
    );

    // Tiny cyan ring
    _drawEllipseRing(
      canvas,
      cx,
      cy,
      rx: size.width * 0.30,
      ry: size.height * 0.10,
      tilt: 0.50,
      angle: t * 2 * math.pi * 2.0,
      color: _kCyan.withValues(alpha: 0.18),
      strokeW: 0.6,
    );

    // Dot orbiting the outer ring
    _drawOrbitDot(
      canvas,
      cx,
      cy,
      rx: size.width * 0.62,
      ry: size.height * 0.22,
      tilt: -0.30,
      angle: t * 2 * math.pi,
      color: _kPurple,
      dotR: 4.0,
    );

    _drawOrbitDot(
      canvas,
      cx,
      cy,
      rx: size.width * 0.45,
      ry: size.height * 0.16,
      tilt: 0.20,
      angle: -t * 2 * math.pi * 1.4 + math.pi,
      color: _kCyan,
      dotR: 3.0,
    );
  }

  void _drawEllipseRing(
    Canvas canvas,
    double cx,
    double cy, {
    required double rx,
    required double ry,
    required double tilt,
    required double angle,
    required Color color,
    required double strokeW,
  }) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.transform(_mat4RotX(tilt).storage);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );
    canvas.restore();
  }

  void _drawOrbitDot(
    Canvas canvas,
    double cx,
    double cy, {
    required double rx,
    required double ry,
    required double tilt,
    required double angle,
    required Color color,
    required double dotR,
  }) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final x = rx * cosA;
    final rawY = ry * sinA;
    final cosTilt = math.cos(tilt);
    final y = rawY * cosTilt;

    // glow
    canvas.drawCircle(
      Offset(cx + x, cy + y),
      dotR * 3,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(Offset(cx + x, cy + y), dotR, Paint()..color = color);
  }

  Matrix4 _mat4RotX(double angle) {
    final c = math.cos(angle), s = math.sin(angle);
    return Matrix4(1, 0, 0, 0, 0, c, -s, 0, 0, s, c, 0, 0, 0, 0, 1);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

//
// Auth Card   3D-tilting glass panel
//
class _AuthCard extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onSwitchTab;
  final TextEditingController loginEmail, loginPass;
  final bool obscureLogin;
  final VoidCallback onToggleLogin;
  final TextEditingController signupName, signupEmail, signupPass;
  final bool obscureSignup;
  final VoidCallback onToggleSignup;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;
  final AnimationController glowAnim;

  const _AuthCard({
    required this.tab,
    required this.onSwitchTab,
    required this.loginEmail,
    required this.loginPass,
    required this.obscureLogin,
    required this.onToggleLogin,
    required this.signupName,
    required this.signupEmail,
    required this.signupPass,
    required this.obscureSignup,
    required this.onToggleSignup,
    required this.onLoginTap,
    required this.onSignupTap,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
          animation: glowAnim,
          builder: (_, child) {
            final glow = glowAnim.value; // 01 pulsing
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _kPurple.withValues(alpha: 0.08 + glow * 0.10),
                    blurRadius: 40 + glow * 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121216), // Solid dark surface
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF7F77DD).withValues(
                        alpha: 0.3 + glow * 0.4,
                      ), // Thin purple border
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 28, 0, 28),
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  Animated logo orb with Hero
              Hero(
                tag: 'app-logo',
                child: _LogoOrb(glowAnim: glowAnim),
              ),

              const SizedBox(height: 12),

              //  Gradient title
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFFDDB4FF), Colors.white, Color(0xFF93C5FD)],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(r),
                child: Text(
                  'ClashChat',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'WHERE EVERY WORD IS A WEAPON',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: _kHint,
                ),
              ),

              const SizedBox(height: 24),

              //  Toggle row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ToggleRow(active: tab, onSwitch: onSwitchTab),
              ),

              const SizedBox(height: 18),

              //  Form switcher
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.07),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: tab == 0
                      ? KeyedSubtree(
                          key: const ValueKey('login'),
                          child: _LoginForm(
                            emailCtrl: loginEmail,
                            passCtrl: loginPass,
                            obscure: obscureLogin,
                            onToggle: onToggleLogin,
                            onSubmit: onLoginTap,
                          ),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('signup'),
                          child: _SignupForm(
                            nameCtrl: signupName,
                            emailCtrl: signupEmail,
                            passCtrl: signupPass,
                            obscure: obscureSignup,
                            onToggle: onToggleSignup,
                            onSubmit: onSignupTap,
                          ),
                        ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 900.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.90, 0.90),
          end: const Offset(1.00, 1.00),
          delay: 200.ms,
          duration: 700.ms,
          curve: Curves.easeOutBack,
        );
  }
}

//
// Logo orb  spinning ring + pulsing glow
//
class _LogoOrb extends StatelessWidget {
  final AnimationController glowAnim;
  const _LogoOrb({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, _) {
        final g = glowAnim.value;
        return SizedBox(
          width: 88,
          height: 88,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kPurple.withValues(alpha: 0.45 + g * 0.25),
                      blurRadius: 20 + g * 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Orb body
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const AppLogoWidget(size: 72),
              ),
              // Rotating arc
              Transform.rotate(
                angle: glowAnim.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(88, 88),
                  painter: _ArcPainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Colors.transparent, _kCyan, Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(r, r), radius: r));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(r, r), radius: r - 1),
      0,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

//
// Toggle row
//
class _ToggleRow extends StatelessWidget {
  final int active;
  final ValueChanged<int> onSwitch;
  const _ToggleRow({required this.active, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleBtn(
            label: 'Sign In',
            active: active == 0,
            onTap: () => onSwitch(0),
          ),
          _ToggleBtn(
            label: 'Create Account',
            active: active == 1,
            onTap: () => onSwitch(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kPurple, _kIndigo],
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _kPurple.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : _kHint,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

//
// Sign-in form
//
class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure;
  final VoidCallback onToggle, onSubmit;

  const _LoginForm({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DarkField(
            ctrl: emailCtrl,
            label: 'EMAIL',
            hint: 'you@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _DarkField(
            ctrl: passCtrl,
            label: 'PASSWORD',
            hint: '',
            icon: Icons.lock_outline_rounded,
            obscure: obscure,
            onToggle: onToggle,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kGold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _CTA(label: 'Sign In', onTap: onSubmit),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final result = await AuthService.signInWithGoogle();
              if (result != null) {
                // Create session on successful Google sign-in
                await SessionService.createSession();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google sign in failed. Try again.'),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                border: Border.all(color: const Color(0xFF2A2A35), width: 1.0),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/google_icon.png', height: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// Sign-up form
//
class _SignupForm extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl, passCtrl;
  final bool obscure;
  final VoidCallback onToggle, onSubmit;

  const _SignupForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DarkField(
            ctrl: nameCtrl,
            label: 'FULL NAME',
            hint: 'Your name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _DarkField(
            ctrl: emailCtrl,
            label: 'EMAIL',
            hint: 'you@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _DarkField(
            ctrl: passCtrl,
            label: 'PASSWORD',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: obscure,
            onToggle: onToggle,
          ),
          const SizedBox(height: 24),
          _CTA(label: 'Join Debate', onTap: onSubmit),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final result = await AuthService.signInWithGoogle();
              if (result != null) {
                // Create session on successful Google sign-in
                await SessionService.createSession();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Google sign in failed. Try again.'),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kBg.withValues(alpha: 0.5),
                border: Border.all(color: _kBorder, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/google_icon.png', height: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// Dark text field
//
class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggle;
  final TextInputType? keyboardType;

  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggle,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: _kHint,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder.withValues(alpha: 0.1)),
          ),
          child: Center(
            child: TextFormField(
              controller: ctrl,
              obscureText: obscure,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: _kHint),
                prefixIcon: Icon(icon, size: 18, color: _kSubtle),
                suffixIcon: onToggle != null
                    ? IconButton(
                        onPressed: onToggle,
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: _kHint,
                        ),
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//
// CTA button  shimmer gradient
//
class _CTA extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CTA({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF7F77DD),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7F77DD).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Themed Dialog Widget
// ══════════════════════════════════════════════════════════
class _ThemedDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<(String, Color?)> actions;
  final Future<void> Function(int)? onActionSelected;

  const _ThemedDialog({
    required this.title,
    required this.content,
    required this.actions,
    // ignore: unused_element_parameter
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _kBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: List.generate(actions.length, (index) {
                final (label, color) = actions[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  child: TextButton(
                    onPressed: () async {
                      if (onActionSelected != null) {
                        await onActionSelected!(index);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: color ?? _kPurple,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

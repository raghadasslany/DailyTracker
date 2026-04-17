import 'dart:math';
import 'package:flutter/material.dart';

/// ─── Mood Monster ───────────────────────────────────────────────────────────
/// A cute, custom-painted blob monster for each mood.
/// Tapping triggers a bounce + emote animation (hearts, sparkles, etc.).
///
/// Supported moods: happy, good, meh, bad, awful
class MoodMonster extends StatefulWidget {
  final String mood;
  final double size;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback? onTap;

  const MoodMonster({
    super.key,
    required this.mood,
    this.size = 56,
    this.isSelected = false,
    this.showLabel = true,
    this.onTap,
  });

  @override
  State<MoodMonster> createState() => _MoodMonsterState();
}

class _MoodMonsterState extends State<MoodMonster>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _idleCtrl;
  late AnimationController _emoteCtrl;
  late Animation<double> _bounceAnim;
  late Animation<double> _idleAnim;

  final _rng = Random();
  List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Bounce on tap
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.85), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.08), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));

    // Idle breathing
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _idleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );

    // Emote particles
    _emoteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _idleCtrl.dispose();
    _emoteCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceCtrl.forward(from: 0);
    _spawnParticles();
    widget.onTap?.call();
  }

  void _spawnParticles() {
   
    _particles = List.generate(6, (i) {
      final angle = (i / 6) * pi * 2 + _rng.nextDouble() * 0.5;
      return _Particle(
        angle: angle,
        speed: 18 + _rng.nextDouble() * 14,
        size: 5 + _rng.nextDouble() * 5,
        delay: _rng.nextDouble() * 0.2,
      );
    });
    _emoteCtrl.forward(from: 0);
  }

  static const Map<String, Color> _moodColors = {
    'happy': Color(0xFF22c55e),
    'good': Color(0xFF3b82f6),
    'meh': Color(0xFFeab308),
    'bad': Color(0xFFf97316),
    'awful': Color(0xFFef4444),
  };

  static const Map<String, String> _moodLabels = {
    'happy': 'Happy',
    'good': 'Good',
    'meh': 'Meh',
    'bad': 'Bad',
    'awful': 'Awful',
  };

  @override
  Widget build(BuildContext context) {
    final color = _moodColors[widget.mood] ?? Colors.grey;
    final label = _moodLabels[widget.mood] ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceCtrl, _idleCtrl, _emoteCtrl]),
        builder: (context, child) {
          final bounceScale = _bounceCtrl.isAnimating ? _bounceAnim.value : 1.0;
          return SizedBox(
            width: widget.size + 24,
            height: widget.size + (widget.showLabel ? 24 : 8),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Emote particles
                if (_emoteCtrl.isAnimating)
                  ..._particles.map((p) {
                    final t = (_emoteCtrl.value - p.delay).clamp(0.0, 1.0);
                    final x = cos(p.angle) * p.speed * t;
                    final y = sin(p.angle) * p.speed * t - 8 * t;
                    final opacity = (1 - t).clamp(0.0, 1.0);
                    return Positioned(
                      left: (widget.size + 24) / 2 + x - p.size / 2,
                      top: widget.size / 2 + y - p.size / 2 - 4,
                      child: Opacity(
                        opacity: opacity,
                        child: _buildParticleIcon(p.size, color),
                      ),
                    );
                  }),

                // Monster body
                Positioned(
                  top: 0,
                  child: Transform.scale(
                    scale: bounceScale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected
                            ? color.withOpacity(0.15)
                            : Colors.transparent,
                        border: widget.isSelected
                            ? Border.all(color: color.withOpacity(0.5), width: 2)
                            : null,
                        boxShadow: widget.isSelected
                            ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 16, spreadRadius: 2)]
                            : [],
                      ),
                      child: CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _MonsterPainter(
                          mood: widget.mood,
                          color: color,
                          idlePhase: _idleAnim.value,
                          isSelected: widget.isSelected,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
                ),

                // Label
                if (widget.showLabel)
                  Positioned(
                    bottom: 0,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: widget.isSelected ? color : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticleIcon(double size, Color color) {
    // Different particle types per mood
    switch (widget.mood) {
      case 'happy':
        return Icon(Icons.favorite, size: size, color: color);
      case 'good':
        return Icon(Icons.star_rounded, size: size, color: color);
      case 'meh':
        return Icon(Icons.cloud, size: size, color: color);
      case 'bad':
        return Icon(Icons.water_drop, size: size, color: color);
      case 'awful':
        return Icon(Icons.bolt, size: size, color: color);
      default:
        return Icon(Icons.auto_awesome, size: size, color: color);
    }
  }
}

// ── Particle data ──────────────────────────────────────────────────────────
class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double delay;
  _Particle({required this.angle, required this.speed, required this.size, required this.delay});
}

// ── Monster Painter ────────────────────────────────────────────────────────
class _MonsterPainter extends CustomPainter {
  final String mood;
  final Color color;
  final double idlePhase; // 0..1
  final bool isSelected;
  final bool isDark;

  _MonsterPainter({
    required this.mood,
    required this.color,
    required this.idlePhase,
    required this.isSelected,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Idle breathing offset
    final breathe = sin(idlePhase * pi) * 1.5;
    final squish = 1.0 + sin(idlePhase * pi) * 0.03;

    canvas.save();
    canvas.translate(cx, cy + breathe);
    canvas.scale(1.0 / squish, squish);

    switch (mood) {
      case 'happy':
        _drawHappyMonster(canvas, r);
        break;
      case 'good':
        _drawGoodMonster(canvas, r);
        break;
      case 'meh':
        _drawMehMonster(canvas, r);
        break;
      case 'bad':
        _drawBadMonster(canvas, r);
        break;
      case 'awful':
        _drawAwfulMonster(canvas, r);
        break;
      default:
        _drawMehMonster(canvas, r);
    }

    canvas.restore();
  }

  // ── HAPPY: Round blob with tiny horns, big smile, rosy cheeks ──────
  void _drawHappyMonster(Canvas canvas, double r) {
    final bodyPaint = Paint()..color = color;
    final darkPaint = Paint()..color = const Color(0xFF0F172A);
    final whitePaint = Paint()..color = Colors.white;
    final rosyPaint = Paint()..color = color.withOpacity(0.35);
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.35);

    // Body
    canvas.drawCircle(Offset.zero, r, bodyPaint);

    // Highlight
    canvas.drawCircle(Offset(-r * 0.25, -r * 0.3), r * 0.18, highlightPaint);

    // Little horns
    final hornPath = Path();
    hornPath.moveTo(-r * 0.4, -r * 0.85);
    hornPath.lineTo(-r * 0.55, -r * 1.25);
    hornPath.lineTo(-r * 0.2, -r * 0.9);
    hornPath.close();
    canvas.drawPath(hornPath, bodyPaint);

    final hornPath2 = Path();
    hornPath2.moveTo(r * 0.4, -r * 0.85);
    hornPath2.lineTo(r * 0.55, -r * 1.25);
    hornPath2.lineTo(r * 0.2, -r * 0.9);
    hornPath2.close();
    canvas.drawPath(hornPath2, bodyPaint);

    // Horn tips
    final tipPaint = Paint()..color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(Offset(-r * 0.55, -r * 1.2), r * 0.06, tipPaint);
    canvas.drawCircle(Offset(r * 0.55, -r * 1.2), r * 0.06, tipPaint);

    // Eyes - big and sparkly
    final eyeR = r * 0.16;
    canvas.drawCircle(Offset(-r * 0.3, -r * 0.1), eyeR, whitePaint);
    canvas.drawCircle(Offset(r * 0.3, -r * 0.1), eyeR, whitePaint);
    canvas.drawCircle(Offset(-r * 0.3, -r * 0.1), eyeR * 0.6, darkPaint);
    canvas.drawCircle(Offset(r * 0.3, -r * 0.1), eyeR * 0.6, darkPaint);
    // Sparkle dots
    canvas.drawCircle(Offset(-r * 0.34, -r * 0.16), eyeR * 0.22, whitePaint);
    canvas.drawCircle(Offset(r * 0.26, -r * 0.16), eyeR * 0.22, whitePaint);

    // Rosy cheeks
    canvas.drawCircle(Offset(-r * 0.55, r * 0.15), r * 0.12, rosyPaint);
    canvas.drawCircle(Offset(r * 0.55, r * 0.15), r * 0.12, rosyPaint);

    // Wide smile
    final smilePath = Path();
    smilePath.moveTo(-r * 0.35, r * 0.2);
    smilePath.quadraticBezierTo(0, r * 0.6, r * 0.35, r * 0.2);
    canvas.drawPath(
      smilePath,
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..strokeCap = StrokeCap.round,
    );
    darkPaint.style = PaintingStyle.fill;

    // Tiny feet
    canvas.drawOval(Rect.fromCenter(center: Offset(-r * 0.35, r * 0.95), width: r * 0.3, height: r * 0.15), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.35, r * 0.95), width: r * 0.3, height: r * 0.15), bodyPaint);
  }

  // ── GOOD: Cat-ear blob, content smile, whiskers ───────────────────
  void _drawGoodMonster(Canvas canvas, double r) {
    final bodyPaint = Paint()..color = color;
    final darkPaint = Paint()..color = const Color(0xFF0F172A);
    final whitePaint = Paint()..color = Colors.white;
    final innerEarPaint = Paint()..color = Colors.white.withOpacity(0.3);
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.3);

    // Body
    canvas.drawCircle(Offset.zero, r, bodyPaint);
    canvas.drawCircle(Offset(-r * 0.2, -r * 0.25), r * 0.15, highlightPaint);

    // Cat ears
    final earL = Path();
    earL.moveTo(-r * 0.7, -r * 0.55);
    earL.lineTo(-r * 0.5, -r * 1.2);
    earL.lineTo(-r * 0.15, -r * 0.7);
    earL.close();
    canvas.drawPath(earL, bodyPaint);

    final earR = Path();
    earR.moveTo(r * 0.7, -r * 0.55);
    earR.lineTo(r * 0.5, -r * 1.2);
    earR.lineTo(r * 0.15, -r * 0.7);
    earR.close();
    canvas.drawPath(earR, bodyPaint);

    // Inner ears
    final iEarL = Path();
    iEarL.moveTo(-r * 0.6, -r * 0.6);
    iEarL.lineTo(-r * 0.5, -r * 1.0);
    iEarL.lineTo(-r * 0.25, -r * 0.7);
    iEarL.close();
    canvas.drawPath(iEarL, innerEarPaint);

    final iEarR = Path();
    iEarR.moveTo(r * 0.6, -r * 0.6);
    iEarR.lineTo(r * 0.5, -r * 1.0);
    iEarR.lineTo(r * 0.25, -r * 0.7);
    iEarR.close();
    canvas.drawPath(iEarR, innerEarPaint);

    // Eyes — calm, happy half-closed
    final eyeR = r * 0.13;
    canvas.drawCircle(Offset(-r * 0.28, -r * 0.05), eyeR, whitePaint);
    canvas.drawCircle(Offset(r * 0.28, -r * 0.05), eyeR, whitePaint);
    canvas.drawCircle(Offset(-r * 0.28, -r * 0.05), eyeR * 0.55, darkPaint);
    canvas.drawCircle(Offset(r * 0.28, -r * 0.05), eyeR * 0.55, darkPaint);
    canvas.drawCircle(Offset(-r * 0.31, -r * 0.1), eyeR * 0.2, whitePaint);
    canvas.drawCircle(Offset(r * 0.25, -r * 0.1), eyeR * 0.2, whitePaint);

    // Little nose
    final nosePath = Path();
    nosePath.moveTo(0, r * 0.08);
    nosePath.lineTo(-r * 0.06, r * 0.15);
    nosePath.lineTo(r * 0.06, r * 0.15);
    nosePath.close();
    canvas.drawPath(nosePath, Paint()..color = Colors.white.withOpacity(0.5));

    // Whiskers
    final whiskerPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(-r * 0.45, r * 0.1), Offset(-r * 0.85, r * 0.0), whiskerPaint);
    canvas.drawLine(Offset(-r * 0.45, r * 0.18), Offset(-r * 0.85, r * 0.2), whiskerPaint);
    canvas.drawLine(Offset(r * 0.45, r * 0.1), Offset(r * 0.85, r * 0.0), whiskerPaint);
    canvas.drawLine(Offset(r * 0.45, r * 0.18), Offset(r * 0.85, r * 0.2), whiskerPaint);

    // Gentle smile
    final smilePath = Path();
    smilePath.moveTo(-r * 0.2, r * 0.25);
    smilePath.quadraticBezierTo(0, r * 0.42, r * 0.2, r * 0.25);
    canvas.drawPath(
      smilePath,
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..strokeCap = StrokeCap.round,
    );
    darkPaint.style = PaintingStyle.fill;

    // Tiny feet
    canvas.drawOval(Rect.fromCenter(center: Offset(-r * 0.3, r * 0.95), width: r * 0.28, height: r * 0.14), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.3, r * 0.95), width: r * 0.28, height: r * 0.14), bodyPaint);
  }

  // ── MEH: Round blob with one floppy antenna, flat expression ──────
  void _drawMehMonster(Canvas canvas, double r) {
    final bodyPaint = Paint()..color = color;
    final darkPaint = Paint()..color = const Color(0xFF0F172A);
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.3);

    // Body — slightly squished
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 2.1, height: r * 1.9),
      bodyPaint,
    );
    canvas.drawCircle(Offset(-r * 0.2, -r * 0.22), r * 0.14, highlightPaint);

    // Floppy antenna
    final antennaPath = Path();
    antennaPath.moveTo(0, -r * 0.85);
    antennaPath.quadraticBezierTo(r * 0.3, -r * 1.4, r * 0.15, -r * 1.2);
    canvas.drawPath(
      antennaPath,
      bodyPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.1
        ..strokeCap = StrokeCap.round,
    );
    bodyPaint.style = PaintingStyle.fill;
    // Antenna ball
    canvas.drawCircle(Offset(r * 0.15, -r * 1.2), r * 0.12, bodyPaint);
    canvas.drawCircle(Offset(r * 0.15, -r * 1.2), r * 0.06, whitePaint);

    // Second small antenna
    final ant2 = Path();
    ant2.moveTo(-r * 0.15, -r * 0.85);
    ant2.quadraticBezierTo(-r * 0.4, -r * 1.15, -r * 0.25, -r * 1.05);
    canvas.drawPath(
      ant2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(-r * 0.25, -r * 1.05), r * 0.08, bodyPaint);

    // Eyes — half-lidded
    final eyeR = r * 0.14;
    canvas.drawCircle(Offset(-r * 0.3, -r * 0.05), eyeR, whitePaint);
    canvas.drawCircle(Offset(r * 0.3, -r * 0.05), eyeR, whitePaint);
    canvas.drawCircle(Offset(-r * 0.3, 0), eyeR * 0.5, darkPaint);
    canvas.drawCircle(Offset(r * 0.3, 0), eyeR * 0.5, darkPaint);
    // Eyelids
    canvas.drawArc(
      Rect.fromCircle(center: Offset(-r * 0.3, -r * 0.05), radius: eyeR),
      -pi, pi, true,
      Paint()..color = color,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(r * 0.3, -r * 0.05), radius: eyeR),
      -pi, pi, true,
      Paint()..color = color,
    );
    canvas.drawCircle(Offset(-r * 0.33, -r * 0.02), eyeR * 0.18, whitePaint);
    canvas.drawCircle(Offset(r * 0.27, -r * 0.02), eyeR * 0.18, whitePaint);

    // Flat mouth
    canvas.drawLine(
      Offset(-r * 0.2, r * 0.3),
      Offset(r * 0.2, r * 0.3),
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..strokeCap = StrokeCap.round,
    );
    darkPaint.style = PaintingStyle.fill;

    // Tiny feet
    canvas.drawOval(Rect.fromCenter(center: Offset(-r * 0.35, r * 0.9), width: r * 0.28, height: r * 0.14), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.35, r * 0.9), width: r * 0.28, height: r * 0.14), bodyPaint);
  }

  // ── BAD: Ghost-shaped droopy blob, worried eyes ───────────────────
  void _drawBadMonster(Canvas canvas, double r) {
    final bodyPaint = Paint()..color = color;
    final darkPaint = Paint()..color = const Color(0xFF0F172A);
    final whitePaint = Paint()..color = Colors.white;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.25);

    // Ghost-like body — round top, wavy bottom
    final body = Path();
    body.addArc(Rect.fromCircle(center: Offset(0, -r * 0.1), radius: r), pi, pi);
    body.lineTo(r, r * 0.6);
    body.quadraticBezierTo(r * 0.65, r * 0.35, r * 0.35, r * 0.65);
    body.quadraticBezierTo(r * 0.15, r * 0.4, 0, r * 0.7);
    body.quadraticBezierTo(-r * 0.15, r * 0.4, -r * 0.35, r * 0.65);
    body.quadraticBezierTo(-r * 0.65, r * 0.35, -r, r * 0.6);
    body.close();
    canvas.drawPath(body, bodyPaint);

    // Highlight
    canvas.drawCircle(Offset(-r * 0.25, -r * 0.35), r * 0.14, highlightPaint);

    // Floppy ears
    final earL = Path();
    earL.moveTo(-r * 0.6, -r * 0.6);
    earL.quadraticBezierTo(-r * 1.0, -r * 0.3, -r * 0.75, -r * 0.15);
    canvas.drawPath(
      earL,
      bodyPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.15
        ..strokeCap = StrokeCap.round,
    );
    bodyPaint.style = PaintingStyle.fill;

    final earR = Path();
    earR.moveTo(r * 0.6, -r * 0.6);
    earR.quadraticBezierTo(r * 1.0, -r * 0.3, r * 0.75, -r * 0.15);
    canvas.drawPath(
      earR,
      bodyPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.15
        ..strokeCap = StrokeCap.round,
    );
    bodyPaint.style = PaintingStyle.fill;

    // Worried eyes — big round with raised brows
    final eyeR = r * 0.15;
    canvas.drawCircle(Offset(-r * 0.28, -r * 0.15), eyeR, whitePaint);
    canvas.drawCircle(Offset(r * 0.28, -r * 0.15), eyeR, whitePaint);
    canvas.drawCircle(Offset(-r * 0.28, -r * 0.12), eyeR * 0.55, darkPaint);
    canvas.drawCircle(Offset(r * 0.28, -r * 0.12), eyeR * 0.55, darkPaint);
    canvas.drawCircle(Offset(-r * 0.31, -r * 0.17), eyeR * 0.2, whitePaint);
    canvas.drawCircle(Offset(r * 0.25, -r * 0.17), eyeR * 0.2, whitePaint);

    // Worried brows
    canvas.drawLine(
      Offset(-r * 0.42, -r * 0.38),
      Offset(-r * 0.15, -r * 0.32),
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(r * 0.42, -r * 0.38),
      Offset(r * 0.15, -r * 0.32),
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round,
    );
    darkPaint.style = PaintingStyle.fill;

    // Worried mouth
    final frownPath = Path();
    frownPath.moveTo(-r * 0.2, r * 0.2);
    frownPath.quadraticBezierTo(0, r * 0.08, r * 0.2, r * 0.2);
    canvas.drawPath(
      frownPath,
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06
        ..strokeCap = StrokeCap.round,
    );
    darkPaint.style = PaintingStyle.fill;
  }

  // ── AWFUL: Spiky upset blob with X eyes and tiny tears ────────────
  void _drawAwfulMonster(Canvas canvas, double r) {
    final bodyPaint = Paint()..color = color;
    final darkPaint = Paint()..color = const Color(0xFF0F172A);
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.2);
    final tearPaint = Paint()..color = const Color(0xFF93C5FD);

    // Body
    canvas.drawCircle(Offset.zero, r, bodyPaint);
    canvas.drawCircle(Offset(-r * 0.22, -r * 0.28), r * 0.13, highlightPaint);

    // Spiky top
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + (i - 2) * 0.35;
      final baseX = cos(angle) * r * 0.7;
      final baseY = sin(angle) * r * 0.7;
      final tipX = cos(angle) * r * 1.25;
      final tipY = sin(angle) * r * 1.25;
      final spike = Path();
      final perpAngle = angle + pi / 2;
      final hw = r * 0.12;
      spike.moveTo(baseX + cos(perpAngle) * hw, baseY + sin(perpAngle) * hw);
      spike.lineTo(tipX, tipY);
      spike.lineTo(baseX - cos(perpAngle) * hw, baseY - sin(perpAngle) * hw);
      spike.close();
      canvas.drawPath(spike, bodyPaint);
    }

    // X eyes
    final xSize = r * 0.12;
    final strokePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-r * 0.3 - xSize, -r * 0.1 - xSize),
      Offset(-r * 0.3 + xSize, -r * 0.1 + xSize),
      strokePaint,
    );
    canvas.drawLine(
      Offset(-r * 0.3 + xSize, -r * 0.1 - xSize),
      Offset(-r * 0.3 - xSize, -r * 0.1 + xSize),
      strokePaint,
    );

    canvas.drawLine(
      Offset(r * 0.3 - xSize, -r * 0.1 - xSize),
      Offset(r * 0.3 + xSize, -r * 0.1 + xSize),
      strokePaint,
    );
    canvas.drawLine(
      Offset(r * 0.3 + xSize, -r * 0.1 - xSize),
      Offset(r * 0.3 - xSize, -r * 0.1 + xSize),
      strokePaint,
    );

    // Tiny tears
    canvas.drawCircle(Offset(-r * 0.45, r * 0.1), r * 0.06, tearPaint);
    canvas.drawCircle(Offset(r * 0.45, r * 0.1), r * 0.06, tearPaint);
    // Tear trails
    canvas.drawCircle(Offset(-r * 0.47, r * 0.22), r * 0.04, tearPaint);
    canvas.drawCircle(Offset(r * 0.47, r * 0.22), r * 0.04, tearPaint);

    // Angry/sad frown
    final frownPath = Path();
    frownPath.moveTo(-r * 0.25, r * 0.35);
    frownPath.quadraticBezierTo(0, r * 0.15, r * 0.25, r * 0.35);
    canvas.drawPath(
      frownPath,
      darkPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..strokeCap = StrokeCap.round,
    );
    darkPaint.style = PaintingStyle.fill;

    // Tiny feet
    canvas.drawOval(Rect.fromCenter(center: Offset(-r * 0.35, r * 0.95), width: r * 0.28, height: r * 0.14), bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(r * 0.35, r * 0.95), width: r * 0.28, height: r * 0.14), bodyPaint);
  }

  @override
  bool shouldRepaint(_MonsterPainter old) =>
      old.idlePhase != idlePhase ||
      old.isSelected != isSelected ||
      old.mood != mood ||
      old.isDark != isDark;
}

// ── Static mini monster for inline display (no animation) ──────────────────
class MiniMoodMonster extends StatelessWidget {
  final String mood;
  final double size;

  const MiniMoodMonster({super.key, required this.mood, this.size = 20});

  static const Map<String, Color> _moodColors = {
    'happy': Color(0xFF22c55e),
    'good': Color(0xFF3b82f6),
    'meh': Color(0xFFeab308),
    'bad': Color(0xFFf97316),
    'awful': Color(0xFFef4444),
  };

  @override
  Widget build(BuildContext context) {
    final color = _moodColors[mood] ?? Colors.grey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size(size, size),
      painter: _MonsterPainter(
        mood: mood,
        color: color,
        idlePhase: 0.5,
        isSelected: false,
        isDark: isDark,
      ),
    );
  }
}

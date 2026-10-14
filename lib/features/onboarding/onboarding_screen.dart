import 'package:flutter/material.dart';

import '../../design/tokens.dart';

/// OnboardingScreen — 8 layar ringkas (PRD §7 v1; chat-buddy v2 later).
/// Flow: hero → masalah → cara kerja → challenge pertama → kriteria harian
/// → notif permission → accessibility + pilih app → selesai.
/// Setiap halaman tak butuh persist per-step (tak ada jawaban; v2 chat-buddy
/// yang menambah input). onComplete dipanggil host untuk persist 'onboarded'.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  static const _last = 7;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ds.ink,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(), // wajib Next
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _Hero(),
                  _Problem(),
                  _HowItWorks(),
                  _PickChallenge(),
                  _DailyCriteria(),
                  _NotifPermission(),
                  _AccessibilityPermission(),
                  _Ready(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 28),
              child: Column(
                children: [
                  // dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (i) {
                      final active = i == _page;
                      return Container(
                        width: active ? 18 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: active ? Ds.ember : Ds.chrome.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Ds.ember,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Ds.rPill),
                        ),
                      ),
                      onPressed: () {
                        if (_page >= _last) {
                          widget.onComplete?.call();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: Text(
                        _page >= _last ? 'Start' : 'Next',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared scaffold untuk satu halaman onboarding.
class _Page extends StatelessWidget {
  const _Page(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // TANPA Spacer/Expanded: di dalam PageView (unbounded) — pitfall muslim-leveling
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _HlTitle extends StatelessWidget {
  const _HlTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Ds.ivory,
        fontSize: Ds.fontTitle + 4,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }
}

class _HlBody extends StatelessWidget {
  const _HlBody(this.text, {this.accent});
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: accent ?? Ds.chrome, fontSize: 16, height: 1.5),
    );
  }
}

// ── Pages ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 120),
      Center(child: Icon(Icons.local_fire_department_rounded, size: 96, color: Ds.ember)),
      SizedBox(height: 28),
      Center(
        child: _HlTitle('Earn your screen\ntime with your\nhealth.'),
      ),
      SizedBox(height: 20),
      Center(
        child: _HlBody('Move first. Scroll after.', accent: Ds.teal),
      ),
    ]);
  }
}

class _Problem extends StatelessWidget {
  const _Problem();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 48),
      _HlTitle('Your apps are free.\nYour health pays\nfor them.'),
      SizedBox(height: 20),
      _HlBody(
        'Hours disappear into TikTok, Instagram and games every day — '
        'without a single rep, step or deep breath to show for it.',
      ),
      SizedBox(height: 24),
      _Stat(number: '4h 37m', label: 'average daily phone time'),
      _Stat(number: '0', label: 'push-ups it required'),
    ]);
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 48),
      _HlTitle('How it works'),
      SizedBox(height: 24),
      _StepCard(icon: Icons.directions_run_rounded, title: 'Move', body: 'Complete health challenges — steps, push-ups, workouts, sleep.'),
      _StepCard(icon: Icons.paid_rounded, title: 'Earn', body: 'Every verified habit pays coins. Streaks multiply them.'),
      _StepCard(icon: Icons.lock_open_rounded, title: 'Unlock', body: 'Spend coins to open your apps. Out of coins? Back to the grind.'),
    ]);
  }
}

class _PickChallenge extends StatelessWidget {
  const _PickChallenge();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 48),
      _HlTitle('Pick your first\nchallenge'),
      SizedBox(height: 20),
      _ChallengePick(title: 'Fitness Starter', days: 21, badge: 'Free', highlight: true),
      _ChallengePick(title: 'Dopamine Detox', days: 7, badge: 'Premium', highlight: false),
      _ChallengePick(title: '10K Steps', days: 30, badge: 'Premium', highlight: false),
      _ChallengePick(title: 'Sleep Reset', days: 14, badge: 'Premium', highlight: false),
    ]);
  }
}

class _DailyCriteria extends StatelessWidget {
  const _DailyCriteria();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 48),
      _HlTitle('Daily criteria'),
      SizedBox(height: 20),
      _HlBody('Every day you complete the criteria counts. Miss a day? Your 2 shields cover you automatically.'),
      SizedBox(height: 24),
      _TierRow(tier: 'Bronze', detail: '15 push-ups + 15 squats', color: Colors.brown),
      _TierRow(tier: 'Silver', detail: '30 + 30 — pays the same coins', color: Colors.blueGrey),
      _TierRow(tier: 'Gold', detail: '50 + 50 — same coins, extra pride', color: Color(0xFFD4AF37)),
    ]);
  }
}

class _NotifPermission extends StatelessWidget {
  const _NotifPermission();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 60),
      Center(child: Icon(Icons.notifications_active_rounded, size: 72, color: Ds.teal)),
      SizedBox(height: 28),
      _HlTitle('Gentle nudges,\nnever spam'),
      SizedBox(height: 20),
      _HlBody('One reminder when your daily challenge is waiting. That is it.'),
    ]);
  }
}

class _AccessibilityPermission extends StatelessWidget {
  const _AccessibilityPermission();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 60),
      Center(child: Icon(Icons.lock_person_rounded, size: 72, color: Ds.ember)),
      SizedBox(height: 28),
      _HlTitle('App blocking'),
      SizedBox(height: 20),
      _HlBody(
        'Health Leveling uses Android Accessibility only to detect when a locked app opens — '
        'nothing is read or stored. Next screen: enable it in system settings, then pick the apps to lock.',
      ),
    ]);
  }
}

class _Ready extends StatelessWidget {
  const _Ready();

  @override
  Widget build(BuildContext context) {
    return const _Page([
      SizedBox(height: 140),
      Center(child: Icon(Icons.emoji_events_rounded, size: 88, color: Ds.teal)),
      SizedBox(height: 28),
      Center(child: _HlTitle("You're ready.")),
      SizedBox(height: 16),
      Center(child: _HlBody('Fitness Starter starts today. Day 1 begins now.')),
    ]);
  }
}

// ── Small pieces ────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              number,
              style: const TextStyle(color: Ds.ember, fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(label, style: const TextStyle(color: Ds.chrome, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Ds.rCard),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Ds.teal),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Ds.ivory, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: Ds.chrome, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengePick extends StatelessWidget {
  const _ChallengePick({required this.title, required this.days, required this.badge, required this.highlight});
  final String title;
  final int days;
  final String badge;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? Ds.ember.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Ds.rCard),
        border: highlight ? Border.all(color: Ds.ember, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title · $days days',
              style: const TextStyle(color: Ds.ivory, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badge == 'Free' ? Ds.teal : Ds.chrome.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.detail, required this.color});
  final String tier;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(tier, style: const TextStyle(color: Ds.ivory, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: Text(detail, style: const TextStyle(color: Ds.chrome, fontSize: 13))),
        ],
      ),
    );
  }
}

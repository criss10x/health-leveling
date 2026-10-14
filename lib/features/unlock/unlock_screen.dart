import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../engine/models.dart';

/// UnlockScreen — belanja koin untuk sesi unlock (PRD §4.2 + §6).
/// Pilih paket → konfirmasi → sesi aktif (service layer menulis registry + timer).
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key, required this.balance, this.onPurchase});

  final int balance;
  final void Function(UnlockPackage pkg)? onPurchase;

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ds.ivory,
      appBar: AppBar(
        backgroundColor: Ds.ivory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Ds.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Unlock screen time',
          style: TextStyle(color: Ds.ink, fontSize: Ds.fontTitle, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Ds.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${widget.balance} coins',
                style: const TextStyle(
                  color: Ds.teal,
                  fontSize: Ds.fontChip * 0.66,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final pkg in UnlockPackage.values)
            _PackageCard(
              pkg: pkg,
              affordable: widget.balance >= pkg.price,
              onTap: () => _confirm(context, pkg),
            ),
          if (widget.balance < UnlockPackage.m10.price) ...[
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Not enough coins',
                style: TextStyle(color: Ds.chrome, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirm(BuildContext context, UnlockPackage pkg) {
    if (widget.balance < pkg.price) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Ds.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Ds.rCard)),
        title: Text(
          'Unlock for ${pkg.minutesLabel}?',
          style: const TextStyle(color: Ds.ink, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Spend ${pkg.price} coins. The app unlocks for ${pkg.minutesLabel}, then locks again.',
          style: const TextStyle(color: Ds.chrome, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Ds.chrome)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Ds.ember, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onPurchase?.call(pkg);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unlocked for ${pkg.minutesLabel} — timer running')),
              );
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.pkg, required this.affordable, required this.onTap});

  final UnlockPackage pkg;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: affordable ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Ds.cardBg,
            borderRadius: BorderRadius.circular(Ds.rCard),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  pkg.minutesLabel,
                  style: const TextStyle(color: Ds.ink, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${pkg.price} coins',
                style: TextStyle(
                  color: affordable ? Ds.ember : Ds.chrome,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on UnlockPackage {
  String get minutesLabel => switch (this) {
        UnlockPackage.m10 => '10 minutes',
        UnlockPackage.m30 => '30 minutes',
        UnlockPackage.m60 => '1 hour',
      };
}

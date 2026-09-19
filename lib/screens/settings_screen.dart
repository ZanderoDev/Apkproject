import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Pengaturan',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Jaga data tetap aman dan aplikasi tetap nyaman.',
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          const GlassCard(
            color: AppTheme.crimson,
            child: Row(
              children: [
                Icon(Icons.shield_rounded, color: Colors.white, size: 38),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data lokal terlindungi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Buat backup rutin ke penyimpanan publik perangkat.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SettingsAction(
            icon: Icons.cloud_upload_outlined,
            title: 'Backup sekarang',
            subtitle: 'Simpan snapshot data ke Documents/PMRPuspa5_Backup',
            onTap: () => _run(context, true),
          ),
          const SizedBox(height: 10),
          _SettingsAction(
            icon: Icons.cloud_download_outlined,
            title: 'Restore dari backup',
            subtitle: 'Pulihkan backup terbaru yang tersimpan',
            onTap: () => _run(context, false),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tentang aplikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Absen PMR Puspa 5', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 5),
                Text('Versi 1.0.0 • Local-first attendance', style: TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, bool backup) async {
    try {
      final provider = context.read<AppProvider>();
      if (backup) {
        await provider.backup();
      } else {
        final shouldRestore = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Restore backup?'),
            content: const Text(
              'Data lokal saat ini akan diganti dengan backup terbaru. '
              'Pastikan backup yang dipilih memang milik aplikasi ini.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );
        if (shouldRestore != true) return;
        await provider.restore();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(backup ? 'Backup berhasil dibuat.' : 'Restore berhasil.'),
            backgroundColor: const Color(0xFF1BAA72),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Operasi penyimpanan gagal: $error')),
        );
      }
    }
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppTheme.crimson.withOpacity(.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppTheme.crimson),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        ),
      ),
    );
  }
}

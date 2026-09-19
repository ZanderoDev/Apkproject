import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Selamat pagi'
        : hour < 17
            ? 'Selamat siang'
            : 'Selamat malam';
    final date = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: provider.refresh,
        color: AppTheme.crimson,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PMR Puspa 5',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(date, style: const TextStyle(color: AppTheme.muted)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.crimson.withOpacity(.12),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppTheme.crimson,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GlassCard(
              color: AppTheme.crimson,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kehadiran hari ini',
                          style: TextStyle(color: Colors.white.withOpacity(.82)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.presentToday} / ${provider.members.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          provider.members.isEmpty
                              ? 'Tambahkan anggota untuk mulai'
                              : '${provider.absentToday} anggota belum absen',
                          style: TextStyle(color: Colors.white.withOpacity(.8)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    size: 70,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total anggota',
                    value: provider.members.length,
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF536DFE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Hadir',
                    value: provider.presentToday,
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF1BAA72),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Belum hadir',
                    value: provider.absentToday < 0 ? 0 : provider.absentToday,
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFFFF9F43),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Aksi cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.how_to_reg_rounded,
              title: 'Tap untuk absen',
              subtitle: 'Catat kehadiran anggota hari ini',
              onTap: () => _showAttendanceHint(context),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Tambah anggota',
              subtitle: 'Kelola data anggota PMR Puspa 5',
              onTap: () => _showMembersHint(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buka menu Absensi untuk mencatat kehadiran.')),
    );
  }

  void _showMembersHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buka menu Anggota untuk menambahkan data.')),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.crimson.withOpacity(.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.crimson),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

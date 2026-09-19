import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/member.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  int? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final members = provider.members;
    final selectedId =
        members.any((member) => member.id == _selectedMemberId) ? _selectedMemberId : null;
    final selected = selectedId == null
        ? null
        : members.firstWhere((member) => member.id == selectedId);
    final today = selected == null ? null : provider.todayFor(selected.id!);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Absensi',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Catat kehadiran dengan satu sentuhan.',
            style: TextStyle(color: AppTheme.muted),
          ),
          const SizedBox(height: 24),
          GlassCard(
            color: AppTheme.crimson,
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, d MMMM', 'id_ID').format(_now),
                  style: TextStyle(color: Colors.white.withOpacity(.8)),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm:ss').format(_now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (members.isEmpty)
            const GlassCard(
              child: Text(
                'Belum ada anggota. Tambahkan data anggota terlebih dahulu.',
                style: TextStyle(color: AppTheme.muted),
              ),
            )
          else ...[
            DropdownButtonFormField<int>(
              value: selectedId,
              decoration: const InputDecoration(
                labelText: 'Pilih anggota',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              items: members
                  .map(
                    (member) => DropdownMenuItem<int>(
                      value: member.id,
                      child: Text(member.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedMemberId = value),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: AppTheme.crimson.withOpacity(.1),
                    child: Text(
                      selected == null ? '?' : _initials(selected),
                      style: const TextStyle(
                        color: AppTheme.crimson,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected?.name ?? 'Pilih anggota',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selected == null
                              ? 'Data kehadiran akan tampil di sini'
                              : '${selected.className} • ${_statusText(today)}',
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ),
                  if (today?.checkIn != null)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1BAA72)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: selected == null || today?.checkIn != null
                        ? null
                        : () => _runAction(context, selected, true),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Absen Masuk'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: const Color(0xFF1BAA72),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: selected == null ||
                            today?.checkIn == null ||
                            today?.checkOut != null
                        ? null
                        : () => _runAction(context, selected, false),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Absen Keluar'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: AppTheme.crimson,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Member? member,
    bool checkIn,
  ) async {
    if (member?.id == null) return;
    try {
      final provider = context.read<AppProvider>();
      if (checkIn) {
        await provider.checkIn(member!.id!);
      } else {
        await provider.checkOut(member!.id!);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkIn ? 'Absen masuk tersimpan.' : 'Absen keluar tersimpan.'),
            backgroundColor: const Color(0xFF1BAA72),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan absensi: $error')),
        );
      }
    }
  }

  String _initials(Member member) {
    final parts = member.name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _statusText(dynamic attendance) {
    if (attendance == null) return 'Belum absen';
    if (attendance.checkOut != null) return 'Selesai';
    return 'Sedang hadir';
  }
}

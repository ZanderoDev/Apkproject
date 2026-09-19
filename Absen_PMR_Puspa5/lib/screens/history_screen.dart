import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../models/attendance.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final grouped = <String, List<Attendance>>{};
    for (final item in provider.attendance) {
      grouped.putIfAbsent(item.date, () => []).add(item);
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Jejak kehadiran tersimpan rapi.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Export CSV',
                onPressed: provider.attendance.isEmpty
                    ? null
                    : () => _export(context, provider),
                icon: const Icon(Icons.file_download_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (grouped.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Center(
                child: Column(
                  children: [
                    Lottie.asset('assets/lottie/empty.json', width: 110, height: 110),
                    SizedBox(height: 12),
                    Text('Belum ada riwayat', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text(
                      'Data akan muncul setelah anggota melakukan absensi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            )
          else
            ...grouped.entries.map(
              (entry) => _DaySection(date: entry.key, records: entry.value),
            ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, AppProvider provider) async {
    try {
      await provider.exportCsv();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV berhasil disimpan ke folder Documents.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: $error')),
        );
      }
    }
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.date, required this.records});
  final String date;
  final List<Attendance> records;

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(date);
    final day = parsed == null ? '-' : DateFormat('EEEE', 'id_ID').format(parsed);
    final dateLabel = parsed == null
        ? date
        : DateFormat('d MMMM', 'id_ID').format(parsed);
    final year = parsed?.year.toString() ?? '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.crimson,
                  ),
                ),
              ),
              Text(
                '$dateLabel $year',
                style: const TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        ...records.map((record) => _AttendanceTile(record: record)),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.record});
  final Attendance record;

  @override
  Widget build(BuildContext context) {
    String time(String? value) =>
        value == null ? '--:--' : DateFormat('HH:mm').format(DateTime.parse(value));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 46,
              decoration: BoxDecoration(
                color: record.checkIn == null ? Colors.orange : const Color(0xFF1BAA72),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.memberName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Kelas ${record.className}',
                    style: const TextStyle(color: AppTheme.text, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk ${time(record.checkIn)}  •  Keluar ${time(record.checkOut)}',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              record.checkOut == null ? Icons.timelapse_rounded : Icons.done_all_rounded,
              color: record.checkOut == null ? Colors.orange : const Color(0xFF1BAA72),
            ),
          ],
        ),
      ),
    );
  }
}

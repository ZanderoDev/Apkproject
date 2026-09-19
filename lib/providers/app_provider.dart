import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/attendance.dart';
import '../models/member.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _database = DatabaseHelper.instance;
  final StorageService _storage = StorageService();

  List<Member> members = [];
  List<Attendance> attendance = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> initialize() async {
    isLoading = true;
    try {
      await refresh();
    } catch (error) {
      errorMessage = 'Gagal memuat data: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    members = await _database.getMembers();
    attendance = await _database.getAttendance();
    notifyListeners();
  }

  List<Member> searchMembers(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return members;
    return members
        .where(
          (member) =>
              member.name.toLowerCase().contains(normalized) ||
              member.className.toLowerCase().contains(normalized),
        )
        .toList();
  }

  int get presentToday {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return attendance
        .where((item) => item.date == today && item.checkIn != null)
        .length;
  }

  int get absentToday => members.length - presentToday;

  Attendance? todayFor(int memberId) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (final item in attendance) {
      if (item.memberId == memberId && item.date == today) return item;
    }
    return null;
  }

  Future<void> saveMember({
    int? id,
    required String name,
    required String className,
    required String phone,
  }) async {
    final member = Member(
      id: id,
      name: name.trim(),
      className: className.trim(),
      phone: phone.trim(),
    );
    if (id == null) {
      await _database.insertMember(member);
    } else {
      await _database.updateMember(member);
    }
    await refresh();
    unawaited(_safeAutoBackup());
  }

  Future<void> removeMember(int id) async {
    await _database.deleteMember(id);
    await refresh();
    unawaited(_safeAutoBackup());
  }

  Future<void> checkIn(int memberId) async {
    await _database.markCheckIn(memberId, DateTime.now());
    await refresh();
    unawaited(_safeAutoBackup());
  }

  Future<void> checkOut(int memberId) async {
    await _database.markCheckOut(memberId, DateTime.now());
    await refresh();
    unawaited(_safeAutoBackup());
  }

  Future<void> backup() async {
    final path = await _database.createBackupJson();
    await _storage.backupJson(path);
  }

  Future<void> _safeAutoBackup() async {
    try {
      await backup();
    } catch (_) {
      // Local SQLite writes remain successful when storage is unavailable.
    }
  }

  Future<void> restore() async {
    final temp = await _database.createBackupJson();
    await _storage.restoreLatest(temp);
    final content = await _readFile(temp);
    await _database.restoreFromJson(content);
    await refresh();
  }

  Future<void> exportCsv() async {
    final rows = <List<String>>[
      ['Hari', 'Tanggal', 'Tahun', 'Nama Anggota', 'Kelas', 'Check In', 'Check Out'],
      ...attendance.map((item) {
        final parsedDate = DateTime.tryParse(item.date);
        return [
          parsedDate == null ? '-' : DateFormat('EEEE', 'id_ID').format(parsedDate),
          item.date,
          parsedDate?.year.toString() ?? '-',
          item.memberName,
          item.className,
          _formatTime(item.checkIn),
          _formatTime(item.checkOut),
        ];
      }),
    ];
    await _storage.exportCsv(const ListToCsvConverter().convert(rows));
  }

  String _formatTime(String? value) {
    if (value == null) return '-';
    return DateFormat('HH:mm').format(DateTime.tryParse(value) ?? DateTime.now());
  }

  Future<String> _readFile(String filePath) async {
    return File(filePath).readAsString();
  }
}

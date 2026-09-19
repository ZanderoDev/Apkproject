import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/attendance.dart';
import '../models/member.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, 'pmr_puspa5.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            class_name TEXT NOT NULL,
            phone TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            member_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            check_in TEXT,
            check_out TEXT,
            UNIQUE(member_id, date),
            FOREIGN KEY(member_id) REFERENCES members(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<Member>> getMembers() async {
    final rows = await (await database).query('members', orderBy: 'name COLLATE NOCASE');
    return rows.map(Member.fromMap).toList();
  }

  Future<int> insertMember(Member member) async {
    return (await database).insert('members', member.toMap());
  }

  Future<void> updateMember(Member member) async {
    await (await database).update(
      'members',
      member.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> deleteMember(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('attendance', where: 'member_id = ?', whereArgs: [id]);
      await txn.delete('members', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Attendance>> getAttendance({String? date}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT attendance.*, members.name AS member_name,
        members.class_name AS class_name
      FROM attendance
      INNER JOIN members ON members.id = attendance.member_id
      ${date == null ? '' : 'WHERE attendance.date = ?'}
      ORDER BY attendance.date DESC, attendance.check_in DESC
    ''', date == null ? null : [date]);
    return rows.map(Attendance.fromMap).toList();
  }

  Future<void> markCheckIn(int memberId, DateTime time) async {
    final db = await database;
    final date = _date(time);
    await db.insert(
      'attendance',
      {
        'member_id': memberId,
        'date': date,
        'check_in': time.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> markCheckOut(int memberId, DateTime time) async {
    final db = await database;
    final date = _date(time);
    await db.update(
      'attendance',
      {'check_out': time.toIso8601String()},
      where: 'member_id = ? AND date = ?',
      whereArgs: [memberId, date],
    );
  }

  Future<String> createBackupJson() async {
    final members = await getMembers();
    final attendance = await getAttendance();
    final directory = await getTemporaryDirectory();
    final file = File(path.join(directory.path, 'pmr_puspa5_backup.json'));
    final json = jsonEncode({
      'schema': 1,
      'app': 'Absen PMR Puspa 5',
      'exported_at': DateTime.now().toIso8601String(),
      'members': members.map((item) => item.toMap()).toList(),
      'attendance': attendance.map((item) => item.toMap()).toList(),
    });
    await file.writeAsString(json);
    return file.path;
  }

  Future<void> restoreFromJson(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map || decoded['schema'] != 1) {
      throw const FormatException('Format backup tidak dikenali.');
    }
    final members = decoded['members'];
    final attendance = decoded['attendance'];
    if (members is! List || attendance is! List) {
      throw const FormatException('Data backup tidak lengkap.');
    }
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('attendance');
      await txn.delete('members');
      for (final raw in members) {
        if (raw is Map) {
          await txn.insert('members', Map<String, Object?>.from(raw)..remove('id'));
        }
      }
      for (final raw in attendance) {
        if (raw is Map) {
          await txn.insert(
            'attendance',
            Map<String, Object?>.from(raw)..remove('id'),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}


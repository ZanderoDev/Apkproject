import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  static const _channel = MethodChannel('pmr_puspa5/public_storage');

  Future<void> backupJson(String sourcePath) async {
    await _requestLegacyPermission();
    await _channel.invokeMethod<void>('backup', {
      'sourcePath': sourcePath,
      'fileName':
          'pmr_puspa5_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    });
  }

  Future<void> restoreLatest(String destinationPath) async {
    await _requestLegacyPermission();
    await _channel.invokeMethod<void>('restoreLatest', {
      'destinationPath': destinationPath,
    });
  }

  Future<void> exportCsv(String content) async {
    await _requestLegacyPermission();
    final directory = await getTemporaryDirectory();
    final source = File(
      '${directory.path}/pmr_puspa5_attendance_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await source.writeAsString(content);
    try {
      await _channel.invokeMethod<void>('exportCsv', {
        'sourcePath': source.path,
        'fileName':
            'pmr_puspa5_attendance_${DateTime.now().millisecondsSinceEpoch}.csv',
      });
    } finally {
      if (await source.exists()) await source.delete();
    }
  }

  Future<void> _requestLegacyPermission() async {
    if (!Platform.isAndroid) return;
    // Scoped storage on Android 10+ does not need broad storage permission.
    if (await _channel.invokeMethod<bool>('isScopedStorage') ?? true) return;
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw const StorageException(
        'Izin penyimpanan diperlukan untuk Android versi lama.',
      );
    }
  }
}

class StorageException implements Exception {
  const StorageException(this.message);
  final String message;

  @override
  String toString() => message;
}

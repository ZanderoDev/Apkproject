package com.pmr.puspa5

import android.content.ContentUris
import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "pmr_puspa5/public_storage"
    private val backupFolder = "${Environment.DIRECTORY_DOCUMENTS}/PMRPuspa5_Backup"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "isScopedStorage" -> result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                        "backup" -> {
                            writePublicFile(
                                call.argument<String>("sourcePath")!!,
                                call.argument<String>("fileName")!!,
                                "application/json"
                            )
                            result.success(null)
                        }
                        "exportCsv" -> {
                            writePublicFile(
                                call.argument<String>("sourcePath")!!,
                                call.argument<String>("fileName")!!,
                                "text/csv"
                            )
                            result.success(null)
                        }
                        "restoreLatest" -> {
                            restoreLatest(call.argument<String>("destinationPath")!!)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("STORAGE_ERROR", error.message, null)
                }
            }
    }

    private fun writePublicFile(sourcePath: String, fileName: String, mimeType: String) {
        val source = File(sourcePath)
        require(source.exists()) { "Sumber backup tidak ditemukan." }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Files.FileColumns.DISPLAY_NAME, fileName)
                put(MediaStore.Files.FileColumns.MIME_TYPE, mimeType)
                put(MediaStore.Files.FileColumns.RELATIVE_PATH, backupFolder)
                put(MediaStore.Files.FileColumns.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(
                MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
                values
            ) ?: error("Tidak dapat membuat file di Documents.")
            try {
                contentResolver.openOutputStream(uri)?.use { output ->
                    FileInputStream(source).use { input -> input.copyTo(output) }
                } ?: error("Tidak dapat membuka file tujuan.")
                values.clear()
                values.put(MediaStore.Files.FileColumns.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
            } catch (error: Exception) {
                contentResolver.delete(uri, null, null)
                throw error
            }
        } else {
            @Suppress("DEPRECATION")
            val folder = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS),
                "PMRPuspa5_Backup"
            )
            if (!folder.exists() && !folder.mkdirs()) error("Tidak dapat membuat folder backup.")
            FileOutputStream(File(folder, fileName)).use { output ->
                FileInputStream(source).use { input -> input.copyTo(output) }
            }
        }
    }

    private fun restoreLatest(destinationPath: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val projection = arrayOf(
                MediaStore.Files.FileColumns._ID,
                MediaStore.Files.FileColumns.DATE_ADDED
            )
            val selection = "${MediaStore.Files.FileColumns.RELATIVE_PATH} = ? AND " +
                "${MediaStore.Files.FileColumns.MIME_TYPE} = ?"
            val args = arrayOf(backupFolder + "/", "application/json")
            var newestId: Long? = null
            var newestDate = Long.MIN_VALUE
            contentResolver.query(collection, projection, selection, args, null)?.use { cursor ->
                val idIndex = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns._ID)
                val dateIndex = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATE_ADDED)
                while (cursor.moveToNext()) {
                    val date = cursor.getLong(dateIndex)
                    if (date > newestDate) {
                        newestDate = date
                        newestId = cursor.getLong(idIndex)
                    }
                }
            }
            val id = newestId ?: error("Belum ada backup yang tersedia.")
            val uri = ContentUris.withAppendedId(collection, id)
            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(File(destinationPath)).use { output -> input.copyTo(output) }
            } ?: error("Backup tidak dapat dibaca.")
        } else {
            @Suppress("DEPRECATION")
            val folder = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS),
                "PMRPuspa5_Backup"
            )
            val latest = folder.listFiles { file -> file.extension == "json" }
                ?.maxByOrNull { it.lastModified() }
                ?: error("Belum ada backup yang tersedia.")
            latest.inputStream().use { input ->
                FileOutputStream(File(destinationPath)).use { output -> input.copyTo(output) }
            }
        }
    }
}

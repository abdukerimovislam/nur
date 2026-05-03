import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecitationRecordingResult {
  const RecitationRecordingResult({
    required this.path,
    required this.duration,
  });

  final String path;
  final Duration duration;

  File get file => File(path);
}

class RecitationRecordingService {
  RecitationRecordingService();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool _isInitialized = false;
  bool _isRecording = false;
  DateTime? _startedAt;
  String? _currentPath;

  bool get isRecording => _isRecording;

  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      await _recorder.openRecorder();

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Recitation recorder init failed: $e');
      return false;
    }
  }

  Future<String?> start() async {
    try {
      final initialized = await init();
      if (!initialized) return null;

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/nur_recitation_$timestamp.aac';

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        sampleRate: 44100,
        numChannels: 1,
        bitRate: 128000,
      );

      _isRecording = true;
      _startedAt = DateTime.now();
      _currentPath = path;

      return path;
    } catch (e) {
      debugPrint('Recitation recording start failed: $e');
      _isRecording = false;
      _startedAt = null;
      _currentPath = null;
      return null;
    }
  }

  Future<RecitationRecordingResult?> stop() async {
    try {
      final startedAt = _startedAt;
      final fallbackPath = _currentPath;

      final path = await _recorder.stopRecorder();

      final resolvedPath = path ?? fallbackPath;

      _isRecording = false;
      _startedAt = null;
      _currentPath = null;

      if (resolvedPath == null) return null;

      final duration = startedAt == null
          ? Duration.zero
          : DateTime.now().difference(startedAt);

      return RecitationRecordingResult(
        path: resolvedPath,
        duration: duration,
      );
    } catch (e) {
      debugPrint('Recitation recording stop failed: $e');
      _isRecording = false;
      _startedAt = null;
      _currentPath = null;
      return null;
    }
  }

  Future<void> cancel() async {
    try {
      if (_isRecording) {
        await _recorder.stopRecorder();
      }
    } catch (e) {
      debugPrint('Recitation recording cancel failed: $e');
    } finally {
      _isRecording = false;
      _startedAt = null;
      _currentPath = null;
    }
  }

  Future<void> dispose() async {
    try {
      await cancel();
      if (_isInitialized) {
        await _recorder.closeRecorder();
      }
    } catch (e) {
      debugPrint('Recitation recorder dispose failed: $e');
    } finally {
      _isInitialized = false;
    }
  }
}
import 'dart:io';
import 'package:just_audio/just_audio.dart';

/// Service for audio playback.
/// 
/// Handles:
/// - Play, pause, stop, seek
/// - Position and duration tracking
/// - Volume control
/// - Playback state
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  
  /// Stream of playback state.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  
  /// Stream of position updates.
  Stream<Duration> get positionStream => _player.positionStream;
  
  /// Stream of duration updates.
  Stream<Duration?> get durationStream => _player.durationStream;
  
  /// Stream of buffered position.
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  
  /// Current playback state.
  PlayerState get playerState => _player.playerState;
  
  /// Whether audio is currently playing.
  bool get isPlaying => _player.playing;
  
  /// Current position.
  Duration get position => _player.position;
  
  /// Total duration.
  Duration? get duration => _player.duration;

  /// Load an audio file from path.
  Future<void> loadFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $filePath');
    }
    await _player.setFilePath(filePath);
  }

  /// Load audio from URL (for voice previews).
  Future<void> loadUrl(String url) async {
    await _player.setUrl(url);
  }

  /// Play audio.
  Future<void> play() async {
    await _player.play();
  }

  /// Pause audio.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop audio and reset position.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to a specific position.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set playback speed.
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  /// Seek relative to current position.
  Future<void> seekRelative(Duration offset) async {
    final newPosition = _player.position + offset;
    final clamped = newPosition < Duration.zero
        ? Duration.zero
        : (_player.duration != null && newPosition > _player.duration!
            ? _player.duration!
            : newPosition);
    await _player.seek(clamped);
  }

  /// Dispose the audio player.
  Future<void> dispose() async {
    await _player.dispose();
  }
}

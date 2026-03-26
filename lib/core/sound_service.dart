import 'package:audioplayers/audioplayers.dart';
import 'logger_service.dart';

/// [SoundService] gestiona la ambientación sonora de la aplicación.
/// Implementa efectos de sonido para interacciones y una música de fondo ligera.
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  // URLs de ejemplo para demostración inmediata (pueden ser reemplazados por assets locales)
  // URL de "Lofi Hip Hop Radio" (Zeno.fm) - Directa y estable
  static const String _bgMusicUrl = 'https://stream.zeno.fm/0r0xa792kwzuv';
  static const String _confirmSoundUrl = 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3';
  static const String _errorSoundUrl = 'https://assets.mixkit.co/active_storage/sfx/2558/2558-preview.mp3';

  bool _isMuted = false;
  bool _isMusicStarted = false;

  /// Inicia la música de fondo en bucle.
  Future<void> startBackgroundMusic() async {
    if (_isMusicStarted) return;
    try {
      _isMusicStarted = true;
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
      await _bgPlayer.setVolume(0.12); // Nivel elegante para chiptune
      LoggerService.i('SoundService - Retro Gamer Music iniciada (Local)');
    } catch (e) {
      _isMusicStarted = false;
      LoggerService.e('SoundService - Error al iniciar música: $e');
    }
  }

  /// Detiene la música de fondo.
  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  /// Reproduce un sonido de confirmación (Éxito).
  Future<void> playConfirmSound() async {
    if (_isMuted) return;
    try {
      await _effectPlayer.play(UrlSource(_confirmSoundUrl));
    } catch (e) {
      LoggerService.e('SoundService - Error al reproducir confirmación: $e');
    }
  }

  /// Reproduce un sonido de error.
  Future<void> playErrorSound() async {
    if (_isMuted) return;
    try {
      await _effectPlayer.play(UrlSource(_errorSoundUrl));
    } catch (e) {
      LoggerService.e('SoundService - Error al reproducir error: $e');
    }
  }

  /// Alterna el silencio global.
  void toggleMute() {
    _isMuted = !_isMuted;
    _bgPlayer.setVolume(_isMuted ? 0 : 0.15);
  }
}

// Global instance for easy access
final soundService = SoundService();

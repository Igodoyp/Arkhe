import 'dart:math' as math;
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

/// Servicio de audio para efectos de UI.
/// 
/// Responsable de:
/// - Precachear sonidos en memoria para latencia mínima (LoadMode.memory)
/// - Reproducir efectos con variación de pitch para "game feel"
/// - Manejo de polyphony (múltiples sonidos simultáneos)
/// - Fire-and-forget pattern (no bloqueamos UI esperando audio)
/// 
/// Estética: Digital Punk (Persona 5/Splatoon)
/// - ui_tap.wav: Toques de botón con pitch 0.96-1.06
/// - ui_success.wav: Completar misión con pitch 1.0-1.12
class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  final _logger = Logger('AudioService');
  final _random = math.Random();

  // AudioSources precacheadas
  AudioSource? _tapSound;
  AudioSource? _successSound;
  AudioSource? _slideSound;
  AudioSource? _confirmSound;

  // Estado de inicialización
  bool _isInitialized = false;
  bool get isReady => _isInitialized;

  AudioService._internal();

  /// Inicializa SoLoud y precachea los sonidos.
  /// 
  /// DEBE llamarse antes de runApp en main.dart:
  /// ```dart
  /// await AudioService.instance.init();
  /// ```
  Future<void> init() async {
    if (_isInitialized) {
      _logger.warning('AudioService ya estaba inicializado');
      return;
    }

    try {
      // 1. Inicializar motor de audio
      _logger.info('🔊 Inicializando SoLoud...');
      await SoLoud.instance.init();

      // 2. Precachear sonidos en memoria (LoadMode.memory = baja latencia)
      _logger.info('📦 Precacheando assets de audio...');
      
      _tapSound = await SoLoud.instance.loadAsset(
        'assets/audio/ui_tap.wav',
        mode: LoadMode.memory,
      );
      _logger.info('✅ ui_tap.wav cargado');

      _successSound = await SoLoud.instance.loadAsset(
        'assets/audio/ui_success.wav',
        mode: LoadMode.memory,
      );
      _logger.info('✅ ui_success.wav cargado');

      _slideSound = await SoLoud.instance.loadAsset(
        'assets/audio/ui_slide.wav',
        mode: LoadMode.memory,
      );
      _logger.info('✅ ui_slide.wav cargado');

      _confirmSound = await SoLoud.instance.loadAsset(
        'assets/audio/ui_confirm.wav',
        mode: LoadMode.memory,
      );
      _logger.info('✅ ui_confirm.wav cargado');

      _isInitialized = true;
      _logger.info('🎵 AudioService listo');
    } catch (e, stack) {
      _logger.severe('❌ Error al inicializar AudioService', e, stack);
      // No lanzamos excepción - la app debe seguir funcionando sin audio
      _isInitialized = false;
    }
  }

  /// Reproduce el sonido de tap con variación de pitch (0.96-1.06).
  /// 
  /// Usar en:
  /// - Todos los botones
  /// - Checkboxes/Switches
  /// - Navegación
  void playTap() {
    if (!_isInitialized || _tapSound == null) {
      _logger.fine('AudioService no inicializado, omitiendo playTap');
      return;
    }

    try {
      // Pitch variation: 0.96-1.06 (±6% de variación)
      final pitch = 0.96 + (_random.nextDouble() * 0.10);
      
      // Fire-and-forget: no esperamos el resultado
      SoLoud.instance.play(_tapSound!).then((handle) {
        SoLoud.instance.setRelativePlaySpeed(handle, pitch);
      }).catchError((e) {
        _logger.warning('Error al reproducir ui_tap: $e');
      });
    } catch (e) {
      _logger.warning('Error en playTap: $e');
    }
  }

  /// Reproduce el sonido de éxito con variación de pitch (1.0-1.12).
  /// 
  /// Usar en:
  /// - Completar misión
  /// - Subir de nivel
  /// - Desbloquear logro
  void playSuccess() {
    if (!_isInitialized || _successSound == null) {
      _logger.fine('AudioService no inicializado, omitiendo playSuccess');
      return;
    }

    try {
      // Pitch variation: 1.0-1.12 (0% a +12% para sonido más brillante)
      final pitch = 1.0 + (_random.nextDouble() * 0.12);
      
      // Fire-and-forget: no esperamos el resultado
      SoLoud.instance.play(_successSound!).then((handle) {
        SoLoud.instance.setRelativePlaySpeed(handle, pitch);
      }).catchError((e) {
        _logger.warning('Error al reproducir ui_success: $e');
      });
    } catch (e) {
      _logger.warning('Error en playSuccess: $e');
    }
  }

  /// Reproduce el sonido de deslizar/slide con variación de pitch (0.98-1.04).
  /// 
  /// Usar en:
  /// - Cambios de página en PageView
  /// - Deslizar entre slides
  /// - Navegación lateral
  void playSlide() {
    if (!_isInitialized || _slideSound == null) {
      _logger.fine('AudioService no inicializado, omitiendo playSlide');
      return;
    }

    try {
      // Pitch variation: 0.98-1.04 (±4% de variación, más sutil que tap)
      final pitch = 0.98 + (_random.nextDouble() * 0.06);
      
      // Fire-and-forget: no esperamos el resultado
      SoLoud.instance.play(_slideSound!).then((handle) {
        SoLoud.instance.setRelativePlaySpeed(handle, pitch);
      }).catchError((e) {
        _logger.warning('Error al reproducir ui_slide: $e');
      });
    } catch (e) {
      _logger.warning('Error en playSlide: $e');
    }
  }

  /// Reproduce el sonido de confirmación con variación de pitch (1.0-1.08).
  /// 
  /// Usar en:
  /// - Confirmar acción importante
  /// - Guardar cambios
  /// - Finalizar proceso
  void playConfirm() {
    if (!_isInitialized || _confirmSound == null) {
      _logger.fine('AudioService no inicializado, omitiendo playConfirm');
      return;
    }

    try {
      // Pitch variation: 1.0-1.08 (0% a +8% para sonido positivo)
      final pitch = 1.0 + (_random.nextDouble() * 0.08);
      
      // Fire-and-forget: no esperamos el resultado
      SoLoud.instance.play(_confirmSound!).then((handle) {
        SoLoud.instance.setRelativePlaySpeed(handle, pitch);
      }).catchError((e) {
        _logger.warning('Error al reproducir ui_confirm: $e');
      });
    } catch (e) {
      _logger.warning('Error en playConfirm: $e');
    }
  }

  /// Limpia recursos de audio.
  /// 
  /// Llamar en dispose() de la app si es necesario.
  void dispose() {
    if (!_isInitialized) return;

    try {
      _logger.info('🛑 Deteniendo AudioService...');
      SoLoud.instance.deinit();
      _isInitialized = false;
      _tapSound = null;
      _successSound = null;
      _logger.info('✅ AudioService detenido');
    } catch (e) {
      _logger.warning('Error al detener AudioService: $e');
    }
  }
}

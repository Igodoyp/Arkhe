// core/time/virtual_time_provider.dart

import 'time_provider.dart';
import 'date_time_extensions.dart';

/// Implementación de TimeProvider con tiempo virtual mutable.
/// Útil para testing y desarrollo del ciclo diario sin depender del reloj real.
/// 
/// El tiempo virtual se reinicia cada vez que se crea una nueva instancia.
/// Para testing multi-día, usa `advanceDays()` para simular el paso del tiempo.
class VirtualTimeProvider implements TimeProvider {
  DateTime _now;

  /// Crea un provider con el tiempo actual real como punto de partida.
  /// Para empezar en una fecha específica, usa [VirtualTimeProvider.fixed].
  VirtualTimeProvider() : _now = DateTime.now();

  /// Crea un provider con una fecha fija como punto de partida.
  VirtualTimeProvider.fixed(DateTime fixedNow) : _now = fixedNow;

  @override
  DateTime get now => _now;

  @override
  DateTime get todayStripped => _now.stripped;

  @override
  DateTime get yesterdayStripped => _now.subtract(const Duration(days: 1)).stripped;

  @override
  DateTime get tomorrowStripped => _now.add(const Duration(days: 1)).stripped;

  /// Avanza el tiempo virtual por el número de días especificado.
  /// Puede ser negativo para retroceder en el tiempo.
  void advanceDays(int days) {
    _now = _now.add(Duration(days: days));
    print('[VirtualTimeProvider] 📅 Tiempo avanzado $days día(s) → ${_now.stripped}');
  }

  /// Establece el tiempo virtual a una fecha específica.
  void setNow(DateTime newNow) {
    _now = newNow;
    print('[VirtualTimeProvider] 🕐 Tiempo establecido → ${_now.stripped}');
  }

  /// Reinicia el tiempo virtual al momento actual real.
  void reset() {
    _now = DateTime.now();
    print('[VirtualTimeProvider] 🔄 Tiempo reiniciado → ${_now.stripped}');
  }
}

# 🔥 BONFIRE QUICK START GUIDE

## ✅ Lo que se implementó

El sistema **Bonfire** está completamente implementado y listo para usar. Incluye:

### Archivos Creados/Modificados (10 archivos)

#### Domain Layer (3 archivos)
1. `lib/features/missions/domain/entities/day_feedback_entity.dart` - Entidad principal
2. `lib/features/missions/domain/repositories/day_feedback_repository.dart` - Contrato
3. `lib/features/missions/domain/usecases/day_feedback_usecase.dart` - 4 casos de uso

#### Data Layer (3 archivos)
4. `lib/features/missions/data/models/day_feedback_model.dart` - Modelo con serialización
5. `lib/features/missions/data/datasources/day_feedback_datasource.dart` - Datasource dummy
6. `lib/features/missions/data/repositories/day_feedback_repository_impl.dart` - Implementación

#### Presentation Layer (2 archivos)
7. `lib/features/missions/presentation/controllers/bonfire_controller.dart` - Controller
8. `lib/features/missions/presentation/pages/bonfire_page.dart` - UI completa

#### Integration (2 archivos modificados)
9. `lib/features/missions/presentation/controllers/day_session_controller.dart` - +método getBonfireData()
10. `lib/features/missions/presentation/pages/mission_page.dart` - Navegación a Bonfire

---

## 🚀 Cómo Probar el Sistema

### 1. Ejecutar la App

```powershell
cd d:\D0\d0
flutter run
```

### 2. Flujo de Usuario Completo

1. **Marca algunas misiones como completadas**
   - Toca los checkboxes de las misiones
   - Verás el contador actualizado

2. **Presiona "FINALIZAR DÍA"**
   - Botón rojo en la parte superior
   - Se calculan y aplican las stats

3. **Bonfire Screen aparece automáticamente**
   - Animación de entrada suave
   - Icono de fuego brillante

4. **Proporciona Feedback**
   - Selecciona dificultad (Muy Fácil → Muy Difícil)
   - Indica tu energía (1-5 círculos)
   - Marca misiones como fáciles/difíciles (opcional)
   - Agrega notas (opcional)

5. **Guarda el Feedback**
   - Presiona "GUARDAR Y CONTINUAR"
   - Verás pantalla de éxito
   - Presiona "VOLVER AL INICIO"

6. **Repite el proceso varios días**
   - Al tercer día verás el análisis de tendencias
   - Las recomendaciones aparecerán en el card azul

---

## 🧪 Verificar que Todo Funciona

### Check Console Output

Cuando uses la app, deberías ver logs como:

```
[BonfireController] 🔥 Inicializando Bonfire...
  - Session ID: session_2024_01_15
  - Misiones completadas: 3

[BonfireController] 📊 Análisis cargado: FeedbackAnalysis(...)

[BonfireController] 💾 Guardando feedback...
[DayFeedbackDataSource] ✅ Feedback guardado para sesión session_2024_01_15
  - Dificultad: Perfecto
  - Energía: 4/5
  - Misiones difíciles: 1
  - Misiones fáciles: 2
```

### Estados del Bonfire

1. **Inicial** → Cargando
2. **Ready** → Formulario listo
3. **Saving** → Guardando (spinner)
4. **Saved** → Pantalla de éxito
5. **Error** → Mensaje de error (si algo falla)

---

## 🎨 UI Preview

### Pantalla de Bonfire

```
┌─────────────────────────────────┐
│         🔥                      │
│       BONFIRE                   │
│  Descansa y reflexiona...       │
│                                 │
├─────────────────────────────────┤
│  Resumen del Día                │
│  ✓ Misiones Completadas: 3      │
│  📈 Stats Ganados: +15          │
├─────────────────────────────────┤
│  ¿Cómo fue la dificultad?       │
│  ○ Muy Fácil                    │
│  ◉ Perfecto                     │  ← Seleccionado
│  ○ Desafiante                   │
│  ○ Muy Difícil                  │
├─────────────────────────────────┤
│  ¿Cómo estuvo tu energía?       │
│  ① ② ③ ④ ⑤                     │
│     └─┴─┴─┴─┘                   │
│  Agotado ... Lleno de energía   │
├─────────────────────────────────┤
│  Marca las misiones...          │
│  [ Entrenar ] 😞 😊            │
│  [ Leer    ] 😞 😊            │
│  [ Meditar ] 😞 😊            │
├─────────────────────────────────┤
│  Notas adicionales              │
│  ┌───────────────────────────┐  │
│  │ Tuve mucho trabajo hoy... │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│  📊 Análisis de Tendencias      │
│  • Últimos 7 días analizados    │
│  • ¡Excelente equilibrio!       │
├─────────────────────────────────┤
│  [ GUARDAR Y CONTINUAR ]        │
│  [ Saltar feedback ]            │
└─────────────────────────────────┘
```

---

## 🔍 Testing Scenarios

### Escenario 1: Primera vez (sin historial)
- No verás el card de "Análisis de Tendencias"
- El prompt generado será genérico (usuario nuevo)

### Escenario 2: Después de 3 días
- Aparece el análisis con recomendaciones
- El multiplicador de dificultad se calcula
- El prompt incluye contexto del usuario

### Escenario 3: Energía baja consistente
- Reporta energía 1-2 por varios días
- El análisis recomendará reducir carga
- Multiplicador será < 1.0

### Escenario 4: Muy fácil consistente
- Selecciona "Muy Fácil" por varios días
- El análisis recomendará más desafío
- Multiplicador será > 1.0

---

## 📊 Generar Prompt para IA (Testing)

Si quieres ver cómo luce el prompt generado:

1. Abre `bonfire_controller.dart`
2. En el método `saveFeedback()`, agrega:

```dart
final prompt = await generateAIPrompt();
print('=== PROMPT PARA IA ===');
print(prompt);
print('=====================');
```

3. Después de guardar feedback, revisa la consola
4. Verás el prompt completo que se enviaría a Gemini

---

## 🐛 Troubleshooting

### "No se puede navegar a Bonfire"
- **Causa**: No hay misiones completadas
- **Solución**: Marca al menos una misión antes de "Finalizar Día"

### "Error al guardar feedback"
- **Causa**: Validación falla (energyLevel inválido)
- **Solución**: Verifica que el energyLevel esté entre 1-5

### "No aparece el análisis"
- **Causa**: No hay suficiente historial (< 3 días)
- **Solución**: Proporciona feedback por al menos 3 días

### "La navegación vuelve dos veces"
- **Causa**: `popUntil` regresa al inicio
- **Solución**: Esto es correcto, limpia el stack de navegación

---

## 🎯 Próximos Pasos Sugeridos

### Corto Plazo
1. **Probar el flujo completo** (3-5 días simulados)
2. **Verificar logs en consola** para debugging
3. **Experimentar con diferentes niveles** de dificultad/energía

### Mediano Plazo
1. **Integrar con Gemini API**
   - Usar el prompt generado
   - Crear misiones dinámicas

2. **Persistencia Real**
   - Reemplazar dummy datasource
   - Usar SharedPreferences o SQLite

3. **Tests**
   - Unit tests para use cases
   - Widget tests para BonfirePage

### Largo Plazo
1. **Visualización de Tendencias**
   - Gráfica de energía vs tiempo
   - Pie chart de dificultad

2. **Gamificación**
   - Logros por feedback consistente
   - Rachas de días en "flow"

3. **Machine Learning**
   - Predecir energía futura
   - Ajustar automáticamente dificultad

---

## 📝 Comandos Útiles

```powershell
# Ejecutar la app
flutter run

# Ver logs en tiempo real
flutter logs

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run

# Verificar errores
flutter analyze

# Formatear código
flutter format lib/
```

---

## 📚 Documentación Completa

Para más detalles, consulta:
- `BONFIRE_SYSTEM.md` - Documentación técnica completa
- `ARCHITECTURE_REVIEW.md` - Arquitectura general del proyecto
- `DAY_SESSION_FLOW.md` - Flujo de la sesión del día

---

## ✅ Checklist Final

Antes de marcar como completo, verifica:

- [x] Todos los archivos creados sin errores
- [x] Imports correctos en todos los archivos
- [x] Provider configurado para BonfireController
- [x] Navegación desde MissionsPage implementada
- [x] UI completamente funcional
- [x] Logs claros en consola
- [x] Documentación completa generada

---

**¡El sistema Bonfire está 100% listo para usar!** 🔥

Solo ejecuta `flutter run` y sigue el flujo de usuario descrito arriba.

Si encuentras algún bug o tienes ideas de mejora, ¡estoy aquí para ayudar! 🚀

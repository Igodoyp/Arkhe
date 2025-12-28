# BONFIRE (HOGUERA) - SISTEMA DE FEEDBACK ADAPTATIVO

## 📖 Visión General

El sistema **Bonfire** (Hoguera) es una característica inspirada en Dark Souls que permite al usuario proporcionar feedback sobre sus misiones diarias. Este feedback se utiliza para adaptar dinámicamente la dificultad y el tipo de misiones futuras, creando una experiencia personalizada y optimizada.

---

## 🎯 Objetivos

1. **Recopilar feedback del usuario** después de completar el día
2. **Analizar tendencias** en el desempeño y percepción del usuario
3. **Adaptar misiones futuras** basándose en el feedback histórico
4. **Generar prompts dinámicos** para IA (Gemini) que creen misiones personalizadas
5. **Mantener al usuario en estado de "flow"** (ni muy fácil, ni muy difícil)

---

## 🏗️ Arquitectura

### Clean Architecture en 3 Capas

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  - bonfire_page.dart        (UI hermosa tipo Dark Souls) │
│  - bonfire_controller.dart  (Estado y lógica de UI)      │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                        │
│  - day_feedback_entity.dart     (Entidad core)           │
│  - day_feedback_repository.dart (Contrato abstracto)     │
│  - day_feedback_usecase.dart    (4 casos de uso)         │
└─────────────────────────────────────────────────────────┘
                          ↓↑
┌─────────────────────────────────────────────────────────┐
│                       DATA LAYER                         │
│  - day_feedback_model.dart          (Serialización)      │
│  - day_feedback_datasource.dart     (Persistencia dummy) │
│  - day_feedback_repository_impl.dart (Implementación)    │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Componentes Implementados

### 1. Entidades de Dominio

#### `DayFeedback` Entity
Representa el feedback del usuario sobre un día completado.

**Propiedades:**
- `sessionId`: ID de la sesión del día
- `date`: Fecha del feedback
- `difficulty`: Nivel de dificultad percibido (`DifficultyLevel` enum)
- `energyLevel`: Nivel de energía del usuario (1-5)
- `struggledMissions`: IDs de misiones que fueron difíciles
- `easyMissions`: IDs de misiones que fueron fáciles
- `notes`: Notas adicionales del usuario (texto libre)

**Enums:**
- `DifficultyLevel`: `tooEasy`, `justRight`, `challenging`, `tooHard`

**Métodos útiles:**
- `hadLowEnergy`: Verifica si energía ≤ 2
- `needsMoreChallenge`: Verifica si dificultad fue muy fácil
- `needsLessLoad`: Verifica si necesita menos carga

---

### 2. Casos de Uso (Use Cases)

#### `SaveFeedbackUseCase`
Guarda el feedback del usuario con validaciones.

```dart
await saveFeedbackUseCase(feedback);
```

#### `GetFeedbackHistoryUseCase`
Obtiene el historial de feedbacks.

```dart
final allFeedbacks = await getFeedbackHistoryUseCase.getAllFeedbacks();
final recent = await getFeedbackHistoryUseCase.getRecentFeedbacks(7);
```

#### `AnalyzeFeedbackTrendsUseCase`
Analiza tendencias y genera recomendaciones.

```dart
final analysis = await analyzeFeedbackTrendsUseCase(lastDays: 7);
print(analysis.recommendations); // Lista de sugerencias
```

#### `GenerateAIPromptUseCase`
Genera un prompt dinámico para la IA basado en el feedback.

```dart
final prompt = await generateAIPromptUseCase(basedOnLastDays: 7);
// Prompt incluye: energía promedio, dificultad, misiones problemáticas, etc.
```

---

### 3. Controller (Presentation)

#### `BonfireController`
Gestiona el estado del formulario de feedback y coordina con los use cases.

**Estados:**
- `initial`: Inicializando
- `ready`: Listo para feedback
- `saving`: Guardando datos
- `saved`: Feedback guardado exitosamente
- `error`: Error al procesar

**Métodos principales:**
```dart
// Inicializar con datos de la sesión
await controller.initialize(
  sessionId: sessionId,
  completedMissionIds: missionIds,
);

// Actualizar formulario
controller.setDifficulty(DifficultyLevel.justRight);
controller.setEnergy(4);
controller.toggleStruggledMission(missionId);
controller.setNotes("Tuve mucho trabajo hoy");

// Guardar feedback
final success = await controller.saveFeedback();

// Generar prompt para IA
final prompt = await controller.generateAIPrompt();
```

---

### 4. UI (BonfirePage)

Pantalla hermosa inspirada en Dark Souls con:

1. **Header**: Icono de fuego animado + título "BONFIRE"
2. **Resumen del Día**: Misiones completadas y stats ganados
3. **Selector de Dificultad**: 4 opciones con descripciones
4. **Selector de Energía**: Escala visual 1-5
5. **Feedback por Misión**: Marcar misiones como fáciles o difíciles
6. **Notas Libres**: Campo de texto para comentarios adicionales
7. **Análisis de Tendencias**: Card opcional con recomendaciones
8. **Pantalla de Éxito**: Confirmación visual al guardar

**Tema Visual:**
- Fondo oscuro (#1a1a1a)
- Acentos en naranja (fuego)
- Animaciones suaves (fade-in)
- Tipografía bold con espaciado amplio

---

## 🔄 Flujo Completo de Usuario

### Paso a Paso

1. **Usuario completa misiones durante el día**
   - Marca misiones como completadas en `MissionsPage`
   - Las misiones se agregan a la sesión del día

2. **Usuario presiona "FINALIZAR DÍA"**
   - Se ejecuta `DaySessionController.endDay()`
   - Se calculan y aplican las stats ganadas
   - Se obtiene `BonfireData` con la sesión y misiones

3. **Navegación a Bonfire**
   - Se crea un `BonfireController` con todas las dependencias
   - Se navega a `BonfirePage` con los datos de la sesión
   - Se muestra animación de entrada

4. **Usuario proporciona feedback**
   - Selecciona nivel de dificultad
   - Indica su nivel de energía
   - Marca misiones como fáciles o difíciles (opcional)
   - Agrega notas (opcional)
   - Ve análisis de tendencias si existe historial

5. **Usuario guarda el feedback**
   - Se valida el formulario
   - Se crea entidad `DayFeedback`
   - Se guarda usando `SaveFeedbackUseCase`
   - Se muestra pantalla de éxito

6. **Retorno al inicio**
   - Usuario presiona "VOLVER AL INICIO"
   - Se navega de vuelta a `MissionsPage`
   - El feedback está guardado para análisis futuro

---

## 🧮 Lógica de Adaptación de Dificultad

### Multiplicadores por Nivel de Dificultad

| DifficultyLevel | Multiplicador | Significado |
|----------------|---------------|-------------|
| `tooEasy`      | 1.2           | +20% dificultad |
| `justRight`    | 1.0           | Sin cambio |
| `challenging`  | 0.9           | -10% dificultad |
| `tooHard`      | 0.7           | -30% dificultad |

### Ajuste por Energía

Si el promedio de energía < 3 en los últimos 7 días:
- Se aplica un multiplicador adicional de 0.9 (-10%)
- Esto reduce la carga para usuarios con baja energía consistente

### Cálculo del Ajuste Final

```dart
final avgDifficultyMultiplier = // Promedio de los multiplicadores de dificultad
final energyMultiplier = avgEnergy < 3 ? 0.9 : 1.0;
final finalAdjustment = avgDifficultyMultiplier * energyMultiplier;
```

**Ejemplo:**
- Usuario reportó 5 días `tooHard` (0.7) y 2 días `justRight` (1.0)
- Promedio: `(0.7*5 + 1.0*2) / 7 = 0.78`
- Energía promedio: 2.5 → multiplicador 0.9
- Ajuste final: `0.78 * 0.9 = 0.70` → Reducir dificultad un 30%

---

## 🤖 Generación de Prompt para IA

El sistema genera un prompt estructurado para Gemini que incluye:

### Contexto del Usuario
- Energía promedio (últimos N días)
- Nivel de dificultad percibido
- Tendencia actual (necesita más desafío, menos carga, equilibrado)

### Ajustes Requeridos
- Multiplicador de dificultad sugerido
- Razón del ajuste (energía baja, muy fácil, etc.)

### Patrones Identificados
- IDs de misiones problemáticas frecuentes
- IDs de misiones fáciles frecuentes

### Notas del Usuario
- Comentarios recientes del usuario

### Instrucciones para la IA
- Generar misiones ajustadas al nivel de energía
- Aplicar multiplicador de dificultad
- Evitar misiones problemáticas
- Mantener balance entre desafío y alcanzabilidad

**Formato del Prompt:**
```
# CONTEXTO DEL USUARIO
## Historial Reciente (últimos 7 días)
- Energía promedio: 3.5/5
- Nivel de dificultad percibido: Desafiante
- Tendencia: Usuario en equilibrio

## Ajustes Requeridos
- Multiplicador de dificultad sugerido: 0.95x
- Mantener nivel actual

## Misiones Problemáticas
- IDs frecuentes: mission_001, mission_005

## Misiones Fáciles
- IDs frecuentes: mission_002, mission_003

## Notas del Usuario
- Tuve mucho trabajo hoy
- Me sentí motivado

# INSTRUCCIONES PARA LA IA
[...]
```

---

## 📊 Análisis de Tendencias

El sistema puede analizar tendencias y generar recomendaciones:

### Métricas Calculadas
- Energía promedio (últimos N días)
- Distribución de niveles de dificultad
- Total de misiones problemáticas/fáciles mencionadas
- Multiplicador de dificultad sugerido

### Recomendaciones Automáticas

**Por energía baja (<2.5):**
- "Considera reducir la carga de misiones diarias"
- "Tu energía promedio es baja, prioriza el descanso"

**Por energía alta (>4.0):**
- "Tienes buena energía, podrías aumentar el desafío"

**Por dificultad:**
- Muy fácil (>50%): "Las misiones parecen demasiado fáciles, aumenta la dificultad"
- Muy difícil (>50%): "Las misiones son muy difíciles, reduce la complejidad"
- Perfecto (>60%): "¡Excelente! Has encontrado un buen equilibrio"

---

## 🚀 Próximos Pasos (Futuro)

### Integración con IA (Gemini)
1. Usar el prompt generado para crear misiones dinámicas
2. Llamar a Gemini API con el contexto del usuario
3. Parsear las misiones generadas
4. Actualizar el datasource con las nuevas misiones

### Análisis Avanzado
1. Detectar patrones en días específicos (lunes vs viernes)
2. Correlacionar energía con tipos de misiones
3. Predecir la energía futura del usuario
4. Sugerir descansos basados en tendencias

### Gamificación
1. Logros por consistencia en feedback
2. Racha de días con feedback proporcionado
3. "Maestro del Flow" - X días consecutivos en `justRight`

### Visualización
1. Gráfica de energía vs tiempo
2. Distribución de dificultad (pie chart)
3. Tendencias de misiones problemáticas/fáciles

---

## 🧪 Testing (Pendiente)

### Unit Tests
- `DayFeedback` entity helpers
- `DayFeedbackRepositoryImpl` cálculos
- Use cases validaciones

### Widget Tests
- `BonfirePage` UI rendering
- Form validation
- Navigation flow

### Integration Tests
- Flujo completo: EndDay → Bonfire → Save → Analysis

---

## 📝 Notas Importantes

1. **Datasource Dummy**: Actualmente usa almacenamiento en memoria. Para producción, implementar con SharedPreferences o SQLite.

2. **Provider Setup**: El `BonfireController` se crea dinámicamente en `MissionsPage` al navegar. Para apps más grandes, considerar usar un provider global.

3. **Validaciones**: El `energyLevel` debe estar entre 1-5 (validado en entity y use case).

4. **Inmutabilidad**: Todas las entidades son inmutables (usan `copyWith`).

5. **Logging**: Extenso logging en consola para debugging. Considerar usar un logger real en producción.

---

## 🎨 Personalización UI

Para personalizar los colores del Bonfire:

```dart
// En bonfire_page.dart
const bonfireBackground = Color(0xFF1a1a1a);  // Fondo oscuro
const bonfireAccent = Colors.orange;          // Color del fuego
const bonfireTextPrimary = Colors.white;
const bonfireTextSecondary = Colors.grey;
```

---

## 📚 Referencias

- **Inspiración**: Dark Souls Bonfire System
- **Teoría**: Flow State (Mihaly Csikszentmihalyi)
- **Arquitectura**: Clean Architecture (Robert C. Martin)
- **Estado**: Provider Pattern (Flutter)

---

## ✅ Checklist de Implementación

- [x] DayFeedback entity con enums y helpers
- [x] DayFeedbackModel con serialización JSON
- [x] DayFeedbackDataSource (dummy)
- [x] DayFeedbackRepository interface + implementation
- [x] 4 Use Cases (Save, History, Analyze, GeneratePrompt)
- [x] BonfireController con manejo de estado
- [x] BonfirePage UI completa
- [x] Integración con DaySessionController
- [x] Navegación desde MissionsPage
- [ ] Tests unitarios
- [ ] Tests de widgets
- [ ] Integración con Gemini API
- [ ] Persistencia real (SharedPreferences/SQLite)
- [ ] Análisis visual de tendencias

---

**Autor**: Sistema de Bonfire implementado como parte del sistema RPG Daily Missions  
**Versión**: 1.0  
**Fecha**: 2024

---

¡El Bonfire está listo para ayudar al usuario a alcanzar el estado de flow perfecto! 🔥

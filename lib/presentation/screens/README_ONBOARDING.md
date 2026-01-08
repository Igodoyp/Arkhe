# MVP Onboarding Screen - Documentación

## Ubicación
`lib/presentation/screens/onboarding_screen.dart`

## Características Implementadas

### Diseño
- **Background**: Pure Black (`Colors.black`)
- **Typography**: Space Mono (Google Fonts) para texto monospace/terminal
- **Estética**: Cyberpunk/Rebellion

### Navegación
- **PageView swipeable** con 3 slides
- **Dot indicators** en la parte inferior (indicador activo en Punk Red `#D72638`)
- Transición suave entre páginas

### Contenido de Slides

#### Slide 1: THE SYSTEM
- Icon: `Icons.visibility_off_outlined` (blanco, 120px)
- Título: "THE SYSTEM" (RansomNoteText)
- Body: "El algoritmo está diseñado para mantenerte dócil, distraído y consumiendo. Eres combustible para ellos."

#### Slide 2: THE GLITCH
- Widget: `GeoFlame(width: 180, height: 180, intensity: 0.8)`
- Título: "THE GLITCH" (RansomNoteText)
- Body: "Tu ambición es un error en su código. Arkhe es tu kit de sabotaje para recuperar tu atención."

#### Slide 3: TRUE SELF
- Icon: `Icons.fingerprint` (blanco, 120px)
- Título: "TRUE SELF" (RansomNoteText)
- Body: "Usa el fuego para quemar la niebla. Completa misiones. Escapa del promedio."
- **Botón**: "INICIAR REBELIÓN" (Punk Red `#D72638`, bordes cuadrados)

### Botón de Acción
- **Solo visible en el slide 3**
- Background: `#D72638` (Punk Red)
- Forma: Square corners (`BorderRadius.zero`)
- Texto: "INICIAR REBELIÓN" (Space Mono, bold, letter-spacing: 2)
- Acción: Navega a `/home` (MissionsPage) usando `pushReplacementNamed`

## Uso

### Navegación Directa
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
);
```

### Navegación con Ruta Nombrada (Recomendado)
Para usar esta pantalla, simplemente navega desde SplashPage o cualquier parte de la app que lo requiera:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
);
```

## Widgets Reutilizados
- `RansomNoteText`: Títulos con estilo ransom note
- `GeoFlame`: Animación de fuego geométrico en Slide 2

## Rutas Configuradas
- `/home` → `MissionsPage` (configurado en `main.dart`)

## Método Reutilizable
`_buildOnboardingPage()` acepta:
- `icon` (IconData) o `customWidget` (Widget)
- `title` (String) - renderizado con RansomNoteText
- `body` (String) - renderizado con Space Mono monospace

## Ejemplo de Testing
Para probar esta pantalla directamente sin pasar por el flujo de SplashPage, puedes modificar temporalmente `main.dart`:

```dart
// En RPGApp.build():
home: const OnboardingScreen(), // En lugar de SplashPage
```

## Notas de Implementación
- Los dot indicators cambian de tamaño (24px activo vs 8px inactivo) con animación implícita
- El botón solo aparece en la última página para evitar confusión
- Se usa `SizedBox(height: 104)` como spacer en páginas 1-2 para mantener altura consistente
- La paleta de RansomNoteText incluye: Punk Red, White, Cian (`#4AF2F5`)

# Cambiar el Icono de la Aplicación

## Pasos para cambiar el icono:

### 1. Preparar tu icono

- Crea un icono en formato PNG de 1024x1024 píxeles
- Guárdalo como `icon.png` en la carpeta `assets/icon/`
- El icono debe tener fondo transparente o sólido según tu preferencia

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Generar los iconos

```bash
flutter pub run flutter_launcher_icons:main
```

### 4. Reconstruir la aplicación

```bash
flutter clean
flutter pub get
flutter run
```

## Requisitos del icono:

- **Tamaño:** 1024x1024 píxeles (mínimo)
- **Formato:** PNG (recomendado)
- **Fondo:** Puede ser transparente o sólido
- **Estilo:** Simple y claro para verse bien en diferentes tamaños

## Archivos que se generarán automáticamente:

### Android:

- `android/app/src/main/res/mipmap-hdpi/launcher_icon.png`
- `android/app/src/main/res/mipmap-mdpi/launcher_icon.png`
- `android/app/src/main/res/mipmap-xhdpi/launcher_icon.png`
- `android/app/src/main/res/mipmap-xxhdpi/launcher_icon.png`
- `android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png`

### iOS:

- Varios archivos en `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Configuración personalizada:

En `pubspec.yaml`, puedes personalizar:

```yaml
flutter_launcher_icons:
  android: "launcher_icon" # Nombre del icono en Android
  ios: true # Generar para iOS
  image_path: "assets/icon/icon.png" # Ruta a tu icono
  min_sdk_android: 21 # SDK mínimo de Android
  web:
    generate: true
    image_path: "assets/icon/icon.png"
    background_color: "#FF6B6B" # Color de fondo para web
    theme_color: "#FF6B6B" # Color del tema
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
```

## Consejos de diseño:

1. **Simplicidad:** Los iconos simples se ven mejor en tamaños pequeños
2. **Contraste:** Usa colores que contrasten bien
3. **Identidad:** Debe representar tu aplicación (FoodApp = comida/restaurante)
4. **Consistencia:** Mantén el estilo consistente con tu aplicación

## Ejemplo de iconos para FoodApp:

- 🍽️ Plato con cubiertos
- 🍕 Pizza
- 🍔 Hamburguesa
- 🥘 Olla con comida
- 🏪 Restaurante
- 📱 Teléfono con comida

¡Usa el archivo `icon_template.svg` como base para crear tu propio icono!

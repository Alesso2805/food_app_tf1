# FoodApp - Clean Architecture Implementation

## Descripción

FoodApp es una aplicación Flutter que implementa Clean Architecture con una separación clara entre capas (data, domain, presentation) para una mejor organización del código.

## Arquitectura

### Clean Architecture

La aplicación sigue los principios de Clean Architecture propuestos por Robert C. Martin:

```
lib/
├── core/                           # Funcionalidades compartidas
│   ├── error/                      # Manejo de errores
│   ├── network/                    # Utilidades de red
│   └── usecases/                   # Base para casos de uso
├── features/                       # Características por módulos
│   ├── auth/                       # Autenticación
│   │   ├── data/                   # Capa de datos
│   │   │   ├── datasources/        # Fuentes de datos
│   │   │   ├── models/             # Modelos de datos
│   │   │   └── repositories/       # Implementación de repositorios
│   │   ├── domain/                 # Capa de dominio
│   │   │   ├── entities/           # Entidades
│   │   │   ├── repositories/       # Contratos de repositorios
│   │   │   └── usecases/          # Casos de uso
│   │   └── presentation/           # Capa de presentación
│   │       ├── bloc/               # Gestión de estado
│   │       └── pages/              # Páginas/Screens
│   ├── restaurants/                # Gestión de restaurantes
│   └── favorites/                  # Gestión de favoritos
└── injection_container.dart        # Inyección de dependencias
```

### Capas de la Arquitectura

#### 1. Capa de Dominio (Domain Layer)

- **Entities**: Objetos de negocio puros sin dependencias externas
- **Repositories**: Contratos/interfaces para acceso a datos
- **Use Cases**: Lógica de negocio específica

#### 2. Capa de Datos (Data Layer)

- **Models**: Modelos de datos con serialización JSON
- **Data Sources**: Fuentes de datos (API, Local Storage)
- **Repository Implementations**: Implementaciones concretas de los repositorios

#### 3. Capa de Presentación (Presentation Layer)

- **BLoC**: Gestión de estado usando patrón BLoC
- **Pages**: Interfaces de usuario
- **Widgets**: Componentes reutilizables

### Características Implementadas

#### Autenticación

- Login con email y contraseña
- Gestión de tokens JWT
- Validación de formularios

#### Gestión de Restaurantes

- Listado de restaurantes
- Detalles de restaurante
- Sistema de comentarios y calificaciones
- Integración con mapas y enlaces externos

#### Sistema de Favoritos

- Agregar/quitar restaurantes de favoritos
- Persistencia local con SharedPreferences
- Sincronización entre pestañas

### Dependencias Principales

```yaml
dependencies:
  flutter_bloc: ^8.1.3 # Gestión de estado
  bloc: ^8.1.4 # Patrón BLoC
  get_it: ^7.6.4 # Inyección de dependencias
  dartz: ^0.10.1 # Programación funcional
  equatable: ^2.0.5 # Comparación de objetos
  http: ^1.1.0 # Peticiones HTTP
  shared_preferences: ^2.2.2 # Almacenamiento local
  cached_network_image: ^3.3.0 # Caché de imágenes
  flutter_rating_bar: ^4.0.1 # Componente de calificación
  url_launcher: ^6.2.1 # Lanzador de URLs
```

### Patrones Implementados

#### 1. Repository Pattern

Abstrae el acceso a datos y permite intercambiar fuentes de datos fácilmente.

#### 2. BLoC Pattern

Separa la lógica de negocio de la interfaz de usuario usando streams.

#### 3. Dependency Injection

Usa GetIt para inyección de dependencias, facilitando testing y mantenimiento.

#### 4. Use Case Pattern

Encapsula la lógica de negocio en casos de uso específicos.

### Beneficios de la Arquitectura

1. **Separación de Responsabilidades**: Cada capa tiene una responsabilidad específica
2. **Testabilidad**: Fácil creación de tests unitarios para cada capa
3. **Mantenibilidad**: Código más organizado y fácil de mantener
4. **Escalabilidad**: Arquitectura que escala bien con el crecimiento del proyecto
5. **Reutilización**: Componentes reutilizables entre diferentes partes de la app
6. **Independencia**: Las capas no dependen de implementaciones concretas

### Flujo de Datos

```
UI → BLoC → Use Case → Repository → Data Source → API/Local Storage
```

### Gestión de Estados

La aplicación usa BLoC para gestionar estados:

- **AuthBloc**: Maneja autenticación y login
- **RestaurantBloc**: Gestiona restaurantes y comentarios
- **FavoritesBloc**: Controla el sistema de favoritos

### Manejo de Errores

Sistema centralizado de manejo de errores:

- **Failures**: Clases para diferentes tipos de errores
- **Either**: Uso del patrón Either para manejar éxito/error
- **Error Boundaries**: Manejo de errores en la UI

### Configuración de Red

- Configuración de seguridad de red para Android
- Headers personalizados para peticiones HTTP
- Manejo de timeouts y errores de red

### Ejecutar la Aplicación

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run

# Ejecutar análisis de código
flutter analyze

# Ejecutar tests
flutter test
```

### API Endpoints

- **Base URL**: `https://foodapp-eqayckejbjg3eqgn.eastus-01.azurewebsites.net`
- **Login**: `POST /auth/login`
- **Restaurantes**: `GET /restaurants`
- **Comentarios**: `GET /restaurants/{id}/comments`
- **Agregar Comentario**: `POST /restaurants/{id}/comments`

### Persistencia Local

- **Favoritos**: Almacenados en SharedPreferences
- **Formato**: JSON serializado
- **Sincronización**: Automática entre sesiones

Esta implementación de Clean Architecture proporciona una base sólida para el desarrollo y mantenimiento de la aplicación FoodApp.

![Demo de la app](diseño/background.gif)


# 🎬 ReelsDown

**¡Descarga tus videos favoritos de Facebook, TikTok e Instagram en segundos!** 😎

[![GitHub license](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/tu_usuario/VidGrab?style=social)](https://github.com/tu_usuario/VidGrab/stargazers)

---

## 🚀 Características

- **Interfaz moderna**: Diseño inspirado en TikTok con colores rosa y negro
- **Fácil de usar**: Simplemente pega la URL del video de TikTok
- **Navegación por pestañas**: Home, Historial y Configuraciones
- **Funcionalidad de pegado**: Botón para pegar automáticamente desde el portapapeles
- **Indicador de descarga**: Animación de carga durante el proceso de descarga
- **Historial de descargas**: Pantalla para ver videos descargados previamente
- **Configuraciones**: Personaliza la ubicación de descarga y calidad de video

## 📱 Pantallas

### 1. Pantalla Principal (Home)
- Campo de entrada para URL de TikTok
- Botón de descarga con animación de carga
- Características destacadas (HD, Rápido, Seguro)
- Botón de pegar desde portapapeles

### 2. Historial
- Lista de videos descargados (próximamente)
- Estado vacío cuando no hay descargas

### 3. Configuraciones
- Ubicación de descarga
- Calidad de video
- Notificaciones
- Información de la app

![Logo](./assets/logo.png)



## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil multiplataforma
- **Material 3**: Sistema de diseño moderno de Google
- **Dart**: Lenguaje de programación

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada principal
├── models/                   # Modelos de datos
│   └── video_model.dart     # Modelo para videos de TikTok
├── services/                 # Servicios de la aplicación
│   └── tiktok_service.dart  # Servicio para extraer videos
├── screens/                  # Pantallas de la aplicación
│   ├── home_screen.dart     # Pantalla principal
│   ├── history_screen.dart  # Historial de descargas
│   └── settings_screen.dart # Configuraciones
├── widgets/                  # Widgets personalizados
│   └── custom_text_field.dart # Campo de texto personalizado
└── utils/                   # Utilidades
    ├── app_theme.dart       # Tema de la aplicación
    └── constants.dart       # Constantes de la app
```

## 🎨 Diseño y Tema

La aplicación utiliza un tema personalizado con:

- **Colores primarios**: Rosa (#FF4081) y Negro (#000000)
- **Colores secundarios**: Cian para gradientes
- **Material 3**: Componentes modernos y animaciones fluidas
- **Tipografía**: Fuentes claras y legibles

## 📋 Próximas Características

- [ ] Gestión de archivos descargados
- [ ] Opciones de calidad de video
- [ ] Descarga de audio únicamente
- [ ] Compartir videos descargados
- [ ] Modo oscuro/claro
- [ ] Descarga en lote
- [ ] Integración con APIs reales de TikTok

## 🚦 Cómo Ejecutar

1. Asegúrate de tener Flutter instalado
2. Clona este repositorio
3. Ejecuta `flutter pub get` para instalar dependencias
4. Conecta tu dispositivo o inicia un emulador
5. Ejecuta `flutter run`

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^0.13.6
  path_provider: ^2.1.1
  url_launcher: ^6.2.1
  share_plus: ^7.2.1
  image_picker: ^1.0.4
  permission_handler: ^11.0.1
```

## 🔧 Configuración de Desarrollo

### Android
- NDK Version: 27.0.12077973
- Compile SDK: flutter.compileSdkVersion
- Min SDK: flutter.minSdkVersion

### Permisos
- Internet
- Almacenamiento externo
- Notificaciones

## 🤝 Contribuciones

Las contribuciones son bienvenidas.




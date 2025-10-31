import 'package:flutter/material.dart';

class AppConstants {
  // Aplicación
  static const String appName = 'ReelsDown';
  static const String appVersion = '1.0.0';

  // URLs y APIs
  static const String tikTokDomain = 'tiktok.com';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';

  // Límites
  static const int maxHistoryItems = 100;
  static const int maxRetryAttempts = 3;
  static const Duration requestTimeout = Duration(seconds: 30);

  // Tamaños
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double thumbnailAspectRatio = 9 / 16;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);

  // Padding y Margins
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);

  // Mensajes
  static const String invalidUrlMessage =
      'Por favor, ingresa una URL válida de TikTok';
  static const String networkErrorMessage =
      'Error de conexión. Verifica tu internet';
  static const String downloadSuccessMessage = 'Video descargado exitosamente';
  static const String downloadErrorMessage = 'Error al descargar el video';

  // Patrones RegExp
  static final RegExp tikTokUrlPattern = RegExp(
    r'https?://(www\.)?(tiktok\.com|vm\.tiktok\.com)',
    caseSensitive: false,
  );
}

class AppStrings {
  // General
  static const String appTitle = 'ReelsDown';
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String cancel = 'Cancelar';
  static const String ok = 'OK';
  static const String retry = 'Reintentar';
  static const String close = 'Cerrar';

  // Home Screen
  static const String homeTitle = 'Descargar Videos';
  static const String urlHint = 'Pega aquí el enlace de TikTok';
  static const String downloadButton = 'Descargar';
  static const String pasteButton = 'Pegar';
  static const String clearButton = 'Limpiar';

  // History Screen
  static const String historyTitle = 'Historial';
  static const String emptyHistory = 'No hay videos en el historial';
  static const String clearHistory = 'Limpiar historial';
  static const String confirmClearHistory =
      '¿Estás seguro de que quieres limpiar todo el historial?';

  // Download Status
  static const String extracting = 'Extrayendo información...';
  static const String downloading = 'Descargando...';
  static const String completed = 'Completado';
  static const String failed = 'Error en la descarga';
  static const String cancelled = 'Cancelado';

  // Settings Screen
  static const String settingsTitle = 'Configuración';
  static const String downloadQuality = 'Calidad de descarga';
  static const String downloadLocation = 'Ubicación de descarga';
  static const String notifications = 'Notificaciones';
  static const String darkMode = 'Modo oscuro';
  static const String about = 'Acerca de';

  // About Screen
  static const String aboutTitle = 'Acerca de';
  static const String appDescription =
      'Una aplicación moderna para descargar videos de redes sociales';
  static const String developer = 'Desarrollado con ❤️ en Flutter';
  static const String version = 'Versión';
  static const String privacyPolicy = 'Política de privacidad';
  static const String termsOfService = 'Términos de servicio';

  // Errors
  static const String invalidUrl = 'URL de TikTok no válida';
  static const String networkError = 'Error de conexión a internet';
  static const String downloadError = 'Error al descargar el video';
  static const String storageError = 'Error de almacenamiento';
  static const String permissionError = 'Permisos insuficientes';
  static const String unknownError = 'Error desconocido';

  // Navigation
  static const String homeTab = 'Inicio';
  static const String historyTab = 'Historial';
  static const String settingsTab = 'Configuración';
}

class AppDimensions {
  // Tamaños de fuente
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeRegular = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;

  // Espaciado
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingRegular = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;

  // Tamaños de iconos
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeRegular = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Altura de componentes
  static const double buttonHeight = 48.0;
  static const double inputHeight = 52.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;

  // Ancho de componentes
  static const double maxContentWidth = 500.0;
  static const double thumbnailWidth = 100.0;
  static const double thumbnailHeight = 178.0; // 9:16 aspect ratio
}

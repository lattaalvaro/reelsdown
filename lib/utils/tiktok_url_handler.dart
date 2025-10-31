class TikTokUrlHandler {
  // Patrones de URL más específicos para diferentes plataformas
  static const Map<String, String> urlPatterns = {
    'desktop_full': r'https?://(?:www\.)?tiktok\.com/@([^/]+)/video/(\d+)',
    'mobile_vm': r'https?://vm\.tiktok\.com/([a-zA-Z0-9]+)',
    'mobile_vt': r'https?://vt\.tiktok\.com/([a-zA-Z0-9]+)',
    'share_link': r'https?://(?:www\.)?tiktok\.com/t/([a-zA-Z0-9]+)',
    'mobile_direct': r'https?://(?:m\.)?tiktok\.com/v/(\d+)',
    'regional_domain': r'https?://(?:www\.)?tiktok\.co/.*',
    'with_params': r'https?://(?:www\.)?tiktok\.com/@[^/]+/video/(\d+)\?.*',
    'generic_video': r'https?://(?:www\.)?tiktok\.com/.*video.*(\d+).*',
  };

  // Ejemplos de URLs reales para diferentes regiones
  static const Map<String, List<String>> urlExamples = {
    'Escritorio (PC)': [
      'https://www.tiktok.com/@username/video/1234567890123456789',
      'https://tiktok.com/@creator/video/9876543210987654321',
    ],
    'Móvil Android (VM)': [
      'https://vm.tiktok.com/ZMF1A2B3C',
      'https://vm.tiktok.com/ZS8xyz123',
      'https://vm.tiktok.com/ZTR9abc456',
    ],
    'Móvil Android (VT)': [
      'https://vt.tiktok.com/ZSF1A2B3C',
      'https://vt.tiktok.com/ZTR9abc456',
    ],
    'Enlaces de compartir': [
      'https://www.tiktok.com/t/ABC123DEF',
      'https://tiktok.com/t/XYZ789GHI',
    ],
    'URLs móviles directas': [
      'https://m.tiktok.com/v/1234567890123456789',
      'https://m.tiktok.com/video/9876543210987654321',
    ],
  };

  // Función para detectar el tipo de URL
  static String detectUrlType(String url) {
    url = url.toLowerCase().trim();

    for (String key in urlPatterns.keys) {
      RegExp regex = RegExp(urlPatterns[key]!, caseSensitive: false);
      if (regex.hasMatch(url)) {
        return key;
      }
    }

    return 'unknown';
  }

  // Función para normalizar URLs de diferentes plataformas
  static String normalizeUrl(String url) {
    url = url.trim();

    // Eliminar parámetros innecesarios pero mantener la estructura
    if (url.contains('?')) {
      // Para URLs con parámetros, mantener solo los esenciales
      Uri uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        url = '${uri.scheme}://${uri.host}${uri.path}';
      }
    }

    // Convertir móvil a escritorio si es necesario para mejor compatibilidad
    if (url.contains('m.tiktok.com')) {
      url = url.replaceAll('m.tiktok.com', 'www.tiktok.com');
    }

    return url;
  }

  // Función para validar si la URL es de TikTok
  static bool isValidTikTokUrl(String url) {
    url = url.toLowerCase().trim();

    // Lista de dominios válidos de TikTok
    List<String> validDomains = [
      'tiktok.com',
      'www.tiktok.com',
      'm.tiktok.com',
      'vm.tiktok.com',
      'vt.tiktok.com',
      'tiktok.co',
      'www.tiktok.co',
    ];

    // Verificar si contiene un dominio válido
    bool hasValidDomain = validDomains.any((domain) => url.contains(domain));
    if (!hasValidDomain) return false;

    // Verificar contra patrones específicos
    for (String pattern in urlPatterns.values) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(url)) {
        return true;
      }
    }

    return false;
  }

  // Función para extraer ID del video si es posible
  static String? extractVideoId(String url) {
    for (String pattern in urlPatterns.values) {
      RegExp regex = RegExp(pattern, caseSensitive: false);
      Match? match = regex.firstMatch(url);
      if (match != null && match.groupCount > 0) {
        // Intentar encontrar un ID numérico largo (típico de TikTok)
        for (int i = 1; i <= match.groupCount; i++) {
          String? group = match.group(i);
          if (group != null &&
              group.length > 10 &&
              RegExp(r'^\d+$').hasMatch(group)) {
            return group;
          }
        }
        // Si no hay ID numérico, devolver el primer grupo
        return match.group(1);
      }
    }
    return null;
  }

  // Función para obtener información básica de la URL
  static Map<String, String> getUrlInfo(String url) {
    String type = detectUrlType(url);
    String? videoId = extractVideoId(url);
    String normalized = normalizeUrl(url);

    return {
      'type': type,
      'videoId': videoId ?? 'unknown',
      'normalized': normalized,
      'original': url,
      'isValid': isValidTikTokUrl(url).toString(),
    };
  }
}

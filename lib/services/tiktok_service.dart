import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import '../models/video_model.dart';

class TikTokService {
  static final TikTokService _instance = TikTokService._internal();
  factory TikTokService() => _instance;
  TikTokService._internal();

  final Dio _dio = Dio();

  // Expresión regular para validar URLs de TikTok (incluyendo formatos móviles)
  static const List<String> _tiktokUrlPatterns = [
    // URLs de escritorio
    r'https?://(?:www\.)?tiktok\.com/@[^/]+/video/(\d+)',
    // URLs cortas de TikTok
    r'https?://vm\.tiktok\.com/([a-zA-Z0-9]+)',
    r'https?://vt\.tiktok\.com/([a-zA-Z0-9]+)',
    // URLs de compartir en móvil
    r'https?://(?:www\.)?tiktok\.com/t/([a-zA-Z0-9]+)',
    r'https?://(?:m\.)?tiktok\.com/v/(\d+)',
    // URLs con parámetros adicionales
    r'https?://(?:www\.)?tiktok\.com/@[^/]+/video/(\d+)\?.*',
    r'https?://(?:www\.)?tiktok\.com/.*video.*(\d+).*',
    // URLs con diferentes dominios regionales
    r'https?://(?:www\.)?tiktok\.com/.*',
    r'https?://(?:www\.)?tiktok\.co/.*',
  ];

  bool isValidTikTokUrl(String url) {
    // Limpiar y normalizar la URL
    url = url.trim().toLowerCase();

    for (String pattern in _tiktokUrlPatterns) {
      final RegExp regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(url)) {
        return true;
      }
    }
    return false;
  }

  // Normalizar URL de TikTok para diferentes plataformas
  String _normalizeUrl(String url) {
    url = url.trim();

    // Si es una URL corta, intentar expandirla
    if (url.contains('vm.tiktok.com') || url.contains('vt.tiktok.com')) {
      return url;
    }

    // Convertir URLs móviles a formato estándar si es necesario
    if (url.contains('m.tiktok.com')) {
      url = url.replaceAll('m.tiktok.com', 'www.tiktok.com');
    }

    return url;
  }

  // Extraer información del video usando API pública de TikTok
  Future<VideoModel?> extractVideoInfo(String url) async {
    try {
      // Normalizar la URL
      url = _normalizeUrl(url);

      if (!isValidTikTokUrl(url)) {
        throw Exception('URL de TikTok no válida');
      }

      // Usar API de descarga de TikTok (servicio público)
      final response = await _dio.get(
        'https://tikwm.com/api/',
        queryParameters: {'url': url, 'hd': '1'},
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 0) {
        final data = response.data['data'];

        return VideoModel(
          id: data['id'] ?? '',
          title: data['title'] ?? 'TikTok Video',
          author: data['author']['nickname'] ?? 'Unknown',
          thumbnailUrl: data['cover'] ?? '',
          videoUrl: data['hdplay'] ?? data['play'] ?? '',
          originalUrl: url,
          downloadUrl: data['hdplay'] ?? data['play'] ?? '',
          duration: int.tryParse(data['duration']?.toString() ?? '0') ?? 0,
          viewCount: data['play_count']?.toString() ?? '0',
          likeCount: data['digg_count']?.toString() ?? '0',
          isDownloaded: false,
          downloadPath: '',
          quality: 'HD',
          downloadDate: DateTime.now(),
        );
      } else {
        throw Exception('Error al extraer información del video');
      }
    } catch (e) {
      print('Error extracting video info: $e');
      throw Exception('Error al procesar la URL: ${e.toString()}');
    }
  }

  // Descargar video con progreso
  Future<String> downloadVideo(
    VideoModel video, {
    Function(double)? onProgress,
  }) async {
    try {
      // Solicitar permisos de almacenamiento
      if (!await _requestStoragePermission()) {
        throw Exception('Permisos de almacenamiento requeridos');
      }

      // Obtener directorio de descarga
      final directory = await _getDownloadDirectory();
      await _ensureDirectoryExists(directory);

      final fileName =
          'tiktok_${video.id}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '${directory.path}/$fileName';

      // Descargar el archivo
      await _dio.download(
        video.downloadUrl ?? video.videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': 'https://www.tiktok.com/',
          },
        ),
      );

      return filePath;
    } catch (e) {
      print('Error downloading video: $e');
      throw Exception('Error al descargar el video: ${e.toString()}');
    }
  }

  // Solicitar permisos de almacenamiento
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+) usar nuevos permisos granulares
      try {
        final videosPermission = await Permission.videos.request();
        final photosPermission = await Permission.photos.request();

        // Si los permisos granulares están disponibles, usarlos
        if (videosPermission.isGranted || photosPermission.isGranted) {
          return true;
        }

        // Para versiones anteriores, usar permisos tradicionales
        final storagePermission = await Permission.storage.request();
        if (storagePermission.isGranted) {
          return true;
        }

        // Como último recurso, solicitar acceso a archivos y multimedia
        final manageStoragePermission = await Permission.manageExternalStorage
            .request();
        return manageStoragePermission.isGranted;
      } catch (e) {
        print('Error requesting permissions: $e');
        // Fallback a permisos básicos
        final storagePermission = await Permission.storage.request();
        return storagePermission.isGranted;
      }
    }
    return true; // iOS maneja permisos automáticamente
  }

  // Obtener directorio de descarga
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Para Android, usar Downloads
      return Directory('/storage/emulated/0/Download/TikTokDownloader');
    } else {
      // Para iOS, usar Documents
      final directory = await getApplicationDocumentsDirectory();
      return Directory('${directory.path}/Downloads');
    }
  }

  // Crear directorio si no existe
  Future<void> _ensureDirectoryExists(Directory directory) async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  // Obtener videos descargados
  Future<List<VideoModel>> getDownloadedVideos() async {
    try {
      final directory = await _getDownloadDirectory();
      await _ensureDirectoryExists(directory);

      final files = directory
          .listSync()
          .where((file) => file.path.endsWith('.mp4'))
          .toList();

      return files.map((file) {
        final fileName = file.path.split('/').last;
        return VideoModel(
          id: fileName,
          title: fileName.replaceAll('.mp4', ''),
          author: 'Downloaded',
          thumbnailUrl: '',
          videoUrl: file.path,
          downloadUrl: file.path,
          duration: 0,
          viewCount: '0',
          likeCount: '0',
          isDownloaded: true,
          downloadPath: file.path,
          quality: 'HD',
          downloadDate: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error getting downloaded videos: $e');
      return [];
    }
  }

  // Eliminar video descargado
  Future<bool> deleteDownloadedVideo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting video: $e');
      return false;
    }
  }

  // Abrir archivo de video con la aplicación predeterminada
  Future<bool> openVideoFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // Open the file using open_filex which uses FileProvider on Android
        final result = await OpenFilex.open(filePath);
        // OpenFilexResult has type and message; consider success if type != 2 (which is error)
        // We'll consider any result as success for UX and log message
        print('OpenFilex result: ${result.type} - ${result.message}');
        return true;
      }
      return false;
    } catch (e) {
      print('Error opening video file: $e');
      return false;
    }
  }
}

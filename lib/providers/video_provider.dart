import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../models/download_progress.dart';
import '../services/tiktok_service.dart';
import '../services/storage_service.dart';

class VideoProvider extends ChangeNotifier {
  final TikTokService _tikTokService = TikTokService();
  final StorageService _storageService = StorageService();

  List<VideoModel> _videos = [];
  final Map<String, DownloadProgress> _downloadProgress = {};
  bool _isLoading = false;
  String? _error;

  List<VideoModel> get videos => _videos;
  Map<String, DownloadProgress> get downloadProgress => _downloadProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  VideoProvider() {
    _loadVideoHistory();
  }

  Future<void> _loadVideoHistory() async {
    try {
      _videos = await _storageService.loadVideoHistory();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar historial: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<VideoModel?> extractVideoInfo(String url) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_tikTokService.isValidTikTokUrl(url)) {
        throw Exception('URL de TikTok no válida');
      }

      final video = await _tikTokService.extractVideoInfo(url);

      if (video != null) {
        await _storageService.addVideoToHistory(video);
        _videos.insert(0, video);
        notifyListeners();
      }

      return video;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> downloadVideo(VideoModel video) async {
    final videoId = video.id;

    // Inicializar progreso
    _downloadProgress[videoId] = DownloadProgress(
      videoId: videoId,
      status: DownloadStatus.extracting,
      message: 'Preparando descarga...',
    );
    notifyListeners();

    try {
      // Actualizar progreso a descargando
      _downloadProgress[videoId] = _downloadProgress[videoId]!.copyWith(
        status: DownloadStatus.downloading,
        message: 'Descargando video...',
      );
      notifyListeners();

      // Descargar video
      final filePath = await _tikTokService.downloadVideo(
        video,
        onProgress: (progress) {
          _downloadProgress[videoId] = _downloadProgress[videoId]!.copyWith(
            progress: progress,
            message: 'Descargando... ${(progress * 100).toInt()}%',
          );
          notifyListeners();
        },
      );

      // Actualizar video con ruta local
      final updatedVideo = video.copyWith(
        isDownloaded: true,
        localPath: filePath,
      );

      // Actualizar en lista y storage
      final index = _videos.indexWhere((v) => v.id == videoId);
      if (index != -1) {
        _videos[index] = updatedVideo;
      }
      await _storageService.addVideoToHistory(updatedVideo);

      // Completar descarga
      _downloadProgress[videoId] = _downloadProgress[videoId]!.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        message: 'Descarga completada',
      );
      notifyListeners();

      // Limpiar progreso después de un tiempo
      Future.delayed(const Duration(seconds: 3), () {
        _downloadProgress.remove(videoId);
        notifyListeners();
      });
    } catch (e) {
      _downloadProgress[videoId] = _downloadProgress[videoId]!.copyWith(
        status: DownloadStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();

      // Limpiar progreso de error después de un tiempo
      Future.delayed(const Duration(seconds: 5), () {
        _downloadProgress.remove(videoId);
        notifyListeners();
      });
    }
  }

  Future<void> removeVideo(String videoId) async {
    try {
      await _storageService.removeVideoFromHistory(videoId);
      _videos.removeWhere((video) => video.id == videoId);
      _downloadProgress.remove(videoId);
      notifyListeners();
    } catch (e) {
      _setError('Error al eliminar video: ${e.toString()}');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _storageService.clearHistory();
      _videos.clear();
      _downloadProgress.clear();
      notifyListeners();
    } catch (e) {
      _setError('Error al limpiar historial: ${e.toString()}');
    }
  }

  void cancelDownload(String videoId) {
    if (_downloadProgress.containsKey(videoId)) {
      _downloadProgress[videoId] = _downloadProgress[videoId]!.copyWith(
        status: DownloadStatus.cancelled,
        message: 'Descarga cancelada',
      );
      notifyListeners();

      // Limpiar progreso cancelado
      Future.delayed(const Duration(seconds: 2), () {
        _downloadProgress.remove(videoId);
        notifyListeners();
      });
    }
  }

  bool isValidUrl(String url) {
    return _tikTokService.isValidTikTokUrl(url);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

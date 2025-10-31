import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/video_model.dart';

class StorageService {
  static const String _fileName = 'video_history.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<VideoModel>> loadVideoHistory() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);

        return jsonData.map((item) => VideoModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error al cargar historial: $e');
      return [];
    }
  }

  Future<void> saveVideoHistory(List<VideoModel> videos) async {
    try {
      final file = await _localFile;
      final jsonData = videos.map((video) => video.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error al guardar historial: $e');
    }
  }

  Future<void> addVideoToHistory(VideoModel video) async {
    try {
      final videos = await loadVideoHistory();

      // Evitar duplicados
      videos.removeWhere((v) => v.id == video.id);
      videos.insert(0, video);

      // Mantener solo los últimos 100 videos
      if (videos.length > 100) {
        videos.removeRange(100, videos.length);
      }

      await saveVideoHistory(videos);
    } catch (e) {
      print('Error al agregar video al historial: $e');
    }
  }

  Future<void> removeVideoFromHistory(String videoId) async {
    try {
      final videos = await loadVideoHistory();
      videos.removeWhere((video) => video.id == videoId);
      await saveVideoHistory(videos);
    } catch (e) {
      print('Error al eliminar video del historial: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error al limpiar historial: $e');
    }
  }

  Future<bool> isVideoInHistory(String videoId) async {
    try {
      final videos = await loadVideoHistory();
      return videos.any((video) => video.id == videoId);
    } catch (e) {
      print('Error al verificar video en historial: $e');
      return false;
    }
  }

  Future<VideoModel?> getVideoFromHistory(String videoId) async {
    try {
      final videos = await loadVideoHistory();
      return videos.where((video) => video.id == videoId).firstOrNull;
    } catch (e) {
      print('Error al obtener video del historial: $e');
      return null;
    }
  }
}

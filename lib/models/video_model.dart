class VideoModel {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final String videoUrl;
  final String? originalUrl;
  final DateTime? downloadDate;
  final int duration;
  final String quality;
  final bool isDownloaded;
  final String? localPath;
  final String? downloadUrl;
  final String? viewCount;
  final String? likeCount;
  final String? downloadPath;

  VideoModel({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.originalUrl,
    this.downloadDate,
    required this.duration,
    required this.quality,
    this.isDownloaded = false,
    this.localPath,
    this.downloadUrl,
    this.viewCount,
    this.likeCount,
    this.downloadPath,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? author,
    String? thumbnailUrl,
    String? videoUrl,
    String? originalUrl,
    DateTime? downloadDate,
    int? duration,
    String? quality,
    bool? isDownloaded,
    String? localPath,
    String? downloadUrl,
    String? viewCount,
    String? likeCount,
    String? downloadPath,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      originalUrl: originalUrl ?? this.originalUrl,
      downloadDate: downloadDate ?? this.downloadDate,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      downloadPath: downloadPath ?? this.downloadPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'originalUrl': originalUrl,
      'downloadDate': downloadDate?.toIso8601String(),
      'duration': duration,
      'quality': quality,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'downloadUrl': downloadUrl,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'downloadPath': downloadPath,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      originalUrl: json['originalUrl'],
      downloadDate: json['downloadDate'] != null
          ? DateTime.parse(json['downloadDate'])
          : null,
      duration: json['duration'],
      quality: json['quality'],
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
      downloadUrl: json['downloadUrl'],
      viewCount: json['viewCount'],
      likeCount: json['likeCount'],
      downloadPath: json['downloadPath'],
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    if (downloadDate == null) return 'No descargado';

    final now = DateTime.now();
    final difference = now.difference(downloadDate!);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Ahora mismo';
    }
  }
}

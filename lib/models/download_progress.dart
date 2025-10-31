enum DownloadStatus {
  idle,
  extracting,
  downloading,
  completed,
  error,
  cancelled,
}

class DownloadProgress {
  final String videoId;
  final DownloadStatus status;
  final double progress;
  final String? message;
  final String? errorMessage;

  DownloadProgress({
    required this.videoId,
    required this.status,
    this.progress = 0.0,
    this.message,
    this.errorMessage,
  });

  DownloadProgress copyWith({
    String? videoId,
    DownloadStatus? status,
    double? progress,
    String? message,
    String? errorMessage,
  }) {
    return DownloadProgress(
      videoId: videoId ?? this.videoId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading =>
      status == DownloadStatus.extracting ||
      status == DownloadStatus.downloading;
  bool get isCompleted => status == DownloadStatus.completed;
  bool get hasError => status == DownloadStatus.error;
}

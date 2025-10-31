class DownloadConfig {
  static const String downloadDirectory = 'ReelsDown';
  static const String appName = 'ReelsDown';
  static const String defaultQuality = 'HD';

  // API Endpoints
  static const String tikWmApiUrl = 'https://tikwm.com/api/';

  // User Agent
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

  // Supported video formats
  static const List<String> supportedFormats = ['mp4', 'mov', 'avi'];

  // Max file size (in MB)
  static const int maxFileSize = 100;

  // Timeout duration for downloads
  static const Duration downloadTimeout = Duration(minutes: 10);

  // Supported TikTok URL patterns
  static const List<String> supportedUrlPatterns = [
    r'https?://(?:www\.)?tiktok\.com/@[^/]+/video/(\d+)',
    r'https?://vm\.tiktok\.com/([a-zA-Z0-9]+)',
    r'https?://(?:www\.)?tiktok\.com/t/([a-zA-Z0-9]+)',
    r'https?://(?:www\.)?tiktok\.com/.*',
  ];

  // App version
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
}

class AppConstants {
  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double iconSize = 24.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Error messages
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String invalidUrl = 'Please enter a valid TikTok URL';
  static const String downloadError =
      'Failed to download video. Please try again.';
  static const String permissionError =
      'Storage permission required to download videos';
  static const String genericError = 'An unexpected error occurred';
}

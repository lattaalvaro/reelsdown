import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.spacingXXLarge),

              // Header
              _buildHeader(),

              const SizedBox(height: AppDimensions.spacingXXLarge),

              // URL Input
              _buildUrlInput(),

              const SizedBox(height: AppDimensions.spacingLarge),

              // Download Button
              _buildDownloadButton(),

              const SizedBox(height: AppDimensions.spacingXLarge),

              // Features
              _buildFeatures(),

              const Spacer(),

              // Instructions
              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.video_library, color: Colors.white, size: 40),
        ),
        const SizedBox(height: AppDimensions.spacingRegular),
        Text(
          AppStrings.appTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Text(
          'Descarga videos de TikTok de forma rápida y sencilla',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUrlInput() {
    return CustomTextField(
      controller: _urlController,
      hintText: AppStrings.urlHint,
      prefixIcon: Icons.link,
      keyboardType: TextInputType.url,
      errorText: _errorMessage,
      onChanged: (value) {
        if (_errorMessage != null) {
          setState(() {
            _errorMessage = null;
          });
        }
      },
      onPastePressed: () {
        // Handle paste action
      },
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleDownload,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download),
                  const SizedBox(width: AppDimensions.spacingSmall),
                  Text(
                    AppStrings.downloadButton,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeRegular,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.speed,
        'title': 'Rápido',
        'description': 'Descarga en segundos',
      },
      {
        'icon': Icons.hd,
        'title': 'Alta Calidad',
        'description': 'Videos en HD',
      },
      {
        'icon': Icons.security,
        'title': 'Seguro',
        'description': 'Sin marca de agua',
      },
    ];

    return Row(
      children: features.map((feature) {
        return Expanded(
          child: Container(
            padding: AppConstants.smallPadding,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  feature['icon'] as IconData,
                  color: AppTheme.secondaryColor,
                  size: AppDimensions.iconSizeLarge,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                Text(
                  feature['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.fontSizeMedium,
                  ),
                ),
                Text(
                  feature['description'] as String,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppDimensions.fontSizeSmall,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: AppConstants.defaultPadding,
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo usarlo?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          const Text('1. Copia el enlace del video de TikTok'),
          const Text('2. Pégalo en el campo de arriba'),
          const Text('3. Presiona "Descargar" y ¡listo!'),
        ],
      ),
    );
  }

  void _handleDownload() {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa una URL';
      });
      return;
    }

    if (!_isValidTikTokUrl(url)) {
      setState(() {
        _errorMessage = AppStrings.invalidUrl;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simular descarga por ahora
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Video descargado exitosamente!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        _urlController.clear();
      }
    });
  }

  bool _isValidTikTokUrl(String url) {
    return AppConstants.tikTokUrlPattern.hasMatch(url);
  }
}

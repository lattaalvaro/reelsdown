import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math' as math;
import 'services/tiktok_service.dart';
import 'models/video_model.dart';
import 'widgets/download_progress_dialog.dart';

void main() {
  runApp(const TikTokDownloaderApp());
}

class TikTokDownloaderApp extends StatelessWidget {
  const TikTokDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReelsDown',
      theme: ThemeData(
        // Usar tema oscuro para que el fondo y el texto por defecto sean apropiados
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        primarySwatch: Colors.pink,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<_HistoryScreenState> _historyKey =
      GlobalKey<_HistoryScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    HistoryScreen(key: _historyKey),
    const SettingsScreen(),
  ];

  void _refreshHistory() {
    _historyKey.currentState?.loadDownloadedVideos();
  }

  @override
  Widget build(BuildContext context) {
    // Calcular tamaño responsivo para el logo: no más de 220px y no más del 42% del ancho
    final screenW = MediaQuery.of(context).size.width;
    final double logoSize = math.min(220.0, screenW * 0.42);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  late VideoPlayerController _bgVideoController;
  bool _bgVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el video de fondo (asset)
    _bgVideoController = VideoPlayerController.asset('assets/videos/fondo.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _bgVideoInitialized = true;
          });
          _bgVideoController.play();
        }
      });

    // Nota: el logo ahora será un GIF animado en assets/videos/logo.gif
  }

  @override
  Widget build(BuildContext context) {
  // Calculate responsive logo dimensions for this screen: make it wider-than-tall
  // so it reads more horizontal on most devices.
  final screenW = MediaQuery.of(context).size.width;
  // Make the logo clearly smaller: use a smaller fraction of screen width
  // and a lower maximum so it doesn't dominate the view.
  final double logoWidth = math.min(screenW * 0.6, 360.0);
  // Reduce the minimum height slightly so the GIF stays compact on small devices
  final double logoHeight = math.max(90.0, logoWidth * 0.42);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // Title removed as requested; keep AppBar for status area/navigation
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            // Usar spaceBetween para asegurar que el panel inferior permanezca
            // pegado abajo y el contenido superior pueda desplazarse cuando falte espacio.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contenido principal desplazable para evitar que se suba fuera de pantalla
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 0),
                      SizedBox(
                        width: logoWidth,
                        height: logoHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/videos/logo.gif',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            width: logoWidth,
                            height: logoHeight,
                            // Fallback visual if the GIF asset is missing or fails to load
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.pink, Colors.cyan],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.download_for_offline,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Bajar visualmente solo los textos (título y subtítulo)
                      Transform.translate(
                        offset: const Offset(0, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(height: 4),
                            Text(
                              'Descargar Videos TikTok',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pega tu enlace de TikTok aquí',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Aumentar un poco el espacio antes del campo de texto para bajarlo
                      // (Solo el campo se moverá hacia abajo; el botón y los iconos quedan igual)
                      const SizedBox(height: 44),
                      // Aplicar un pequeño translate solo al campo de texto para moverlo hacia abajo
                      // sin afectar la posición del botón ni los iconos.
                      Transform.translate(
                        offset: const Offset(0, 20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: TextField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              hintText: 'Ej: https://vm.tiktok.com/ZMF...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.link, color: Colors.pink),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.paste, color: Colors.grey),
                                    onPressed: _pasteFromClipboard,
                                    tooltip: 'Pegar desde portapapeles',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _urlController.clear();
                                    },
                                    tooltip: 'Limpiar',
                                  ),
                                ],
                              ),
                            ),
                            maxLines: 1,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botón con padding en lugar de translate para evitar pushes
                      Padding(
                        // Subir el botón un poco (solo este elemento) reduciendo el padding superior
                        padding: const EdgeInsets.only(top: 36.0, left: 0, right: 0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _downloadVideo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Descargar Video',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        // Restaurar padding original para que los iconos vuelvan a su posición previa
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            FeatureItem(icon: Icons.hd, label: 'Calidad HD'),
                            FeatureItem(
                              icon: Icons.flash_on,
                              label: 'Descarga Rápida',
                            ),
                            FeatureItem(icon: Icons.security, label: 'Seguro'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),

              // Bottom social panel
              Builder(
                builder: (context) {
                  // Hacer la altura del panel responsiva para evitar overflow en pantallas pequeñas
                  final screenH = MediaQuery.of(context).size.height;
                  final panelHeight = math.min(210.0, screenH * 0.28);
                  final videoHeight = math.max(140.0, panelHeight - 30.0);

                  return SizedBox(
                    height: panelHeight,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              // Forzar que el ClipRRect ocupe el ancho de la pantalla
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                // Usar recorte estricto para asegurar las esquinas redondeadas
                                clipBehavior: Clip.hardEdge,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                // Reemplazar la imagen por un video asset (mismo alto) pero
                                // extenderlo horizontalmente hasta los bordes de la pantalla
                                // y mantener bordes redondeados del ClipRRect.
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  // Altura del video ahora depende de `videoHeight` calculado por pantalla
                                  height: videoHeight,
                                  child: _bgVideoInitialized
                                      ? FittedBox(
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            // Escalar ligeramente el video internamente para dar sensación de ancho extra
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                1.2,
                                            height: videoHeight,
                                            child: VideoPlayer(
                                              _bgVideoController,
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/fondo.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: videoHeight,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          // Mantener los iconos sociales cerca del borde inferior
                          bottom: -6,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton(
                                assetPath: 'assets/images/f.png',
                                onTap: () => _openLink('https://www.facebook.com/alvarolatta2'),
                              ),
                              const SizedBox(width: 12),
                              SocialButton(
                                assetPath: 'assets/images/i.png',
                                onTap: () => _openLink('https://www.instagram.com/lattaalvaro/#'),
                              ),
                              const SizedBox(width: 12),
                              SocialButton(
                                assetPath: 'assets/images/t.png',
                                onTap: () => _openLink('https://www.tiktok.com/@deannaturals'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _urlController.text = data.text!;
      });
    }
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir enlace: ${e.toString()}')),
        );
      }
    }
  }

  // _socialButton removed; using animated SocialButton widget instead.

  void _downloadVideo() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un enlace de TikTok')),
      );
      return;
    }

    // Validate TikTok URL
    final tikTokService = TikTokService();
    if (!tikTokService.isValidTikTokUrl(_urlController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un enlace válido de TikTok'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Extract video information
      final video = await tikTokService.extractVideoInfo(_urlController.text);

      if (video != null) {
        // Show video info dialog
        final shouldDownload = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Descargar Video?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Título: ${video.title}'),
                const SizedBox(height: 8),
                Text('Autor: ${video.author}'),
                const SizedBox(height: 8),
                Text('Duración: ${video.formattedDuration}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Descargar'),
              ),
            ],
          ),
        );

        if (shouldDownload == true) {
          // Create progress stream controller
          final StreamController<double> progressController =
              StreamController<double>();

          // Show progress dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => DownloadProgressDialog(
              videoTitle: video.title,
              progressStream: progressController.stream,
              onCancel: () {
                // Schedule the pop to avoid navigator being locked during layout
                if (mounted) {
                  Future.microtask(() {
                    if (mounted) Navigator.of(context).maybePop();
                  });
                }
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          );

          try {
            // Start download with progress
            await tikTokService.downloadVideo(
              video,
              onProgress: (progress) {
                progressController.add(progress);
              },
            );

            // Complete progress
            progressController.add(1.0);

            // Wait for user to close dialog
            await Future.delayed(const Duration(milliseconds: 500));

            // Reset loading state after successful download
            setState(() {
              _isLoading = false;
            });

            // Clear the URL field
            _urlController.clear();

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Video descargado exitosamente!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            // Notify parent widget to refresh history if needed
            // This will trigger a rebuild and refresh the history screen
            if (mounted) {
              final mainState = context
                  .findAncestorStateOfType<_MainScreenState>();
              mainState?._refreshHistory();
            }
          } catch (e) {
            // Close the progress dialog safely (schedule pop)
            if (mounted) {
              Future.microtask(() {
                if (mounted) Navigator.of(context).maybePop();
              });
            }
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error en la descarga: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          } finally {
            progressController.close();
            // Ensure loading state is always reset
            if (_isLoading) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose background video controller
    try {
      _bgVideoController.dispose();
    } catch (_) {}
      // logo GIF uses Image.asset so no controller to dispose
    _urlController.dispose();
    super.dispose();
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.pink),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// Animated social button widget: scales on press and shows a subtle shadow
class SocialButton extends StatefulWidget {
  final String assetPath;
  final VoidCallback onTap;

  const SocialButton({super.key, required this.assetPath, required this.onTap});

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _controller.addListener(() {
      setState(() {
        // Map controller value [0..1] to scale [0.92..1.0]
        _scale = 0.92 + (_controller.value * 0.08);
      });
    });
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    // shrink
    _controller.animateTo(0.0, duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
  }

  void _onTapUp(TapUpDetails details) async {
    // restore and trigger onTap after a tiny delay to show animation
    await _controller.animateTo(1.0, duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.animateTo(1.0, duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.0),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: 34,
            backgroundColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(widget.assetPath, width: 46, height: 46, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TikTokService _tikTokService = TikTokService();
  List<VideoModel> _downloadedVideos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedVideos();
  }

  Future<void> loadDownloadedVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final videos = await _tikTokService.getDownloadedVideos();
      setState(() {
        _downloadedVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando descargas: $e')));
      }
    }
  }

  Future<void> _loadDownloadedVideos() async {
    await loadDownloadedVideos();
  }

  Future<void> _deleteVideo(VideoModel video) async {
    final success = await _tikTokService.deleteDownloadedVideo(
      video.downloadPath ?? '',
    );
    if (success) {
      await _loadDownloadedVideos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _playVideo(VideoModel video) {
    if (video.downloadPath != null) {
      // Try to open the video with the default video player
      _tikTokService.openVideoFile(video.downloadPath!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abriendo video: ${video.title}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo encontrar el archivo del video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Descargas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDownloadedVideos();
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedVideos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Sin descargas aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tus videos descargados aparecerán aquí',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _downloadedVideos.length,
              itemBuilder: (context, index) {
                final video = _downloadedVideos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: Icon(Icons.video_file, color: Colors.white),
                    ),
                    title: Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Autor: ${video.author}'),
                        if (video.downloadDate != null)
                          Text('Descargado: ${video.formattedDate}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar Video'),
                              content: const Text(
                                '¿Estás seguro de que quieres eliminar este video?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteVideo(video);
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _playVideo(video),
                  ),
                );
              },
            ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.folder, color: Colors.pink),
            title: Text('Ubicación de Descarga'),
            subtitle: Text('/storage/emulated/0/Download'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.video_settings, color: Colors.pink),
            title: Text('Calidad de Video'),
            subtitle: Text('Mejor Disponible'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.notifications, color: Colors.pink),
            title: Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: null),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info, color: Colors.pink),
            title: Text('Acerca de'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}

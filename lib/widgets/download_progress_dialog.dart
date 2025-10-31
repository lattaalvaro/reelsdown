import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String videoTitle;
  final Stream<double> progressStream;
  final VoidCallback? onCancel;

  const DownloadProgressDialog({
    super.key,
    required this.videoTitle,
    required this.progressStream,
    this.onCancel,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    widget.progressStream.listen((progress) {
      setState(() {
        _progress = progress;
      });

      // Auto-close dialog when download is complete
      if (progress >= 1.0) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          // Schedule pop to avoid calling Navigator during build/layout phase
          Future.microtask(() {
            if (mounted) Navigator.of(context).maybePop(true);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_for_offline, color: Colors.pink, size: 28),
            const SizedBox(width: 12),
            const Text('Descargando Video'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.videoTitle,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Progress Bar
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              minHeight: 8,
            ),
            const SizedBox(height: 12),

            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getProgressStatus(_progress),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),

            // Animated dots for loading
            if (_progress < 1.0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedDot(delay: 0),
                    const SizedBox(width: 4),
                    _AnimatedDot(delay: 200),
                    const SizedBox(width: 4),
                    _AnimatedDot(delay: 400),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          if (_progress < 1.0 && widget.onCancel != null)
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancelar'),
            ),
          if (_progress >= 1.0)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Listo'),
            ),
        ],
      ),
    );
  }

  String _getProgressStatus(double progress) {
    if (progress < 0.1) return 'Iniciando...';
    if (progress < 0.5) return 'Descargando...';
    if (progress < 0.9) return 'Casi listo...';
    if (progress < 1.0) return 'Finalizando...';
    return 'Completado!';
  }
}

class _AnimatedDot extends StatefulWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

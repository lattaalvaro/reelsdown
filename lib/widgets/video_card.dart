import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../models/download_progress.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'custom_button.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final DownloadProgress? downloadProgress;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.video,
    this.downloadProgress,
    this.onDownload,
    this.onDelete,
    this.onTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildCard(context),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingRegular,
        vertical: AppDimensions.spacingSmall,
      ),
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: AppConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.spacingMedium),
              _buildContent(),
              if (widget.downloadProgress != null) ...[
                const SizedBox(height: AppDimensions.spacingMedium),
                _buildDownloadProgress(),
              ],
              const SizedBox(height: AppDimensions.spacingMedium),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.video_library,
            color: Colors.white,
            size: AppDimensions.iconSizeMedium,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.author,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                widget.video.formattedDate,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        if (widget.video.isDownloaded)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSmall,
              vertical: AppDimensions.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download_done,
                  size: AppDimensions.iconSizeSmall,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: AppDimensions.spacingXSmall),
                Text(
                  'Descargado',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeSmall,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        Container(
          width: AppDimensions.thumbnailWidth,
          height: AppDimensions.thumbnailHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: widget.video.thumbnailUrl.isNotEmpty
                ? Image.network(
                    widget.video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildThumbnailPlaceholder();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildThumbnailPlaceholder();
                    },
                  )
                : _buildThumbnailPlaceholder(),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMedium),

        // Video info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              _buildVideoMetadata(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.video_library_outlined,
          size: AppDimensions.iconSizeLarge,
          color: AppTheme.textLight,
        ),
      ),
    );
  }

  Widget _buildVideoMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: AppDimensions.iconSizeSmall,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            Text(
              widget.video.formattedDuration,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXSmall),
        Row(
          children: [
            Icon(
              Icons.high_quality,
              size: AppDimensions.iconSizeSmall,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            Text(
              widget.video.quality,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloadProgress() {
    final progress = widget.downloadProgress!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                progress.message ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (progress.isLoading)
              Text(
                '${(progress.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        LinearProgressIndicator(
          value: progress.isLoading ? progress.progress : null,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress.hasError ? AppTheme.errorColor : AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final progress = widget.downloadProgress;

    return Row(
      children: [
        if (!widget.video.isDownloaded && progress == null)
          Expanded(
            child: CustomButton(
              text: AppStrings.downloadButton,
              icon: Icons.download,
              onPressed: widget.onDownload,
              height: 40,
            ),
          )
        else if (progress?.isLoading == true)
          Expanded(
            child: CustomButton.outlined(
              text: AppStrings.cancel,
              icon: Icons.close,
              onPressed: () {
                // Cancel download logic would go here
              },
              height: 40,
            ),
          )
        else
          Expanded(
            child: CustomButton.outlined(
              text: 'Ver video',
              icon: Icons.play_arrow,
              onPressed: widget.onTap,
              height: 40,
            ),
          ),

        const SizedBox(width: AppDimensions.spacingSmall),

        IconButton(
          onPressed: widget.onDelete,
          icon: const Icon(Icons.delete_outline),
          color: AppTheme.errorColor,
          tooltip: 'Eliminar',
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/voice.dart';
import '../services/audio_service.dart';

/// Card widget for displaying a voice.
class VoiceCard extends StatefulWidget {
  final Voice voice;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onPreview;
  final bool isPreviewing;

  const VoiceCard({
    super.key,
    required this.voice,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onPreview,
    this.isPreviewing = false,
  });

  @override
  State<VoiceCard> createState() => _VoiceCardState();
}

class _VoiceCardState extends State<VoiceCard> {
  final AudioService _audioService = AudioService();

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _playPreview() async {
    if (widget.voice.previewUrl == null) return;
    
    try {
      if (widget.isPreviewing) {
        await _audioService.stop();
        widget.onPreview?.call();
      } else {
        await _audioService.loadUrl(widget.voice.previewUrl!);
        await _audioService.play();
        widget.onPreview?.call();
      }
    } catch (_) {
      // Handle preview error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : Theme.of(context).cardColor,
      elevation: widget.isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        side: BorderSide(
          color: widget.isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.voice.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.star : Icons.star_border,
                      color: widget.isFavorite ? Colors.amber : Colors.grey,
                    ),
                    onPressed: widget.onFavoriteToggle,
                    tooltip: widget.isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (widget.voice.language != null)
                    _buildChip(context, widget.voice.language!),
                  if (widget.voice.gender != null)
                    _buildChip(context, widget.voice.gender!),
                  if (widget.voice.accent != null)
                    _buildChip(context, widget.voice.accent!),
                ],
              ),
              if (widget.voice.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.voice.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.voice.previewUrl != null)
                    IconButton(
                      icon: Icon(
                        widget.isPreviewing
                            ? Icons.stop_circle
                            : Icons.play_circle_fill,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _playPreview,
                      tooltip: widget.isPreviewing
                          ? 'Arrêter'
                          : 'Écouter',
                    ),
                  const Spacer(),
                  if (widget.isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 11,
            ),
      ),
    );
  }
}

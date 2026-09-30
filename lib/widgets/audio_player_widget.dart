import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';

/// Professional audio player widget.
class AudioPlayerWidget extends StatefulWidget {
  final String? audioPath;
  final String? voiceName;
  final bool autoPlay;
  final VoidCallback? onPlayComplete;

  const AudioPlayerWidget({
    super.key,
    this.audioPath,
    this.voiceName,
    this.autoPlay = false,
    this.onPlayComplete,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  bool _isLoading = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        widget.onPlayComplete?.call();
      }
    });
    if (widget.audioPath != null) {
      _loadAudio();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Pause audio when app goes to background
      _audioService.pause();
    }
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.audioPath != oldWidget.audioPath && widget.audioPath != null) {
      _loadAudio();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    if (widget.audioPath == null) return;
    
    setState(() => _isLoading = true);
    try {
      await _audioService.loadFile(widget.audioPath!);
      if (widget.autoPlay) {
        await _audioService.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement audio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice name
            if (widget.voiceName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Voix: ${widget.voiceName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),

            // Progress bar
            StreamBuilder<Duration>(
              stream: _audioService.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: _audioService.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final maxMs = duration.inMilliseconds.toDouble();
                    final currentMs = position.inMilliseconds.toDouble().clamp(0, maxMs);

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: maxMs > 0 ? currentMs.toDouble() : 0.0,
                            max: maxMs > 0 ? maxMs : 1.0,
                            onChanged: maxMs > 0
                                ? (double value) {
                                    _audioService.seek(Duration(milliseconds: value.toInt()));
                                  }
                                : null,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _formatDuration(duration),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 8),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rewind 10s
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => _audioService.seekRelative(const Duration(seconds: -10)),
                ),
                const SizedBox(width: 8),

                // Play/Pause
                _isLoading
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : StreamBuilder<PlayerState>(
                        stream: _audioService.playerStateStream,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data?.playing ?? false;
                          return IconButton(
                            iconSize: 48,
                            icon: Icon(
                              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                _audioService.pause();
                              } else {
                                _audioService.play();
                              }
                            },
                          );
                        },
                      ),

                const SizedBox(width: 8),

                // Forward 10s
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => _audioService.seekRelative(const Duration(seconds: 10)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Volume
            Row(
              children: [
                const Icon(Icons.volume_down, size: 20),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: (value) {
                      setState(() => _volume = value);
                      _audioService.setVolume(value);
                    },
                  ),
                ),
                const Icon(Icons.volume_up, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

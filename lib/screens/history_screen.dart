import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/generation.dart';
import '../providers/generation_provider.dart';
import '../services/audio_service.dart';
import '../widgets/audio_player_widget.dart';

/// Screen for viewing generation history.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AudioService _audioService = AudioService();
  String? _playingAudioPath;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _playAudio(Generation generation) {
    if (generation.audioFilePath == null) return;
    
    setState(() {
      _playingAudioPath = generation.audioFilePath;
    });
  }

  void _deleteGeneration(Generation generation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer cette génération ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<GenerationProvider>().deleteGeneration(generation.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _reuseText(Generation generation) {
    Navigator.pop(context, generation.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Effacer l\'historique'),
                  content: const Text('Voulez-vous vraiment effacer tout l\'historique ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<GenerationProvider>().clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Effacer', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Tout effacer',
          ),
        ],
      ),
      body: Consumer<GenerationProvider>(
        builder: (context, provider, child) {
          if (provider.history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune génération',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vos générations apparaîtront ici',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final generation = provider.history[index];
              final isPlaying = _playingAudioPath == generation.audioFilePath;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              generation.voiceName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(generation.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        generation.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (generation.audioFilePath != null)
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.stop : Icons.play_arrow,
                                color: isPlaying ? Colors.red : null,
                              ),
                              onPressed: () => _playAudio(generation),
                              tooltip: isPlaying ? 'Arrêter' : 'Écouter',
                            ),
                          IconButton(
                            icon: const Icon(Icons.replay),
                            onPressed: () => _reuseText(generation),
                            tooltip: 'Réutiliser',
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteGeneration(generation),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                      if (isPlaying && generation.audioFilePath != null)
                        AudioPlayerWidget(
                          audioPath: generation.audioFilePath,
                          voiceName: generation.voiceName,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/voice.dart';
import '../providers/generation_provider.dart';
import '../providers/voice_provider.dart';
import '../services/audio_service.dart';
import '../services/export_service.dart';
import '../utils/text_validator.dart';
import '../utils/tv_templates.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/voice_card.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// Main screen for text-to-voice generation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final AudioService _audioService = AudioService();
  Voice? _selectedVoice;
  String? _generatedAudioPath;
  bool _isPreviewing = false;

  @override
  void dispose() {
    _textController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _generate() async {
    final text = _textController.text;
    final error = TextValidator.validate(text);
    if (error != null) {
      _showError(error);
      return;
    }

    if (_selectedVoice == null) {
      _showError('Sélectionnez une voix avant de générer.');
      return;
    }

    final generationProvider = context.read<GenerationProvider>();
    final audioPath = await generationProvider.generateTTS(
      text: text,
      voice: _selectedVoice!,
    );

    if (audioPath != null && mounted) {
      setState(() {
        _generatedAudioPath = audioPath;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio généré avec succès !')),
      );
    } else if (generationProvider.error != null && mounted) {
      _showError(generationProvider.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Templates TV',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: TVTemplates.keys.length,
                itemBuilder: (context, index) {
                  final key = TVTemplates.keys[index];
                  final name = TVTemplates.getTemplateName(key);
                  return ListTile(
                    leading: const Icon(Icons.article),
                    title: Text(name),
                    onTap: () {
                      final template = TVTemplates.getTemplate(key);
                      if (template != null) {
                        _textController.text = template;
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _textController.text;
    final charCount = text.length;
    final direction = TextValidator.detectDirection(text);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: 'Historique',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            Text(
              AppConfig.appSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Text editor
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Texte',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.article, size: 20),
                              onPressed: _showTemplateSelector,
                              tooltip: 'Templates TV',
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear_all, size: 20),
                              onPressed: () {
                                _textController.clear();
                                setState(() {});
                              },
                              tooltip: 'Effacer',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 6,
                      minLines: 4,
                      textDirection: direction == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: 'اكتب النص الذي تريد تحويله إلى صوت...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: direction == 'rtl' ? 'Arial' : null,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$charCount / ${AppConfig.maxTextLength}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: charCount > AppConfig.maxTextLength
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                        ),
                        if (TextValidator.containsArabic(text))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'عربي',
                              style: TextStyle(color: Colors.green, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Voice selection
            Text(
              'Voix',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Consumer<VoiceProvider>(
              builder: (context, voiceProvider, child) {
                if (voiceProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (voiceProvider.error != null) {
                  return Card(
                    color: Colors.red.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            voiceProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: voiceProvider.loadVoices,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (voiceProvider.voices.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune voix disponible. Vérifiez votre configuration API.'),
                    ),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: voiceProvider.voices.length,
                    itemBuilder: (context, index) {
                      final voice = voiceProvider.voices[index];
                      final isSelected = _selectedVoice?.id == voice.id;
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        child: VoiceCard(
                          voice: voice,
                          isSelected: isSelected,
                          isFavorite: voiceProvider.isFavorite(voice.id),
                          onTap: () {
                            setState(() => _selectedVoice = voice);
                          },
                          onFavoriteToggle: () {
                            voiceProvider.toggleFavorite(voice.id);
                          },
                          onPreview: () {
                            setState(() => _isPreviewing = !_isPreviewing);
                          },
                          isPreviewing: _isPreviewing,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Generate button
            Consumer<GenerationProvider>(
              builder: (context, generationProvider, child) {
                return ElevatedButton(
                  onPressed: generationProvider.isGenerating ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
                    ),
                  ),
                  child: generationProvider.isGenerating
                      ? Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              'Génération en cours... ${(generationProvider.generationProgress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        )
                      : const Text(
                          'GÉNÉRER LA VOIX',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Audio player
            if (_generatedAudioPath != null) ...[
              AudioPlayerWidget(
                audioPath: _generatedAudioPath,
                voiceName: _selectedVoice?.name,
                autoPlay: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await ExportService.shareAudioFile(
                            _generatedAudioPath!,
                            text: 'Généré avec Eleven Studio',
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur export: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Exporter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final savedPath = await ExportService.saveAudioFile(
                            _generatedAudioPath!,
                            'eleven_studio',
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sauvegardé: $savedPath')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur sauvegarde: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Sauvegarder'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

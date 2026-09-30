import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_keys.dart';
import '../config/app_config.dart';
import '../models/tts_settings.dart';
import '../providers/generation_provider.dart';

/// Screen for app settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _obscureKey = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Configuration
          _buildSectionTitle(context, 'Configuration API'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        ApiKeys.hasApiKey ? Icons.check_circle : Icons.error,
                        color: ApiKeys.hasApiKey ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ApiKeys.hasApiKey
                            ? 'Clé API configurée'
                            : 'Clé API manquante',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      labelText: 'Clé API ElevenLabs',
                      hintText: 'sk_...',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                    controller: TextEditingController(
                      text: ApiKeys.elevenLabsApiKey ?? '',
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La clé est stockée localement dans le fichier .env et n\'est jamais envoyée sur Git.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Model Selection
          _buildSectionTitle(context, 'Modèle ElevenLabs'),
          Consumer<GenerationProvider>(
            builder: (context, provider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modèle par défaut',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...AppConfig.availableModels.map((modelId) {
                        return RadioListTile<String>(
                          title: Text(modelId),
                          value: modelId,
                          groupValue: provider.selectedModelId ?? AppConfig.defaultModelId,
                          onChanged: (value) {
                            if (value != null) {
                              provider.selectModel(value);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Voice Settings
          _buildSectionTitle(context, 'Paramètres de voix'),
          Consumer<GenerationProvider>(
            builder: (context, provider, child) {
              final settings = provider.settings;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSlider(
                        context,
                        'Stabilité',
                        settings.stability,
                        (v) => provider.updateSettings(settings.copyWith(stability: v)),
                      ),
                      _buildSlider(
                        context,
                        'Similarité',
                        settings.similarityBoost,
                        (v) => provider.updateSettings(settings.copyWith(similarityBoost: v)),
                      ),
                      _buildSlider(
                        context,
                        'Style',
                        settings.style,
                        (v) => provider.updateSettings(settings.copyWith(style: v)),
                      ),
                      _buildSlider(
                        context,
                        'Vitesse',
                        settings.speed,
                        (v) => provider.updateSettings(settings.copyWith(speed: v)),
                      ),
                      SwitchListTile(
                        title: const Text('Speaker Boost'),
                        value: settings.useSpeakerBoost,
                        onChanged: (v) => provider.updateSettings(
                          settings.copyWith(useSpeakerBoost: v),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Presets
          _buildSectionTitle(context, 'Préréglages'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.record_voice_over),
                    title: const Text('Par défaut'),
                    subtitle: const Text('Paramètres équilibrés'),
                    onTap: () {
                      context.read<GenerationProvider>().updateSettings(TTSSettings.defaults);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.translate),
                    title: const Text('Optimisé Arabe/Darija'),
                    subtitle: const Text('Pour une prononciation naturelle'),
                    onTap: () {
                      context.read<GenerationProvider>().updateSettings(TTSSettings.arabicOptimized);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.tv),
                    title: const Text('Broadcast TV'),
                    subtitle: const Text('Pour la présentation et narration'),
                    onTap: () {
                      context.read<GenerationProvider>().updateSettings(TTSSettings.broadcast);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About
          _buildSectionTitle(context, 'À propos'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Application professionnelle de génération de voix propulsée par ElevenLabs.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

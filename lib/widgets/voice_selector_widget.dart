import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_provider.dart';
import 'voice_card.dart';

/// Widget for selecting a voice with search and filters.
class VoiceSelectorWidget extends StatefulWidget {
  final String? selectedVoiceId;
  final ValueChanged<String> onVoiceSelected;

  const VoiceSelectorWidget({
    super.key,
    this.selectedVoiceId,
    required this.onVoiceSelected,
  });

  @override
  State<VoiceSelectorWidget> createState() => _VoiceSelectorWidgetState();
}

class _VoiceSelectorWidgetState extends State<VoiceSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une voix...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: provider.search,
            ),
            const SizedBox(height: 8),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Language filter
                  if (provider.availableLanguages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DropdownButton<String?>(
                        hint: const Text('Langue'),
                        value: provider.selectedLanguage,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Toutes'),
                          ),
                          ...provider.availableLanguages.map((lang) {
                            return DropdownMenuItem<String?>(
                              value: lang,
                              child: Text(lang),
                            );
                          }),
                        ],
                        onChanged: provider.filterByLanguage,
                      ),
                    ),

                  // Gender filter
                  if (provider.availableGenders.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DropdownButton<String?>(
                        hint: const Text('Genre'),
                        value: provider.selectedGender,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tous'),
                          ),
                          ...provider.availableGenders.map((gender) {
                            return DropdownMenuItem<String?>(
                              value: gender,
                              child: Text(gender),
                            );
                          }),
                        ],
                        onChanged: provider.filterByGender,
                      ),
                    ),

                  // Favorites filter
                  FilterChip(
                    label: const Text('Favoris'),
                    selected: provider.showFavoritesOnly,
                    onSelected: (_) => provider.toggleFavoritesOnly(),
                    avatar: provider.showFavoritesOnly
                        ? const Icon(Icons.star, size: 16)
                        : const Icon(Icons.star_border, size: 16),
                  ),

                  // Clear filters
                  if (provider.searchQuery.isNotEmpty ||
                      provider.selectedLanguage != null ||
                      provider.selectedGender != null ||
                      provider.selectedUseCase != null ||
                      provider.showFavoritesOnly)
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Effacer'),
                      onPressed: () {
                        _searchController.clear();
                        provider.clearFilters();
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Voice list
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.error != null)
              Card(
                color: Colors.red.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: provider.loadVoices,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.voices.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune voix disponible. Vérifiez votre configuration API.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: provider.voices.length,
                  itemBuilder: (context, index) {
                    final voice = provider.voices[index];
                    final isSelected = widget.selectedVoiceId == voice.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: VoiceCard(
                        voice: voice,
                        isSelected: isSelected,
                        isFavorite: provider.isFavorite(voice.id),
                        onTap: () => widget.onVoiceSelected(voice.id),
                        onFavoriteToggle: () => provider.toggleFavorite(voice.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

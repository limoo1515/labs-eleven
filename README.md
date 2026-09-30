# Eleven Studio

Application Flutter professionnelle de génération de voix (TTS) propulsée par l'API ElevenLabs.

## Fonctionnalités

- **Texte → Voix** : Écrivez du texte en arabe, français, darija algérienne ou tout autre langage supporté
- **Sélection de voix** : Recherchez, filtrez et écoutez les voix disponibles via l'API ElevenLabs
- **Paramètres de voix** : Stabilité, similarité, style, vitesse, speaker boost
- **Historique** : Retrouvez vos générations précédentes, réutilisez ou supprimez-les
- **Favoris** : Marquez vos voix préférées avec une étoile
- **Export** : Partagez ou sauvegardez vos fichiers audio
- **Templates TV** : Présentation, journal télévisé, breaking news, publicité, voix-off, cuisine, intro/outro
- **Support RTL** : Interface complète pour l'arabe et les langues RTL

## Démarrage

### Prérequis

- Flutter 3.29+ et Dart 3.7+
- Clé API ElevenLabs (obtenue sur [elevenlabs.io](https://elevenlabs.io))

### Configuration

1. Créez un fichier `.env` à la racine du projet :
   ```
   ELEVENLABS_API_KEY=votre_clé_api_ici
   ```

2. **IMPORTANT** : Le fichier `.env` est ignoré par Git. Ne commitez jamais votre clé API.

### Installation

```bash
flutter pub get
flutter run
```

### Build

```bash
# Android
flutter build apk --release

# iOS (nécessite macOS + Xcode)
flutter build ios --release
```

## Architecture

```
lib/
├── config/           # Configuration application et gestion des clés API
├── models/           # Modèles de données (Voice, Generation, TTSSettings)
├── providers/        # Gestion d'état (VoiceProvider, GenerationProvider)
├── screens/          # Écrans (Home, History, Settings)
├── services/         # Services (ElevenLabs, Storage, Audio, Export)
├── utils/            # Utilitaires (validation, templates TV)
└── widgets/          # Widgets réutilisables (VoiceCard, AudioPlayer)
```

## Sécurité

- La clé API est stockée dans `.env` (ignoré par Git)
- Pour la production, utilisez un backend proxy pour éviter d'exposer la clé
- La clé n'est jamais affichée dans les logs

## Tests

```bash
flutter test
```

## Licence

Projet personnel - Tous droits réservés

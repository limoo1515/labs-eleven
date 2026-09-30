/// TV/Broadcast text templates.
/// 
/// These templates help users quickly create professional broadcast scripts.
/// They do NOT generate fake news content - they provide structure only.
class TVTemplates {
  TVTemplates._();

  static const Map<String, String> templates = {
    'presentation': '''Bonjour et bienvenue dans cette nouvelle édition.

Aujourd'hui, nous avons le plaisir de vous présenter un sujet qui nous tient à cœur.

Restez avec nous pour découvrir tous les détails.''',

    'journal': '''Bonjour, voici les titres de l'actualité.

Nous commençons par les nouvelles nationales, suivies des informations internationales.

Place maintenant à la météo de la journée.''',

    'breaking': '''Nous interrompons notre programmation pour vous apporter une information de dernière minute.

Dès que nous aurons plus de détails, nous vous les communiquerons.

Merci de votre attention.''',

    'publicité': '''Vous cherchez la qualité au meilleur prix ?

Découvrez notre nouvelle gamme de produits, spécialement conçus pour vous.

Profitez de nos offres exceptionnelles, disponibles dès maintenant.''',

    'voix_off': '''Dans un monde en constante évolution, certaines choses restent essentielles.

C'est pourquoi nous nous engageons à vous offrir le meilleur, chaque jour.

Parce que vous méritez l'excellence.''',

    'cuisine': '''Aujourd'hui, nous allons préparer une recette simple et délicieuse.

Pour commencer, voici les ingrédients dont vous aurez besoin.

Suivez attentivement chaque étape pour un résultat parfait.''',

    'intro_emission': '''Bienvenue dans notre émission !

Nous sommes ravis de vous retrouver pour ce nouveau numéro.

Au programme aujourd'hui : des sujets variés et des invités exceptionnels.''',

    'outro': '''Voici la fin de notre émission pour aujourd'hui.

Merci de votre fidélité et à très bientôt pour de nouvelles aventures.

Bonne soirée à tous !''',
  };

  /// Get template by key.
  static String? getTemplate(String key) {
    return templates[key];
  }

  /// Get all template keys.
  static List<String> get keys => templates.keys.toList();

  /// Get all template names (localized).
  static Map<String, String> get templateNames => {
    'presentation': 'Présentation TV',
    'journal': 'Journal télévisé',
    'breaking': 'Breaking News',
    'publicité': 'Publicité',
    'voix_off': 'Voix-off',
    'cuisine': 'Cuisine',
    'intro_emission': 'Introduction émission',
    'outro': 'Outro',
  };

  /// Get template name by key.
  static String getTemplateName(String key) {
    return templateNames[key] ?? key;
  }
}

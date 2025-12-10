import 'dart:convert';
import '/core/services/api_client.dart';


class Aliment implements Comparable<Aliment> {
  int? id;
  String? libelle;
  String? groupeAlimentaire;
  double? energieKcal;
  double? energieKj;
  double? proteines;
  double? lipides;
  double? acidesGrasSatures;
  double? acidesGrasMono;
  double? acidesGrasPoly;
  double? acidesGrasOmega3;
  double? acidesGrasOmega6;
  double? acidesLino;
  double? acidesGrasTrans;
  double? cholesterol;
  double? glucidesDigestibles;
  double? sucres;
  double? amidon;
  double? fibres;
  double? eau;
  double? sodium;
  double? potassium;
  double? calcium;
  double? phosphore;
  double? magnesium;
  double? fer;
  double? cuivre;
  double? zinc;
  double? selenium;
  double? vitAeq;
  double? vitB1;
  double? vitB2;
  double? vitB12;
  double? vitC;
  double? vitD;
  String? source;
  DateTime? updatedAt;

  Aliment({
    this.id,
    this.libelle,
    this.groupeAlimentaire,
    this.energieKcal,
    this.energieKj,
    this.proteines,
    this.lipides,
    this.acidesGrasSatures,
    this.acidesGrasMono,
    this.acidesGrasPoly,
    this.acidesGrasOmega3,
    this.acidesGrasOmega6,
    this.acidesLino,
    this.acidesGrasTrans,
    this.cholesterol,
    this.glucidesDigestibles,
    this.sucres,
    this.amidon,
    this.fibres,
    this.eau,
    this.sodium,
    this.potassium,
    this.calcium,
    this.phosphore,
    this.magnesium,
    this.fer,
    this.cuivre,
    this.zinc,
    this.selenium,
    this.vitAeq,
    this.vitB1,
    this.vitB2,
    this.vitB12,
    this.vitC,
    this.vitD,
    this.source,
    this.updatedAt,
  });


  /* -----------------------------------------------------------------------
   * Conversion JSON vers Objet Aliment
   * --------------------------------------------------------------------- */

  factory Aliment.fromJson(Map<String, dynamic> json) {
    return Aliment(
      id: json['id'] as int?,
      libelle: json['libelle'] as String?,
      groupeAlimentaire: json['groupe_alimentaire'] as String?,
      energieKcal: (json['energie_kcal'] as num?)?.toDouble(),
      energieKj: (json['energie_kj'] as num?)?.toDouble(),
      proteines: (json['proteines'] as num?)?.toDouble(),
      lipides: (json['lipides'] as num?)?.toDouble(),
      acidesGrasSatures: (json['acides_gras_satures'] as num?)?.toDouble(),
      acidesGrasMono: (json['acides_gras_mono'] as num?)?.toDouble(),
      acidesGrasPoly: (json['acides_gras_poly'] as num?)?.toDouble(),
      acidesGrasOmega3: (json['acides_gras_omega_3'] as num?)?.toDouble(),
      acidesGrasOmega6: (json['acides_gras_omega_6'] as num?)?.toDouble(),
      acidesLino: (json['acides_lino'] as num?)?.toDouble(),
      acidesGrasTrans: (json['acides_gras_trans'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      glucidesDigestibles: (json['glucides_digestibles'] as num?)?.toDouble(),
      sucres: (json['sucres'] as num?)?.toDouble(),
      amidon: (json['amidon'] as num?)?.toDouble(),
      fibres: (json['fibres'] as num?)?.toDouble(),
      eau: (json['eau'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      phosphore: (json['phosphore'] as num?)?.toDouble(),
      magnesium: (json['magnesium'] as num?)?.toDouble(),
      fer: (json['fer'] as num?)?.toDouble(),
      cuivre: (json['cuivre'] as num?)?.toDouble(),
      zinc: (json['zinc'] as num?)?.toDouble(),
      selenium: (json['selenium'] as num?)?.toDouble(),
      vitAeq: (json['vit_a_eq'] as num?)?.toDouble(),
      vitB1: (json['vit_b1'] as num?)?.toDouble(),
      vitB2: (json['vit_b2'] as num?)?.toDouble(),
      vitB12: (json['vit_b12'] as num?)?.toDouble(),
      vitC: (json['vit_c'] as num?)?.toDouble(),
      vitD: (json['vit_d'] as num?)?.toDouble(),
      source: json['source'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,

    );
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : get groupes alimentaires
   * --------------------------------------------------------------------- */
  static Future<List<Map<String, dynamic>>> getGroupesAlimentaires() async {
    final response = await ApiClient.get('get_groupes_alimentaires');
    if (response.statusCode != 200) {
      throw Exception('Failed to get groupes alimentaires (status ${response.statusCode})');
    }
    final List<dynamic> body = json.decode(response.body) as List<dynamic>;
    return body.map((dynamic item) => item as Map<String, dynamic>).toList();
  }

  /* -----------------------------------------------------------------------
   * Obtenir l'ID d'un groupe alimentaire à partir de son nom
   * --------------------------------------------------------------------- */
  static Future<int> getGroupeAlimentaireId(String groupeName) async {
    final groupes = await getGroupesAlimentaires();
    final groupe = groupes.firstWhere(
      (g) => g['libelle'] == groupeName,
      orElse: () => {'id': 16}, // Divers par défaut
    );
    return groupe['id'] as int;
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : get my aliments
   * --------------------------------------------------------------------- */
  static Future<List<Aliment>> getMyAliments() async {
    final response = await ApiClient.get('get_my_aliments');
    if (response.statusCode != 200) {
      throw Exception('Failed to get aliments (status ${response.statusCode})');
    }
    final List<dynamic> body = json.decode(response.body) as List<dynamic>;
    return body
        .map((dynamic item) => Aliment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : delete aliment
   * --------------------------------------------------------------------- */
  Future<void> deleteAliment() async {
    final response = await ApiClient.post(
      'delete_aliment',
      body: json.encode({'aliment_id': id}),
    );
    print('Réponse body: ${response.body}');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete aliment (status: ${response.statusCode})');
    }
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : save aliment
   * --------------------------------------------------------------------- */
  static Future<Aliment> saveAliment(
      int id,
      String libelle,
      int groupeAlimentaireId,
      double? energieKcal,
      double? energieKj,
      double? proteines,
      double? lipides,
      double? acidesGrasSatures,
      double? acidesGrasMono,
      double? acidesGrasPoly,
      double? acidesGrasOmega3,
      double? acidesGrasOmega6,
      double? acidesLino,
      double? acidesGrasTrans,
      double? cholesterol,
      double? glucidesDigestibles,
      double? sucres,
      double? amidon,
      double? fibres,
      double? eau,
      double? sodium,
      double? potassium,
      double? calcium,
      double? phosphore,
      double? magnesium,
      double? fer,
      double? cuivre,
      double? zinc,
      double? selenium,
      double? vitAeq,
      double? vitB1,
      double? vitB2,
      double? vitB12,
      double? vitC,
      double? vitD,
      String? source
      ) async {
    final response = await ApiClient.post(
      'save_aliment',
      body: json.encode({
        'id': id,
        'libelle': libelle.trim(),
        'groupe_id': groupeAlimentaireId,
        'energie_kcal': energieKcal,
        'energie_kj': energieKj,
        'proteines': proteines,
        'lipides': lipides,
        'acides_gras_satures': acidesGrasSatures,
        'acides_gras_mono': acidesGrasMono,
        'acides_gras_poly': acidesGrasPoly,
        'acides_gras_omega_3': acidesGrasOmega3,
        'acides_gras_omega_6': acidesGrasOmega6,
        'acides_lino': acidesLino,
        'acides_gras_trans': acidesGrasTrans,
        'cholesterol': cholesterol,
        'glucides_digestibles': glucidesDigestibles,
        'sucres': sucres,
        'amidon': amidon,
        'fibres': fibres,
        'eau': eau,
        'sodium': sodium,
        'potassium': potassium,
        'calcium': calcium,
        'phosphore': phosphore,
        'magnesium': magnesium,
        'fer': fer,
        'cuivre': cuivre,
        'zinc': zinc,
        'selenium': selenium,
        'vit_a_eq': vitAeq,
        'vit_b1': vitB1,
        'vit_b2': vitB2,
        'vit_b12': vitB12,
        'vit_c': vitC,
        'vit_d': vitD,
        'source': source?.trim()
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return Aliment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to save aliments (status: ${response.body})');
    }
  }

  /* -------------------------------------------------------------
   * egalite / tri – par `createdAt` puis id
   * ----------------------------------------------------------- */

  @override // hashCode
  int get hashCode => id.hashCode;

  @override // equals
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Aliment && runtimeType == other.runtimeType && id == other.id;

  @override // compareTo
  int compareTo(Aliment other) {
    final thisLibelle = libelle ?? '';
    final otherLibelle = other.libelle ?? '';
    return thisLibelle.compareTo(otherLibelle);
  }

}
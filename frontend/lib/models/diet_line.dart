import 'dart:convert';
import '/core/services/api_client.dart';

class DietLine implements Comparable<DietLine> {
  int?   id;
  int?   userId;
  int?   alimentId;
  String? libelle;
  int?   quantity;
  String? unity;             // g | ml
  int?   frequency;          // nb / jour

  /*  valeurs /100 g  */
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

  DietLine({
    this.id,
    this.userId,
    this.alimentId,
    this.libelle,
    this.quantity,
    this.unity,
    this.frequency,
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
   * Conversion JSON vers Objet DietLine
   * --------------------------------------------------------------------- */
  factory DietLine.fromJson(Map<String, dynamic> json) => DietLine(
        id        : json['id']           as int?,
        userId    : json['user_id']      as int?,
        alimentId : json['aliment_id']   as int?,           // <-- récupéré du SELECT
        libelle   : json['aliment_libelle'] as String?,      // <-- alias dans la vue
        quantity  : (json['quantity']    as num?)?.toInt(),
        unity     : json['unity']        as String?,
        frequency : (json['frequency']   as num?)?.toInt(),

        energieKcal : (json['energie_kcal'] as num?)?.toDouble(),
        energieKj   : (json['energie_kj']   as num?)?.toDouble(),
        proteines   : (json['proteines']    as num?)?.toDouble(),
        lipides     : (json['lipides']      as num?)?.toDouble(),
        acidesGrasSatures : (json['acides_gras_satures'] as num?)?.toDouble(),
        acidesGrasMono    : (json['acides_gras_mono']    as num?)?.toDouble(),
        acidesGrasPoly    : (json['acides_gras_poly']    as num?)?.toDouble(),
        acidesGrasOmega3  : (json['acides_gras_omega_3'] as num?)?.toDouble(),
        acidesGrasOmega6  : (json['acides_gras_omega_6'] as num?)?.toDouble(),
        acidesLino        : (json['acides_lino']         as num?)?.toDouble(),
        acidesGrasTrans   : (json['acides_gras_trans']   as num?)?.toDouble(),
        cholesterol       : (json['cholesterol']         as num?)?.toDouble(),
        glucidesDigestibles : (json['glucides_digestibles'] as num?)?.toDouble(),
        sucres            : (json['sucres']              as num?)?.toDouble(),
        amidon            : (json['amidon']              as num?)?.toDouble(),
        fibres            : (json['fibres']              as num?)?.toDouble(),
        eau               : (json['eau']                 as num?)?.toDouble(),
        sodium            : (json['sodium']              as num?)?.toDouble(),
        potassium         : (json['potassium']           as num?)?.toDouble(),
        calcium           : (json['calcium']             as num?)?.toDouble(),
        phosphore         : (json['phosphore']           as num?)?.toDouble(),
        magnesium         : (json['magnesium']           as num?)?.toDouble(),
        fer               : (json['fer']                 as num?)?.toDouble(),
        cuivre            : (json['cuivre']              as num?)?.toDouble(),
        zinc              : (json['zinc']                as num?)?.toDouble(),
        selenium          : (json['selenium']            as num?)?.toDouble(),
        vitAeq            : (json['vit_a_eq']            as num?)?.toDouble(),
        vitB1             : (json['vit_b1']              as num?)?.toDouble(),
        vitB2             : (json['vit_b2']              as num?)?.toDouble(),
        vitB12            : (json['vit_b12']             as num?)?.toDouble(),
        vitC              : (json['vit_c']               as num?)?.toDouble(),
        vitD              : (json['vit_d']               as num?)?.toDouble(),
        source            : json['source']               as String?,
        updatedAt         : json['aliment_updated_at'] != null
                              ? DateTime.parse(json['aliment_updated_at'] as String)
                              : null,
      );

  /* -----------------------------------------------------------------------
   * Appel endpoint : get diet lines
   * --------------------------------------------------------------------- */
  static Future<List<DietLine>> getDietLines() async {
    final response = await ApiClient.get('get_diet_lines');
    if (response.statusCode != 200) {
      throw Exception('Failed to get diet lines (status ${response.statusCode})');
    }
    final List<dynamic> body = json.decode(response.body) as List<dynamic>;
    return body.map((e) => DietLine.fromJson(e as Map<String,dynamic>)).toList();
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : save diet line
   * --------------------------------------------------------------------- */
  static Future<DietLine> saveDietLine({
    required int id,
    required int alimentId,
    required int quantity,
    required String unity,
    required int frequency,
  }) async {

    final response = await ApiClient.post(
      'save_diet_line',
      body: json.encode({
        'id'        : id,
        'aliment_id': alimentId,
        'quantity'  : quantity,
        'unity'     : unity.trim(),
        'frequency' : frequency,
      }),
    );

    if (response.statusCode == 200) {
      return DietLine.fromJson(json.decode(response.body) as Map<String,dynamic>);
    } else {
      throw Exception('Failed to save diet line (status ${response.statusCode})');
    }
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : get delete diet line
   * --------------------------------------------------------------------- */
  Future<void> deleteDietLine() async {
    final response = await ApiClient.post(
      'delete_diet_line',
      body: json.encode({'diet_line_id': id}),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete diet line (status ${response.statusCode})');
    }
  }

  /* -----------------------------------------------------------------------
   * Méthode copyWith pour créer une copie modifiée
   * --------------------------------------------------------------------- */
  DietLine copyWith({
    int? id,
    int? userId,
    int? alimentId,
    String? libelle,
    int? quantity,
    String? unity,
    int? frequency,
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
    String? source,
    DateTime? updatedAt,
  }) {
    return DietLine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alimentId: alimentId ?? this.alimentId,
      libelle: libelle ?? this.libelle,
      quantity: quantity ?? this.quantity,
      unity: unity ?? this.unity,
      frequency: frequency ?? this.frequency,
      energieKcal: energieKcal ?? this.energieKcal,
      energieKj: energieKj ?? this.energieKj,
      proteines: proteines ?? this.proteines,
      lipides: lipides ?? this.lipides,
      acidesGrasSatures: acidesGrasSatures ?? this.acidesGrasSatures,
      acidesGrasMono: acidesGrasMono ?? this.acidesGrasMono,
      acidesGrasPoly: acidesGrasPoly ?? this.acidesGrasPoly,
      acidesGrasOmega3: acidesGrasOmega3 ?? this.acidesGrasOmega3,
      acidesGrasOmega6: acidesGrasOmega6 ?? this.acidesGrasOmega6,
      acidesLino: acidesLino ?? this.acidesLino,
      acidesGrasTrans: acidesGrasTrans ?? this.acidesGrasTrans,
      cholesterol: cholesterol ?? this.cholesterol,
      glucidesDigestibles: glucidesDigestibles ?? this.glucidesDigestibles,
      sucres: sucres ?? this.sucres,
      amidon: amidon ?? this.amidon,
      fibres: fibres ?? this.fibres,
      eau: eau ?? this.eau,
      sodium: sodium ?? this.sodium,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      phosphore: phosphore ?? this.phosphore,
      magnesium: magnesium ?? this.magnesium,
      fer: fer ?? this.fer,
      cuivre: cuivre ?? this.cuivre,
      zinc: zinc ?? this.zinc,
      selenium: selenium ?? this.selenium,
      vitAeq: vitAeq ?? this.vitAeq,
      vitB1: vitB1 ?? this.vitB1,
      vitB2: vitB2 ?? this.vitB2,
      vitB12: vitB12 ?? this.vitB12,
      vitC: vitC ?? this.vitC,
      vitD: vitD ?? this.vitD,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /* -----------------------------------------------------------------------
   * Tri / Hash
   * --------------------------------------------------------------------- */
  @override int get hashCode => id.hashCode;
  @override bool operator==(Object o) => o is DietLine && o.id == id;
  @override int compareTo(DietLine other) => (id ?? 0).compareTo(other.id ?? 0);
}
import 'dart:convert';
import '/core/services/api_client.dart';


class Ciqual implements Comparable<Ciqual> {
  String? libelle;
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
  String source = "Ciqual";

  Ciqual({
    this.libelle,
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
  });


  /* -----------------------------------------------------------------------
   * Conversion JSON vers Objet Aliment
   * --------------------------------------------------------------------- */

  factory Ciqual.fromJson(Map<String, dynamic> json) {
    return Ciqual(
      libelle: json['libelle'] as String?,
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
      vitD: (json['vit_d'] as num?)?.toDouble()
    );
  }

  /* -----------------------------------------------------------------------
   * Appel endpoint : get ciqual
   * --------------------------------------------------------------------- */
  static Future<List<Ciqual>> getCiqual() async {
    final response = await ApiClient.get('get_ciqual');
    print(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to get ciqual (status ${response.statusCode})');
    }
    final List<dynamic> body = json.decode(response.body) as List<dynamic>;
    return body
        .map((dynamic item) => Ciqual.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /* -------------------------------------------------------------
   * egalite / tri
   * ----------------------------------------------------------- */

  @override // hashCode
  int get hashCode => libelle.hashCode;

  @override // equals
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Ciqual && runtimeType == other.runtimeType && libelle == other.libelle;

  @override // compareTo
  int compareTo(Ciqual other) {
    final thisLibelle = libelle ?? '';
    final otherLibelle = other.libelle ?? '';
    return thisLibelle.compareTo(otherLibelle);
  }

}
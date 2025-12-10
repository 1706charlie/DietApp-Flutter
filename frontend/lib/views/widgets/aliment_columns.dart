// lib/views/widgets/aliment_columns.dart
import '../../models/aliment.dart';

class AlimentColumn {
  const AlimentColumn(
      this.label,
      this.get, {
        required this.field,
        this.numeric = false,
      });

  final String  label;
  final String? Function(Aliment) get;
  final String  field;
  final bool    numeric;
}

String? _n(num? v) => v == null ? null : v.toStringAsFixed(1);

const double kNameColWidth = 250;
const double kNumColWidth  = 55;

final List<AlimentColumn> kAlimentColumns = [
  AlimentColumn('ÉNERGIE KCAL', (a) => _n(a.energieKcal),
      field: 'energie_kcal', numeric: true),
  AlimentColumn('ÉNERGIE KJ',  (a) => _n(a.energieKj),
      field: 'energie_kj',  numeric: true),
  AlimentColumn('PROTÉINES',   (a) => _n(a.proteines),
      field: 'proteines',   numeric: true),
  AlimentColumn('LIPIDES',     (a) => _n(a.lipides),
      field: 'lipides',     numeric: true),
  AlimentColumn('AG SATURÉS',  (a) => _n(a.acidesGrasSatures),
      field: 'acides_gras_satures', numeric: true),
  AlimentColumn('AG MONO',     (a) => _n(a.acidesGrasMono),
      field: 'acides_gras_mono', numeric: true),
  AlimentColumn('AG POLY',     (a) => _n(a.acidesGrasPoly),
      field: 'acides_gras_poly', numeric: true),
  AlimentColumn('AG OMEGA 3',  (a) => _n(a.acidesGrasOmega3),
      field: 'acides_gras_omega_3', numeric: true),
  AlimentColumn('AG OMEGA 6',  (a) => _n(a.acidesGrasOmega6),
      field: 'acides_gras_omega_6', numeric: true),
  AlimentColumn('AG LINO',     (a) => _n(a.acidesLino),
      field: 'acides_lino', numeric: true),
  AlimentColumn('AG TRANS',    (a) => _n(a.acidesGrasTrans),
      field: 'acides_gras_trans', numeric: true),
  AlimentColumn('CHOLESTÉROL', (a) => _n(a.cholesterol),
      field: 'cholesterol', numeric: true),
  AlimentColumn('GLUCIDES DIG', (a) => _n(a.glucidesDigestibles),
      field: 'glucides_digestibles', numeric: true),
  AlimentColumn('SUCRES',      (a) => _n(a.sucres),
      field: 'sucres', numeric: true),
  AlimentColumn('AMIDON',      (a) => _n(a.amidon),
      field: 'amidon', numeric: true),
  AlimentColumn('FIBRES',      (a) => _n(a.fibres),
      field: 'fibres', numeric: true),
  AlimentColumn('EAU',         (a) => _n(a.eau),
      field: 'eau', numeric: true),
  AlimentColumn('SODIUM',      (a) => _n(a.sodium),
      field: 'sodium', numeric: true),
  AlimentColumn('POTASSIUM',   (a) => _n(a.potassium),
      field: 'potassium', numeric: true),
  AlimentColumn('CALCIUM',     (a) => _n(a.calcium),
      field: 'calcium', numeric: true),
  AlimentColumn('PHOSPHORE',   (a) => _n(a.phosphore),
      field: 'phosphore', numeric: true),
  AlimentColumn('MAGNÉSIUM',   (a) => _n(a.magnesium),
      field: 'magnesium', numeric: true),
  AlimentColumn('FER',         (a) => _n(a.fer),
      field: 'fer', numeric: true),
  AlimentColumn('CUIVRE',      (a) => _n(a.cuivre),
      field: 'cuivre', numeric: true),
  AlimentColumn('ZINC',        (a) => _n(a.zinc),
      field: 'zinc', numeric: true),
  AlimentColumn('SÉLÉNIUM',    (a) => _n(a.selenium),
      field: 'selenium', numeric: true),
  AlimentColumn('VIT A EQ',    (a) => _n(a.vitAeq),
      field: 'vit_a_eq', numeric: true),
  AlimentColumn('VIT B1',      (a) => _n(a.vitB1),
      field: 'vit_b1', numeric: true),
  AlimentColumn('VIT B2',      (a) => _n(a.vitB2),
      field: 'vit_b2', numeric: true),
  AlimentColumn('VIT B12',     (a) => _n(a.vitB12),
      field: 'vit_b12', numeric: true),
  AlimentColumn('VIT C',       (a) => _n(a.vitC),
      field: 'vit_c', numeric: true),
  AlimentColumn('VIT D',       (a) => _n(a.vitD),
      field: 'vit_d', numeric: true),
  AlimentColumn('SOURCE',      (a) => a.source,
      field: 'source', numeric: false),
];
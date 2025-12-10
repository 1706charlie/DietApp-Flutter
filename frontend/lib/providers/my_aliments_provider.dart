import 'dart:collection';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/aliment.dart';
import 'security_provider.dart';

final myAlimentsProvider =
AsyncNotifierProvider<MyAlimentsNotifier, SplayTreeSet<Aliment>>(() => MyAlimentsNotifier());

class MyAlimentsNotifier extends AsyncNotifier<SplayTreeSet<Aliment>> {
  @override
  Future<SplayTreeSet<Aliment>> build() async {
    ref.watch(securityProvider);
    state = AsyncData(SplayTreeSet<Aliment>());
    state = AsyncLoading();
    try {
      return SplayTreeSet<Aliment>.from(await Aliment.getMyAliments());
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return SplayTreeSet<Aliment>();
    }
  }

  Future<Aliment?> saveAliment(
      int id,
      String libelle,
      int groupeAlimentaireId,
      double energieKcal,
      double energieKj,
      double proteines,
      double lipides,
      double acidesGrasSatures,
      double acidesGrasMono,
      double acidesGrasPoly,
      double acidesGrasOmega3,
      double acidesGrasOmega6,
      double acidesLino,
      double acidesGrasTrans,
      double cholesterol,
      double glucidesDigestibles,
      double sucres,
      double amidon,
      double fibres,
      double eau,
      double sodium,
      double potassium,
      double calcium,
      double phosphore,
      double magnesium,
      double fer,
      double zinc,
      double cuivre,
      double selenium,
      double vitAeq,
      double vitB1,
      double vitB2,
      double vitB12,
      double vitC,
      double vitD,
      String source
    ) async {
    state = const AsyncValue.loading();
    try {
      final newAliment = await Aliment.saveAliment(
          id,
          libelle,
          groupeAlimentaireId,
          energieKcal,
          energieKj,
          proteines,
          lipides,
          acidesGrasSatures,
          acidesGrasMono,
          acidesGrasPoly,
          acidesGrasOmega3,
          acidesGrasOmega6,
          acidesLino,
          acidesGrasTrans,
          cholesterol,
          glucidesDigestibles,
          sucres,
          amidon,
          fibres,
          eau,
          sodium,
          potassium,
          calcium,
          phosphore,
          magnesium,
          fer,
          zinc,
          cuivre,
          selenium,
          vitAeq,
          vitB1,
          vitB2,
          vitB12,
          vitC,
          vitD,
          source
      ); // on s'occupe de la db
      final aliments = state.value!;
      if (id == 0) { // création d'un tricount
        aliments.add(newAliment);
      } else { // modification de tricount
        aliments.removeWhere((element) => element.id == id);
        aliments.add(newAliment);
      }
      state = AsyncData(aliments); // appel réussi // state vaut le nouvel état : la nouvelle liste my tricounts
      return newAliment;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current); // erreur
      return null;
    }
  }

  Future<bool> deleteAliment(Aliment aliment) async {
    state = const AsyncValue.loading(); // chargement
    try {
      await aliment.deleteAliment(); // on s'occupe de la db
      final aliments = state.value!; // on récupère le set d'aliments
      aliments.remove(aliment);
      state = AsyncData(aliments); // appel réussi // state vaut le nouvel état : le set d'aliments
      return true;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return false;
    }
  }

  Future<Aliment?> addAliment(String libelle, String groupeAlimentaire) async {
    state = const AsyncValue.loading();
    try {
      // Obtenir l'ID du groupe alimentaire spécifié
      final groupeAlimentaireId = await Aliment.getGroupeAlimentaireId(groupeAlimentaire);
      
      // Créer un nouvel aliment avec toutes les valeurs à null sauf le libellé
      final newAliment = await Aliment.saveAliment(
        0, // id = 0 pour création
        libelle,
        groupeAlimentaireId,
        null, // energieKcal
        null, // energieKj
        null, // proteines
        null, // lipides
        null, // acidesGrasSatures
        null, // acidesGrasMono
        null, // acidesGrasPoly
        null, // acidesGrasOmega3
        null, // acidesGrasOmega6
        null, // acidesLino
        null, // acidesGrasTrans
        null, // cholesterol
        null, // glucidesDigestibles
        null, // sucres
        null, // amidon
        null, // fibres
        null, // eau
        null, // sodium
        null, // potassium
        null, // calcium
        null, // phosphore
        null, // magnesium
        null, // fer
        null, // cuivre
        null, // zinc
        null, // selenium
        null, // vitAeq
        null, // vitB1
        null, // vitB2
        null, // vitB12
        null, // vitC
        null, // vitD
        null, // source
      );
      
      // Ajouter le nouvel aliment à la liste
      final aliments = state.value!;
      aliments.add(newAliment);
      state = AsyncData(aliments);
      
      return newAliment;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return null;
    }
  }

  Future<void> updateField(int id, String field, String value) async {
    final aliments = state.value;
    if (aliments == null) return;

    // Trouver l'aliment à modifier
    final aliment = aliments.firstWhere((a) => a.id == id);
    if (aliment == null) return;

    // Créer une copie de l'aliment avec le champ modifié
    final updatedAliment = Aliment(
      id: aliment.id,
      libelle: aliment.libelle,
      groupeAlimentaire: aliment.groupeAlimentaire,
      energieKcal: aliment.energieKcal,
      energieKj: aliment.energieKj,
      proteines: aliment.proteines,
      lipides: aliment.lipides,
      acidesGrasSatures: aliment.acidesGrasSatures,
      acidesGrasMono: aliment.acidesGrasMono,
      acidesGrasPoly: aliment.acidesGrasPoly,
      acidesGrasOmega3: aliment.acidesGrasOmega3,
      acidesGrasOmega6: aliment.acidesGrasOmega6,
      acidesLino: aliment.acidesLino,
      acidesGrasTrans: aliment.acidesGrasTrans,
      cholesterol: aliment.cholesterol,
      glucidesDigestibles: aliment.glucidesDigestibles,
      sucres: aliment.sucres,
      amidon: aliment.amidon,
      fibres: aliment.fibres,
      eau: aliment.eau,
      sodium: aliment.sodium,
      potassium: aliment.potassium,
      calcium: aliment.calcium,
      phosphore: aliment.phosphore,
      magnesium: aliment.magnesium,
      fer: aliment.fer,
      cuivre: aliment.cuivre,
      zinc: aliment.zinc,
      selenium: aliment.selenium,
      vitAeq: aliment.vitAeq,
      vitB1: aliment.vitB1,
      vitB2: aliment.vitB2,
      vitB12: aliment.vitB12,
      vitC: aliment.vitC,
      vitD: aliment.vitD,
      source: aliment.source,
      updatedAt: aliment.updatedAt,
    );

    // Mettre à jour le champ spécifique
    switch (field) {
      case 'libelle':
        updatedAliment.libelle = value.isEmpty ? null : value;
        break;
      case 'groupe_alimentaire':
        updatedAliment.groupeAlimentaire = value.isEmpty ? null : value;
        break;
      case 'energie_kcal':
        updatedAliment.energieKcal = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'energie_kj':
        updatedAliment.energieKj = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'proteines':
        updatedAliment.proteines = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'lipides':
        updatedAliment.lipides = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_gras_satures':
        updatedAliment.acidesGrasSatures = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_gras_mono':
        updatedAliment.acidesGrasMono = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_gras_poly':
        updatedAliment.acidesGrasPoly = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_gras_omega_3':
        updatedAliment.acidesGrasOmega3 = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_gras_omega_6':
        updatedAliment.acidesGrasOmega6 = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_lino':
        updatedAliment.acidesLino = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'acides_gras_trans':
        updatedAliment.acidesGrasTrans = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'cholesterol':
        updatedAliment.cholesterol = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'glucides_digestibles':
        updatedAliment.glucidesDigestibles = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'sucres':
        updatedAliment.sucres = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'amidon':
        updatedAliment.amidon = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'fibres':
        updatedAliment.fibres = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'eau':
        updatedAliment.eau = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'sodium':
        updatedAliment.sodium = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'potassium':
        updatedAliment.potassium = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'calcium':
        updatedAliment.calcium = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'phosphore':
        updatedAliment.phosphore = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'magnesium':
        updatedAliment.magnesium = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'fer':
        updatedAliment.fer = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'cuivre':
        updatedAliment.cuivre = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'zinc':
        updatedAliment.zinc = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'selenium':
        updatedAliment.selenium = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'vit_a_eq':
        updatedAliment.vitAeq = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'vit_b1':
        updatedAliment.vitB1 = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'vit_b2':
        updatedAliment.vitB2 = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'vit_b12':
        updatedAliment.vitB12 = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'vit_c':
        updatedAliment.vitC = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'vit_d':
        updatedAliment.vitD = value.isEmpty ? null : double.tryParse(value);
        break;
      case 'source':
        updatedAliment.source = value.isEmpty ? null : value;
        break;
      default:
        throw Exception('Champ inconnu: $field');
    }

    // Obtenir l'ID du groupe alimentaire
    final groupeAlimentaireId = await Aliment.getGroupeAlimentaireId(
      updatedAliment.groupeAlimentaire ?? 'Divers'
    );

    // Sauvegarder l'aliment modifié
    final savedAliment = await Aliment.saveAliment(
      updatedAliment.id!,
      updatedAliment.libelle ?? '',
      groupeAlimentaireId,
      updatedAliment.energieKcal,
      updatedAliment.energieKj,
      updatedAliment.proteines,
      updatedAliment.lipides,
      updatedAliment.acidesGrasSatures,
      updatedAliment.acidesGrasMono,
      updatedAliment.acidesGrasPoly,
      updatedAliment.acidesGrasOmega3,
      updatedAliment.acidesGrasOmega6,
      updatedAliment.acidesLino,
      updatedAliment.acidesGrasTrans,
      updatedAliment.cholesterol,
      updatedAliment.glucidesDigestibles,
      updatedAliment.sucres,
      updatedAliment.amidon,
      updatedAliment.fibres,
      updatedAliment.eau,
      updatedAliment.sodium,
      updatedAliment.potassium,
      updatedAliment.calcium,
      updatedAliment.phosphore,
      updatedAliment.magnesium,
      updatedAliment.fer,
      updatedAliment.cuivre,
      updatedAliment.zinc,
      updatedAliment.selenium,
      updatedAliment.vitAeq,
      updatedAliment.vitB1,
      updatedAliment.vitB2,
      updatedAliment.vitB12,
      updatedAliment.vitC,
      updatedAliment.vitD,
      updatedAliment.source,
    );

    // Mettre à jour l'état
    aliments.remove(aliment);
    aliments.add(savedAliment);
    state = AsyncData(aliments);
  }
}

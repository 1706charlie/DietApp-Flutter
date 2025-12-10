import 'dart:collection';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/diet_line.dart';
import 'security_provider.dart';

final dietLinesProvider =
AsyncNotifierProvider<DietLinesNotifier, SplayTreeSet<DietLine>>(() => DietLinesNotifier());

class DietLinesNotifier extends AsyncNotifier<SplayTreeSet<DietLine>> {
  @override
  Future<SplayTreeSet<DietLine>> build() async {
    ref.watch(securityProvider);
    state = AsyncData(SplayTreeSet<DietLine>());
    state = AsyncLoading();
    try {
      return SplayTreeSet<DietLine>.from(await DietLine.getDietLines());
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return SplayTreeSet<DietLine>();
    }
  }

  Future<DietLine?> saveDietLine({
    required int id,
    required int alimentId,
    required int quantity,
    required String unity,
    required int frequency,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newDietLine = await DietLine.saveDietLine(
        id: id,
        alimentId: alimentId,
        quantity: quantity,
        unity: unity,
        frequency: frequency,
      );
      
      final dietLines = state.value!;
      if (id == 0) { // création d'une ligne de régime
        dietLines.add(newDietLine);
      } else { // modification de ligne de régime
        dietLines.removeWhere((element) => element.id == id);
        dietLines.add(newDietLine);
      }
      state = AsyncData(dietLines);
      return newDietLine;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return null;
    }
  }

  Future<bool> deleteDietLine(DietLine dietLine) async {
    state = const AsyncValue.loading();
    try {
      await dietLine.deleteDietLine();
      final dietLines = state.value!;
      dietLines.remove(dietLine);
      state = AsyncData(dietLines);
      return true;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return false;
    }
  }

  Future<DietLine?> addDietLine({
    required int alimentId,
    int quantity = 0, // Quantité vide par défaut
    required String unity,
    int frequency = 1, // Fréquence égale à 1 par défaut
  }) async {
    state = const AsyncValue.loading();
    try {
      final newDietLine = await DietLine.saveDietLine(
        id: 0, // id = 0 pour création
        alimentId: alimentId,
        quantity: quantity,
        unity: unity,
        frequency: frequency,
      );
      
      final dietLines = state.value!;
      dietLines.add(newDietLine);
      state = AsyncData(dietLines);
      
      return newDietLine;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return null;
    }
  }

  Future<bool> updateDietLineField(DietLine dietLine, String field, String value) async {
    try {
      // Créer une copie modifiée de la DietLine
      DietLine updatedDietLine;
      
      switch (field) {
        case 'quantity':
          final quantity = value.isEmpty ? 0 : int.tryParse(value);
          if (quantity == null) return false;
          updatedDietLine = dietLine.copyWith(quantity: quantity);
          break;
        case 'unity':
          updatedDietLine = dietLine.copyWith(unity: value);
          break;
        case 'frequency':
          final frequency = value.isEmpty ? 1 : int.tryParse(value);
          if (frequency == null || frequency <= 0) return false;
          updatedDietLine = dietLine.copyWith(frequency: frequency);
          break;
        default:
          return false;
      }
      
      // Mettre à jour immédiatement l'état pour un affichage en temps réel
      final dietLines = state.value!;
      dietLines.remove(dietLine);
      dietLines.add(updatedDietLine);
      state = AsyncData(dietLines);
      
      // Sauvegarder en arrière-plan
      _saveDietLineInBackground(updatedDietLine);
      
      return true;
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
      return false;
    }
  }

  // Méthode pour sauvegarder en arrière-plan sans bloquer l'interface
  Future<void> _saveDietLineInBackground(DietLine dietLine) async {
    try {
      await DietLine.saveDietLine(
        id: dietLine.id ?? 0,
        alimentId: dietLine.alimentId ?? 0,
        quantity: dietLine.quantity ?? 0,
        unity: dietLine.unity ?? 'g',
        frequency: dietLine.frequency ?? 1,
      );
    } catch (e) {
      // En cas d'erreur, on pourrait afficher un message à l'utilisateur
      print('Erreur lors de la sauvegarde: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final dietLines = await DietLine.getDietLines();
      state = AsyncData(SplayTreeSet<DietLine>.from(dietLines));
    } catch (e) {
      state = AsyncValue.error("Something went wrong!\nPlease try again later.", StackTrace.current);
    }
  }
}

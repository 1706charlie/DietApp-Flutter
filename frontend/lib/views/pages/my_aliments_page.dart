// my_aliments_page.dart
// ───────────────────────────────────────────────────────────
// Table virtuelle rapide grâce à PaginatedDataTable2
// première colonne fixe + entêtes pivotées
// ───────────────────────────────────────────────────────────
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/aliment.dart';
import '../../providers/my_aliments_provider.dart';
import '../widgets/aliments_grid.dart';

/*────────── constantes de largeur ─────────*/
const double kNameColWidth = 170; // libellé d’aliment
const double kNumColWidth  = 60;  // chaque nutriment

/*────────── dimensions fixes pour le tableau ─────────*/
const int    _rowsPerPage  = 20;      // pagination du PaginatedDataTable2
const double _rowHeight    = 56.0;    // hauteur d’une ligne (par défaut)
const double _headerHeight = 56.0;    // hauteur de l’en-tête du tableau

/*────────── vue regroupée ─────────*/
class _GroupedAlimentsView extends StatelessWidget {
  const _GroupedAlimentsView({
    required this.aliments,
    required this.onValueChange,
    this.onDelete,
    this.onAdd,
  });

  final SplayTreeSet<Aliment> aliments;
  final Future<void> Function(Aliment, String, String) onValueChange;
  final Future<void> Function(Aliment)? onDelete;
  final Future<void> Function(String, String)? onAdd;

  /*──────────────── regroupe et trie ────────────────*/
  Map<String, List<Aliment>> _byGroup() {
    // 1. on place chaque aliment dans son groupe
    final grouped = <String, List<Aliment>>{};
    for (final a in aliments) {
      grouped.putIfAbsent(a.groupeAlimentaire ?? 'Divers', () => []).add(a);
    }

    // 2. on trie les aliments à l’intérieur de chaque liste
    for (final list in grouped.values) {
      list.sort();                 // ⇢ Aliment implémente Comparable<Aliment>
      // si ce n’est pas le cas :  list.sort((a,b) => a.libelle!.compareTo(b.libelle!));
    }

    // 3. on renvoie la map dont les clés sont elles-mêmes triées
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _byGroup();

    return ListView(
      padding: EdgeInsets.zero,
      primary: false,              // ⟵ ✔︎ on annonce qu’on est imbriqué
      shrinkWrap: true,            // ⟵ ✔︎ prend juste la hauteur nécessaire
      children: [
        for (final entry in groups.entries)
          ExpansionTile(
            title: Text(entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: _rowsPerPage * _rowHeight + _headerHeight,
                ),
                child: AlimentsGrid(
                  aliments: entry.value,
                  onValueChange: onValueChange,
                  onDelete: onDelete,
                  onAdd: onAdd,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/*────────── page principale ─────────*/
class MyAlimentsPage extends ConsumerWidget {
  const MyAlimentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAlimentsProvider);
    final notifier = ref.read(myAlimentsProvider.notifier);

    return Scaffold(
      key: navigatorKey,
      appBar: AppBar(
        title: const Text('Ma base de données'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: async.when(
        data: (alims) => _GroupedAlimentsView(
          aliments: alims,
          onValueChange: (aliment, field, value) => notifier.updateField(aliment.id!, field, value),
          onAdd: (libelle, groupe) => notifier.addAliment(libelle, groupe),
          onDelete: (aliment) async {
            // Afficher la boîte de dialogue de confirmation
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirmation de suppression'),
                  content: Text(
                    'Êtes-vous sûr de vouloir supprimer l\'aliment "${aliment.libelle}" de votre base de données ?'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Non'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Oui'),
                    ),
                  ],
                );
              },
            );

            // Si l'utilisateur confirme, procéder à la suppression
            if (confirmed == true) {
              final success = await notifier.deleteAliment(aliment);
              if (!success) {
                // Afficher un message d'erreur
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression de l\'aliment'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
        loading: ()        => const Center(child: CircularProgressIndicator()),
        error  : (e, st)   => null,
      ),
    );
  }
}

/*────────── navigatorKey global (pour les dialogs) ─────────*/
final navigatorKey = GlobalKey<NavigatorState>();
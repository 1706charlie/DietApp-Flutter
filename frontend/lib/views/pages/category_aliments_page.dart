// views/pages/category_aliments_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/aliments_by_group_provider.dart';
import '../../providers/my_aliments_provider.dart';
import '../widgets/data_error_widget.dart';

import '../widgets/aliments_grid.dart';

class CategoryAlimentsPage extends ConsumerWidget {
  const CategoryAlimentsPage({required this.groupName, super.key});
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(myAlimentsProvider);
    final alims = ref.watch(alimentsByGroupProvider(groupName));

    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: allAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, st) => DataErrorWidget(error: e, stackTrace: st),
        data: (_) => AlimentsGrid(
          aliments: alims.toList(),
          onValueChange: (a, f, v) =>
              ref.read(myAlimentsProvider.notifier).updateField(a.id!, f, v),
          onAdd: (libelle, groupe) => ref.read(myAlimentsProvider.notifier).addAliment(libelle, groupe),
          currentGroup: groupName, // Passer le groupe actuel
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
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Oui'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Non'),
                    ),
                  ],
                );
              },
            );

            // Si l'utilisateur confirme, procéder à la suppression
            if (confirmed == true) {
              final success = await ref.read(myAlimentsProvider.notifier).deleteAliment(aliment);
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
      ),
    );
  }
}
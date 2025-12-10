// views/pages/my_aliment_groups_page.dart
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/services.dart';

import '../../models/aliment.dart';
import '../../providers/my_aliments_provider.dart';
import '../widgets/data_error_widget.dart';
import '../widgets/aliment_columns.dart';
import '../widgets/aliments_grid.dart';
import 'category_aliments_page.dart';

class MyAlimentGroupsPage extends ConsumerStatefulWidget {
  const MyAlimentGroupsPage({super.key});

  @override
  ConsumerState<MyAlimentGroupsPage> createState() => _MyAlimentGroupsPageState();
}

class _MyAlimentGroupsPageState extends ConsumerState<MyAlimentGroupsPage> {
  final _searchController = TextEditingController();
  final _hCtrl = ScrollController();
  List<Aliment> _filteredAliments = [];
  List<Aliment> _allAliments = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAliments);
  }

  void _filterAliments() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredAliments = [];
      });
    } else {
      setState(() {
        _filteredAliments = _allAliments.where((aliment) {
          final libelle = aliment.libelle?.toLowerCase() ?? '';
          return libelle.contains(query);
        }).toList();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterAliments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myAlimentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ma base de données')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error  : (e, st) => DataErrorWidget(error: e, stackTrace: st),
        data   : (alims) {
          // Mettre à jour la liste complète des aliments
          _allAliments = alims.toList();
          
          // Filtrer les aliments si il y a une recherche
          if (_searchController.text.isNotEmpty) {
            _filterAliments();
          }

          return Column(
            children: [
              // Barre de recherche
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  children: [
                    SizedBox(
                      width: 400,
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un aliment...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              size: 18,
                            ),
                            onPressed: _clearSearch,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenu principal
              Expanded(
                child: _searchController.text.isEmpty 
                  ? _buildCategoriesList(alims)
                  : _buildAlimentsTable(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoriesList(SplayTreeSet<Aliment> alims) {
          // ▸ on extrait les groupes distincts et on les trie
          final groups = alims
              .map((a) => a.groupeAlimentaire ?? 'Divers')
              .toSet()
              .toList()
            ..sort();
    
          return ListView.separated(
            itemCount: groups.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final g = groups.elementAt(i);
              return ListTile(
                title: Text(g),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryAlimentsPage(groupName: g),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildAlimentsTable() {
    if (_filteredAliments.isEmpty) {
      return const Center(
        child: Text(
          'Aucun aliment trouvé',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Utiliser AlimentsGrid avec la colonne CATÉGORIE ALIMENTAIRE intégrée
    return AlimentsGridWithCategory(
      aliments: _filteredAliments,
      onValueChange: (a, f, v) => ref.read(myAlimentsProvider.notifier).updateField(a.id!, f, v),
      onAdd: (libelle, groupe) => ref.read(myAlimentsProvider.notifier).addAliment(libelle, groupe),
      ref: ref,
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
    );
  }
}

// Widget personnalisé qui étend AlimentsGrid pour inclure la colonne CATÉGORIE ALIMENTAIRE
class AlimentsGridWithCategory extends StatefulWidget {
  const AlimentsGridWithCategory({
    super.key,
    required this.aliments,
    required this.onValueChange,
    this.onDelete,
    this.onAdd,
    required this.ref,
  });

  final List<Aliment> aliments;
  final Future<void> Function(Aliment, String, String) onValueChange;
  final Future<void> Function(Aliment)? onDelete;
  final Future<void> Function(String, String)? onAdd;
  final WidgetRef ref;

  @override
  State<AlimentsGridWithCategory> createState() => _AlimentsGridWithCategoryState();
}

class _AlimentsGridWithCategoryState extends State<AlimentsGridWithCategory> {
  final _hCtrl = ScrollController();
  final _searchController = TextEditingController();
  List<Aliment> _filteredAliments = [];

  @override
  void initState() {
    super.initState();
    _filteredAliments = widget.aliments;
  }

  @override
  void didUpdateWidget(AlimentsGridWithCategory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aliments != widget.aliments) {
      _filterAliments(_searchController.text);
    }
  }

  void _filterAliments(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredAliments = widget.aliments;
      });
    } else {
      setState(() {
        _filteredAliments = widget.aliments.where((aliment) {
          final libelle = aliment.libelle?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return libelle.contains(searchQuery);
        }).toList();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterAliments('');
  }

  void _insertEmptyRow() {
    if (widget.aliments.any((a) => a.id == -1)) return; // déjà une ligne vide
    final fake = Aliment(id: -1, libelle: '', groupeAlimentaire: 'Divers');
    setState(() {
      widget.aliments.insert(0, fake);
      _filterAliments(_searchController.text);           // tient compte du filtre
    });
  }

  void removeFakeRow() {
    setState(() {
      widget.aliments.removeWhere((a) => a.id == -1);
      _filterAliments(_searchController.text);
    });
  }

  Future<void> _onValueChange(Aliment a, String field, String value) async {
    // ••• 1. S'il s'agit de la ligne fantôme et qu'on reçoit un libellé non vide
    if (a.id == -1 && field == 'libelle' && value.trim().isNotEmpty) {
      if (widget.onAdd != null) {
        // Capitaliser la première lettre si elle est en minuscule
        String capitalizedValue = value.trim();
        if (capitalizedValue.isNotEmpty && capitalizedValue[0] == capitalizedValue[0].toLowerCase()) {
          capitalizedValue = capitalizedValue[0].toUpperCase() + capitalizedValue.substring(1);
        }
        
        await widget.onAdd!(capitalizedValue, a.groupeAlimentaire ?? 'Divers');
        // Supprimer la ligne fantôme après l'ajout réussi
        setState(() {
          widget.aliments.removeWhere((x) => x.id == -1);
          _filterAliments(_searchController.text);
        });
      }
      return;
    }

    // ••• 2. S'il s'agit de la ligne fantôme et qu'on reçoit un libellé vide
    if (a.id == -1 && field == 'libelle' && value.trim().isEmpty) {
      // Supprimer la ligne fantôme si elle est vide
      setState(() {
        widget.aliments.removeWhere((x) => x.id == -1);
        _filterAliments(_searchController.text);
      });
      return;
    }

    // ••• 3. Capitalisation pour la colonne SOURCE
    if (field == 'source' && value.trim().isNotEmpty) {
      // Capitaliser la première lettre si elle est en minuscule
      String capitalizedValue = value.trim();
      if (capitalizedValue.isNotEmpty && capitalizedValue[0] == capitalizedValue[0].toLowerCase()) {
        capitalizedValue = capitalizedValue[0].toUpperCase() + capitalizedValue.substring(1);
        await widget.onValueChange(a, field, capitalizedValue);
        return;
      }
    }

    // ••• 4. Ligne normale → update classique
    await widget.onValueChange(a, field, value);
  }

  /*──────────────────── colonnes d'en-tête ────────────────────*/
  List<DataColumn2> _buildColumns() => [
    DataColumn2(
      label: Transform.translate(                      // ↖︎ décalé de –6 px
        offset: const Offset(0, -6),
        child: Container(
          width: 170,
          height: 100,
          padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20), // espace pour descendre le texte
              Text('ALIMENT'),
              SizedBox(height: 3), // espace entre le titre et le sous-titre
              Text(
                '(pour 100g)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      size: ColumnSize.L,
      fixedWidth: 170,
    ),
    // Colonne CATÉGORIE ALIMENTAIRE
    DataColumn2(
      label: Transform.translate(
        offset: const Offset(0, -6),
        child: Container(
          width: 200,
          height: 100,
          padding: const EdgeInsets.only(left: 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              Text('CATÉGORIE'),
              SizedBox(height: 3),
              Text(
                'alimentaire',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      size: ColumnSize.M,
      fixedWidth: 200,
    ),
    ...kAlimentColumns.map(
      (c) => DataColumn2(
        numeric: c.numeric,
        size: ColumnSize.S,
        label: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(                  // ↖︎ décalé de –6 px
            offset: const Offset(0, -35),
            child: Transform.rotate(
              angle: -74 * math.pi / 180,
              child: Text(
                c.label,
                style   : const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    ),
    // ───────────── colonne poubelle ─────────────
    DataColumn2(
      label: const SizedBox.shrink(), // Pas de label pour la colonne poubelle
      size: ColumnSize.S,
      fixedWidth: 50,
    ),
  ];

  /*───────────────────────── build ─────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final minWidth = 170.0 + 200.0 + 60.0 * kAlimentColumns.length + 50.0; // ALIMENT + CATÉGORIE + colonnes nutritionnelles + poubelle

    return Column(
      children: [
        // Tableau
        Expanded(
          child: _searchController.text.isNotEmpty && _filteredAliments.isEmpty
            ? const Center(
                child: Text(
                  'Aucun aliment trouvé',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(
                  physics: const ClampingScrollPhysics(),
                ),
                child: PaginatedDataTable2(
                  key: ValueKey('aliments_grid_with_category_${_filteredAliments.length}'), // Force reconstruction
                  headingRowHeight : 100,
                  dataRowHeight    : 44,
                  columnSpacing    : 0,
                  horizontalMargin : 0,
                  horizontalScrollController: _hCtrl,
                  hidePaginator    : true,
                  rowsPerPage      : _filteredAliments.length > 0 ? _filteredAliments.length : 1,
                  availableRowsPerPage: const <int>[],
                  fixedLeftColumns : 1, // Seulement ALIMENT fixe
                  minWidth         : minWidth,
                  columns          : _buildColumns(),
                  source           : _AlimentsWithCategoryDS(_filteredAliments, _onValueChange, widget.onDelete, widget.ref),
                  border          : TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
              ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// DataSource avec colonne CATÉGORIE ALIMENTAIRE
class _AlimentsWithCategoryDS extends DataTableSource {
  _AlimentsWithCategoryDS(this.aliments, this.onValueChange, this.onDelete, this.ref);

  final List<Aliment> aliments;
  final Future<void> Function(Aliment, String, String) onValueChange;
  final Future<void> Function(Aliment)? onDelete;
  final WidgetRef ref;

  // Obtenir la liste des catégories disponibles (toutes les catégories de la base de données)
  List<String> get _availableCategories {
    // Récupérer toutes les catégories de la base de données, pas seulement celles des aliments affichés
    final allAliments = (ref.read(myAlimentsProvider).value ?? <Aliment>[]) as Iterable<Aliment>;
    final categories = allAliments
        .map((a) => a.groupeAlimentaire ?? 'Divers')
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  Widget _withOptionalTooltip({
    required bool show,
    required String message,
    required Widget child,
  }) =>
      show
          ? Tooltip(
              message: message,
              waitDuration: const Duration(milliseconds: 500),
              child: child,
            )
          : child;

  bool _isOverflowing({
    required String text,
    required double maxWidth,
    required int maxLines,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14),
      ),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width > maxWidth;
  }

  @override
  DataRow? getRow(int i) {
    if (i >= aliments.length) return null;
    final a = aliments[i];
    final lib = a.libelle ?? '';

    // --- test débordement pour la première colonne ---
    final needsTooltip = _isOverflowing(
      text     : lib,
      maxWidth : 155,            // 170 – padding L/R
      maxLines : 2,
    );

    // --- test débordement pour la colonne SOURCE ---
    final sourceValue = a.source ?? '';
    final needsSourceTooltip = _isOverflowing(
      text     : sourceValue,
      maxWidth : 45,             // 55 – padding L/R (même largeur que les colonnes numériques)
      maxLines : 2,
    );

    final bool isGhost = a.id == -1;

    return DataRow.byIndex(
      index: i,
      cells: [
        // ───────────── première colonne : ALIMENT ─────────────
        DataCell(
          _withOptionalTooltip(
            show    : needsTooltip,
            message : lib,
            child   : AlimentNameCell(
              libelle: lib,
              aliment: a,
              onValueChange: onValueChange,
              onDelete: onDelete,
              autoEdit: isGhost,          // ← on active l'auto-édition pour la ligne fantôme
            ),
          ),
        ),

        // ───────────── colonne CATÉGORIE ALIMENTAIRE ─────────────
        DataCell(
          CategoryEditableCell(
            initialValue: a.groupeAlimentaire ?? 'Divers',
            availableCategories: _availableCategories,
            onSave: (newValue) => onValueChange(a, 'groupe_alimentaire', newValue),
            aliment: a,
            onDelete: onDelete,
          ),
        ),

        // ───────────── autres cellules ─────────────
        ...List.generate(kAlimentColumns.length, (j) {
          final column = kAlimentColumns[j];
          final isSourceColumn = column.field == 'source';
          
          return DataCell(
            isSourceColumn
              ? _withOptionalTooltip(
                  show    : needsSourceTooltip,
                  message : sourceValue,
                  child   : EditableCell(
                    initialValue: column.get(a) ?? '-',
                    isNumeric: column.numeric,
                    onSave: (newValue) => onValueChange(a, column.field, newValue),
                    textAlign: TextAlign.center,
                    aliment: a,
                    onDelete: onDelete,
                  ),
                )
              : EditableCell(
                  initialValue: column.get(a) ?? '-',
                  isNumeric: column.numeric,
                  onSave: (newValue) => onValueChange(a, column.field, newValue),
                  textAlign: TextAlign.center,
                  aliment: a,
                  onDelete: onDelete,
                ),
          );
        }),

        // ───────────── colonne poubelle ─────────────
        DataCell(
          SizedBox(
        width: double.infinity,
        child: Center(
              child: IconButton(
                icon: const Icon(Icons.delete, size: 20,),
                onPressed: onDelete != null ? () => onDelete!(a) : null,
                tooltip: 'Supprimer',
            ),
          ),
        ),
      ),
      ],
    );
  }

  @override bool get isRowCountApproximate => false;
  @override int  get rowCount             => aliments.length;
  @override int  get selectedRowCount     => 0;
}

// Widget cellule nom d'aliment (copié exactement de aliments_grid.dart)
class AlimentNameCell extends StatefulWidget {
  const AlimentNameCell({
    super.key,
    required this.libelle,
    required this.aliment,
    required this.onValueChange,
    this.onDelete,
    this.autoEdit = false,
  });

  final String libelle;
  final Aliment aliment;
  final Future<void> Function(Aliment, String, String) onValueChange;
  final Future<void> Function(Aliment)? onDelete;
  final bool autoEdit;

  @override
  State<AlimentNameCell> createState() => _AlimentNameCellState();
}

class _AlimentNameCellState extends State<AlimentNameCell> {
  void _showContextMenu(Offset globalPosition) {
    if (widget.onDelete == null) return;
    
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final RelativeRect menuPosition = RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      overlay.size.width - globalPosition.dx,
      overlay.size.height - globalPosition.dy,
    );

    showMenu<String>(
      context: context,
      position: menuPosition,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          height: 24,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, size: 16),
                SizedBox(width: 6),
                Text(
                  'Supprimer aliment',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        _showDeleteConfirmation();
      }
    });
  }

  void _showDeleteConfirmation() async {
    if (widget.onDelete == null) return;
    
    try {
      await widget.onDelete!(widget.aliment);
    } catch (e) {
      // L'erreur sera gérée par les pages qui ont leur propre gestion d'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: widget.onDelete != null ? (details) => _showContextMenu(details.globalPosition) : null,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 10.0),
          child: EditableCell(
            initialValue: widget.libelle,
            onSave: (newValue) => widget.onValueChange(widget.aliment, 'libelle', newValue),
            isNumeric: false,
            textAlign: TextAlign.start,
            aliment: widget.aliment,
            onDelete: widget.onDelete,
            autoEdit: widget.autoEdit,
          ),
        ),
      ),
    );
  }
}

// Widget cellule catégorie éditable avec fonctionnalités complètes
class CategoryEditableCell extends StatefulWidget {
  const CategoryEditableCell({
    super.key,
    required this.initialValue,
    required this.availableCategories,
    required this.onSave,
    this.aliment,
    this.onDelete,
  });

  final String initialValue;
  final List<String> availableCategories;
  final Future<void> Function(String) onSave;
  final Aliment? aliment;
  final Future<void> Function(Aliment)? onDelete;

  @override
  State<CategoryEditableCell> createState() => _CategoryEditableCellState();
}

class _CategoryEditableCellState extends State<CategoryEditableCell> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(CategoryEditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _currentValue = widget.initialValue;
    }
  }

  void _showCategoryMenu(Offset globalPosition) {
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final RelativeRect menuPosition = RelativeRect.fromLTRB(
      globalPosition.dx,
      globalPosition.dy,
      overlay.size.width - globalPosition.dx,
      overlay.size.height - globalPosition.dy,
    );

    showMenu<String>(
      context: context,
      position: menuPosition,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        // Options de catégories (sans titre ni séparateurs)
        ...widget.availableCategories.map((category) {
          return PopupMenuItem<String>(
            value: category,
            height: 24,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (category == widget.initialValue)
                    Icon(Icons.check, size: 16),
                  if (category == widget.initialValue)
                    SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: category == widget.initialValue ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    ).then((value) {
      if (value != null) {
        if (value != 'title' && value != 'separator' && value != 'separator2') {
          // C'est une catégorie sélectionnée
          _saveChanges(value);
        }
      }
    });
  }

  void _saveChanges(String newCategory) async {
    if (newCategory != widget.initialValue) {
      try {
        await widget.onSave(newCategory);
        setState(() {
          _currentValue = newCategory;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() async {
    if (widget.aliment == null || widget.onDelete == null) return;
    
    try {
      await widget.onDelete!(widget.aliment!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        _showCategoryMenu(position + Offset(0, renderBox.size.height));
      },
      onSecondaryTapDown: (details) => _showCategoryMenu(details.globalPosition),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: widget.initialValue.isEmpty 
              ? Border.all(color: Colors.grey.shade200, width: 0.5)
              : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _currentValue,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
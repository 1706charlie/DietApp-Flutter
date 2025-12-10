import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../widgets/aliment_columns.dart';
import '../../models/aliment.dart';
import '../../models/diet_line.dart';
import '../../providers/my_aliments_provider.dart';
import '../../providers/diet_lines_provider.dart';

class AddDietPage extends ConsumerStatefulWidget {
  const AddDietPage({super.key});

  @override
  ConsumerState<AddDietPage> createState() => _AddDietPageState();
}

class _AddDietPageState extends ConsumerState<AddDietPage> {
  final _hCtrl = ScrollController();
  final _searchController = TextEditingController();
  TextEditingController? _currentAutocompleteController;
  bool _isCiqualSelected = true; // Par défaut, Ciqual est sélectionné
  bool _isPersoSelected = false;

  void _showContextMenu(Offset globalPosition, DietLine dietLine) {
    // Utiliser la position exacte du clic droit
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    // Calculer la position relative pour le menu (commence exactement à la position du clic)
    final RelativeRect menuPosition = RelativeRect.fromLTRB(
      globalPosition.dx, // left (position exacte du clic)
      globalPosition.dy, // top (position exacte du clic)
      overlay.size.width - globalPosition.dx, // right
      overlay.size.height - globalPosition.dy, // bottom
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
                  'Supprimer ligne de régime',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        _removeAliment(dietLine);
      }
    });
  }
  List<Map<String, dynamic>> _emptyRows = [];
  List<Aliment> _allAliments = [];
  List<Aliment> _filteredAliments = [];

    @override
  void initState() {
    super.initState();
    // Tableau complètement vide sans aucune ligne
    _emptyRows = [];
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

  @override
  void dispose() {
    _hCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _filterAliments();
  }

  Future<void> _removeAliment(DietLine dietLine) async {
    final success = await ref.read(dietLinesProvider.notifier).deleteDietLine(dietLine);
    if (success == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateDietLineField(DietLine dietLine, String field, String value) async {
    final success = await ref.read(dietLinesProvider.notifier).updateDietLineField(dietLine, field, value);
    if (success == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /*──────────────────── colonnes d'en-tête ────────────────────*/
  List<DataColumn2> _buildColumns() => [
    DataColumn2(
      label: Transform.translate(
        offset: const Offset(0, -6),
        child: Container(
          width: 170,
          height: 100,
          padding: const EdgeInsets.only(left: 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              Text('ALIMENT'),
            ],
          ),
        ),
      ),
      size: ColumnSize.L,
      fixedWidth: 170,
    ),
    // ───────────── colonne QUANTITÉ ─────────────
    DataColumn2(
      numeric: true,
      size: ColumnSize.S,
      label: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: const Offset(0, -35),
          child: Transform.rotate(
            angle: -74 * math.pi / 180,
            child: const Text(
              'QUANTITÉ',
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ),
    // ───────────── colonne UNITÉ ─────────────
    DataColumn2(
      numeric: true,
      size: ColumnSize.S,
      label: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: const Offset(0, -35),
          child: Transform.rotate(
            angle: -74 * math.pi / 180,
            child: const Text(
              'UNITÉ',
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ),
    // ───────────── colonne FRÉQUENCE ─────────────
    DataColumn2(
      numeric: true,
      size: ColumnSize.S,
      label: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: const Offset(0, -35),
          child: Transform.rotate(
            angle: -74 * math.pi / 180,
            child: const Text(
              'FRÉQUENCE',
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ),
      ),
    ),
    ...kAlimentColumns.map(
      (c) => DataColumn2(
        numeric: c.numeric,
        size: ColumnSize.S,
        label: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: const Offset(0, -35),
            child: Transform.rotate(
              angle: -74 * math.pi / 180,
              child: Text(
                c.label,
                style: const TextStyle(fontSize: 11),
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
      label: const SizedBox.shrink(),
      size: ColumnSize.S,
      fixedWidth: 50,
    ),
  ];

  /*───────────────────────── build ─────────────────────────*/
  @override
  Widget build(BuildContext context) {
    final minWidth = 170.0 + 60.0 * 3 + 60.0 * kAlimentColumns.length + 50.0;
    final async = ref.watch(myAlimentsProvider);
    final dietLinesAsync = ref.watch(dietLinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un régime'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
        data: (alims) {
          // Mettre à jour la liste complète des aliments
          _allAliments = alims.toList();
          
          // Filtrer les aliments si il y a une recherche
          if (_searchController.text.isNotEmpty) {
            _filterAliments();
          }

          return Column(
            children: [
              // Barre de recherche avec autocomplétion
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  children: [
                    SizedBox(
                      width: 400,
                      child: Autocomplete<Aliment>(
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          // Garder une référence au contrôleur pour pouvoir le vider plus tard
                          _currentAutocompleteController = textEditingController;
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            autofocus: true,
                            onEditingComplete: onFieldSubmitted,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un aliment à ajouter...',
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
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Aliment>.empty();
                          }
                          return _allAliments.where((aliment) {
                            final libelle = aliment.libelle?.toLowerCase() ?? '';
                            return libelle.contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        displayStringForOption: (Aliment option) => option.libelle ?? '',
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option        = options.elementAt(index);
                                    final highlighted   = AutocompleteHighlightedOption.of(context) == index;

                                    return InkWell(
                                      onTap: () => onSelected(option),      // clic → sélection
                                      child: Container(
                                        color: highlighted                  // ↑/↓ déplacent la surbrillance
                                            ? Theme.of(context).highlightColor.withOpacity(0.2)
                                            : null,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(option.libelle ?? ''),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (Aliment selection) async {
                          // Ajouter l'aliment sélectionné au régime via le provider
                          final newDietLine = await ref.read(dietLinesProvider.notifier).addDietLine(
                            alimentId: selection.id ?? 0,
                            unity: 'g',
                            frequency: 1,
                          );
                          
                          if (newDietLine != null) {
                            // Vider la barre de recherche après l'ajout
                            _currentAutocompleteController?.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erreur lors de l\'ajout au régime'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bouton Ciqual
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isCiqualSelected = true;
                          _isPersoSelected = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCiqualSelected 
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300]),
                        foregroundColor: _isCiqualSelected 
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isCiqualSelected) 
                            Icon(
                              Icons.check,
                              size: 16,
                              color: _isCiqualSelected 
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                                  : null,
                            ),
                          if (_isCiqualSelected) const SizedBox(width: 4),
                          const Text('Ciqual'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bouton Perso
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isCiqualSelected = false;
                          _isPersoSelected = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPersoSelected 
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300]),
                        foregroundColor: _isPersoSelected 
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isPersoSelected) 
                            Icon(
                              Icons.check,
                              size: 16,
                              color: _isPersoSelected 
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                                  : null,
                            ),
                          if (_isPersoSelected) const SizedBox(width: 4),
                          const Text('Perso'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          // Tableau vide
          Expanded(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const ClampingScrollPhysics(),
              ),
              child: PaginatedDataTable2(
                key: ValueKey('diet_lines_grid_${dietLinesAsync.when(
                  loading: () => 0,
                  error: (e, st) => 0,
                  data: (dietLines) => dietLines.length,
                )}'),
                headingRowHeight: 100,
                dataRowHeight: 44,
                columnSpacing: 0,
                horizontalMargin: 0,
                horizontalScrollController: _hCtrl,
                hidePaginator: true,
                rowsPerPage: 10,
                availableRowsPerPage: const <int>[10, 25, 50],
                fixedLeftColumns: 4,
                minWidth: minWidth,
                columns: _buildColumns(),
                source: dietLinesAsync.when(
                  loading: () => _SelectedAlimentsDS([], _removeAliment, _showContextMenu, _updateDietLineField),
                  error: (e, st) => _SelectedAlimentsDS([], _removeAliment, _showContextMenu, _updateDietLineField),
                  data: (dietLines) => _SelectedAlimentsDS(dietLines.toList(), _removeAliment, _showContextMenu, _updateDietLineField),
                ),
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
            ),
          ),
        ],
      );
        },
      ),
    );
  }
}

/*────────────────────────── widget cellule éditable pour DietLine ──────────────────────────*/
class EditableDietCell extends StatefulWidget {
  const EditableDietCell({
    super.key,
    required this.initialValue,
    required this.onSave,
    required this.isNumeric,
    this.textAlign = TextAlign.center,
    this.dietLine,
    this.onShowContextMenu,
  });

  final String initialValue;
  final Future<void> Function(String) onSave;
  final bool isNumeric;
  final TextAlign textAlign;
  final DietLine? dietLine;
  final Function(Offset, DietLine)? onShowContextMenu;

  @override
  State<EditableDietCell> createState() => _EditableDietCellState();
}

class _EditableDietCellState extends State<EditableDietCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue == '-' || widget.initialValue.isEmpty ? '' : widget.initialValue;
    _controller = TextEditingController(text: initialText);
    _focusNode = FocusNode();
    _originalValue = widget.initialValue == '-' || widget.initialValue.isEmpty ? '' : widget.initialValue;
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
    });
  }

  @override
  void didUpdateWidget(EditableDietCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mettre à jour le contrôleur si la valeur initiale a changé et qu'on n'est pas en train d'éditer
    if (oldWidget.initialValue != widget.initialValue && !_isEditing) {
      final newText = widget.initialValue == '-' || widget.initialValue.isEmpty ? '' : widget.initialValue;
      _controller.text = newText;
      _originalValue = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    _focusNode.requestFocus();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void _saveChanges() async {
    if (!_isEditing) return;
    
    setState(() {
      _isEditing = false;
    });

    final newValue = _controller.text.trim();
    
    if (newValue == _originalValue) return;

    // Validation pour les champs numériques
    if (widget.isNumeric && newValue.isNotEmpty) {
      final double? parsedValue = double.tryParse(newValue);
      if (parsedValue == null) {
        _controller.text = _originalValue;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Valeur numérique invalide'),
          ),
        );
        return;
      }
    }

    final valueToSave = newValue.isEmpty ? '' : newValue;

    try {
      await widget.onSave(valueToSave);
      _originalValue = newValue;
    } catch (e) {
      _controller.text = _originalValue;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: widget.textAlign == TextAlign.start
            ? Alignment.centerLeft
            : Alignment.center,
        padding: widget.textAlign == TextAlign.start
            ? const EdgeInsets.only(left: 5.0)
            : EdgeInsets.zero,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textAlign: widget.textAlign,
          style: const TextStyle(fontSize: 13.5),
          cursorColor: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
          cursorWidth: 1.0,
          cursorHeight: 16.0,
          keyboardType: widget.isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: widget.isNumeric ? [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ] : null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onSubmitted: (_) => _saveChanges(),
          onEditingComplete: _saveChanges,
        ),
      );
    }

    final displayValue = widget.initialValue.isEmpty ? '' : widget.initialValue;

    return GestureDetector(
      onTap: _startEditing,
      onSecondaryTapDown: widget.dietLine != null && widget.onShowContextMenu != null 
          ? (details) => widget.onShowContextMenu!(details.globalPosition, widget.dietLine!)
          : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: displayValue.isEmpty 
              ? Border.all(color: Colors.grey.shade200, width: 0.5)
              : null,
        ),
        child: widget.textAlign == TextAlign.start 
          ? LayoutBuilder(
              builder: (context, constraints) {
                final tp = TextPainter(
                  text: TextSpan(text: displayValue, style: const TextStyle(fontSize: 14)),
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth - 10);
                final needsTooltip = tp.didExceedMaxLines;
                final textWidget = Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      displayValue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: widget.textAlign,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
                return needsTooltip
                  ? Tooltip(
                      message: displayValue,
                      waitDuration: const Duration(milliseconds: 500),
                      child: textWidget,
                    )
                  : textWidget;
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final tp = TextPainter(
                  text: TextSpan(text: displayValue, style: const TextStyle(fontSize: 14)),
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth - 10);
                final needsTooltip = tp.didExceedMaxLines;
                final textWidget = Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      displayValue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: widget.textAlign,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
                return needsTooltip
                  ? Tooltip(
                      message: displayValue,
                      waitDuration: const Duration(milliseconds: 500),
                      child: textWidget,
                    )
                  : textWidget;
              },
            ),
      ),
    );
  }
}

// DataSource pour les lignes de régime
class _SelectedAlimentsDS extends DataTableSource {
  _SelectedAlimentsDS(this.dietLines, this.onRemoveAliment, this.onShowContextMenu, this.onUpdateField);

  final List<DietLine> dietLines;
  final Future<void> Function(DietLine) onRemoveAliment;
  final Function(Offset, DietLine) onShowContextMenu;
  final Future<void> Function(DietLine, String, String) onUpdateField;

  String? _getNutritionalValue(DietLine dietLine, AlimentColumn column) {
    // Si la quantité est 0, afficher des valeurs vides pour les nutriments (sauf source)
    final quantity = dietLine.quantity ?? 0;
    final frequency = dietLine.frequency ?? 1;
    if (quantity == 0 && column.field != 'source') {
      return null;
    }
    
    // Calculer la valeur proportionnelle à la quantité et à la fréquence
    double? calculateProportionalValue(double? valueFor100g) {
      if (valueFor100g == null || dietLine.quantity == null || dietLine.quantity == 0) {
        return null;
      }
      final frequency = dietLine.frequency ?? 1;
      return (valueFor100g * dietLine.quantity! * frequency) / 100.0;
    }
    
    switch (column.field) {
      case 'energie_kcal':
        return calculateProportionalValue(dietLine.energieKcal)?.toStringAsFixed(1);
      case 'energie_kj':
        return calculateProportionalValue(dietLine.energieKj)?.toStringAsFixed(1);
      case 'proteines':
        return calculateProportionalValue(dietLine.proteines)?.toStringAsFixed(1);
      case 'lipides':
        return calculateProportionalValue(dietLine.lipides)?.toStringAsFixed(1);
      case 'acides_gras_satures':
        return calculateProportionalValue(dietLine.acidesGrasSatures)?.toStringAsFixed(1);
      case 'acides_gras_mono':
        return calculateProportionalValue(dietLine.acidesGrasMono)?.toStringAsFixed(1);
      case 'acides_gras_poly':
        return calculateProportionalValue(dietLine.acidesGrasPoly)?.toStringAsFixed(1);
      case 'acides_gras_omega_3':
        return calculateProportionalValue(dietLine.acidesGrasOmega3)?.toStringAsFixed(1);
      case 'acides_gras_omega_6':
        return calculateProportionalValue(dietLine.acidesGrasOmega6)?.toStringAsFixed(1);
      case 'acides_lino':
        return calculateProportionalValue(dietLine.acidesLino)?.toStringAsFixed(1);
      case 'acides_gras_trans':
        return calculateProportionalValue(dietLine.acidesGrasTrans)?.toStringAsFixed(1);
      case 'cholesterol':
        return calculateProportionalValue(dietLine.cholesterol)?.toStringAsFixed(1);
      case 'glucides_digestibles':
        return calculateProportionalValue(dietLine.glucidesDigestibles)?.toStringAsFixed(1);
      case 'sucres':
        return calculateProportionalValue(dietLine.sucres)?.toStringAsFixed(1);
      case 'amidon':
        return calculateProportionalValue(dietLine.amidon)?.toStringAsFixed(1);
      case 'fibres':
        return calculateProportionalValue(dietLine.fibres)?.toStringAsFixed(1);
      case 'eau':
        return calculateProportionalValue(dietLine.eau)?.toStringAsFixed(1);
      case 'sodium':
        return calculateProportionalValue(dietLine.sodium)?.toStringAsFixed(1);
      case 'potassium':
        return calculateProportionalValue(dietLine.potassium)?.toStringAsFixed(1);
      case 'calcium':
        return calculateProportionalValue(dietLine.calcium)?.toStringAsFixed(1);
      case 'phosphore':
        return calculateProportionalValue(dietLine.phosphore)?.toStringAsFixed(1);
      case 'magnesium':
        return calculateProportionalValue(dietLine.magnesium)?.toStringAsFixed(1);
      case 'fer':
        return calculateProportionalValue(dietLine.fer)?.toStringAsFixed(1);
      case 'cuivre':
        return calculateProportionalValue(dietLine.cuivre)?.toStringAsFixed(1);
      case 'zinc':
        return calculateProportionalValue(dietLine.zinc)?.toStringAsFixed(1);
      case 'selenium':
        return calculateProportionalValue(dietLine.selenium)?.toStringAsFixed(1);
      case 'vit_a_eq':
        return calculateProportionalValue(dietLine.vitAeq)?.toStringAsFixed(1);
      case 'vit_b1':
        return calculateProportionalValue(dietLine.vitB1)?.toStringAsFixed(1);
      case 'vit_b2':
        return calculateProportionalValue(dietLine.vitB2)?.toStringAsFixed(1);
      case 'vit_b12':
        return calculateProportionalValue(dietLine.vitB12)?.toStringAsFixed(1);
      case 'vit_c':
        return calculateProportionalValue(dietLine.vitC)?.toStringAsFixed(1);
      case 'vit_d':
        return calculateProportionalValue(dietLine.vitD)?.toStringAsFixed(1);
      case 'source':
        return dietLine.source;
      default:
        return null;
    }
  }

  // Méthode pour calculer les totaux des valeurs nutritionnelles
  Map<String, double> _calculateTotals() {
    final totals = <String, double>{};
    
    for (final column in kAlimentColumns) {
      if (column.field == 'source') continue; // Ignorer la colonne source
      
      double total = 0.0;
      for (final dietLine in dietLines) {
        final quantity = dietLine.quantity ?? 0;
        final frequency = dietLine.frequency ?? 1;
        
        if (quantity > 0) {
          double? valueFor100g;
          switch (column.field) {
            case 'energie_kcal':
              valueFor100g = dietLine.energieKcal;
              break;
            case 'energie_kj':
              valueFor100g = dietLine.energieKj;
              break;
            case 'proteines':
              valueFor100g = dietLine.proteines;
              break;
            case 'lipides':
              valueFor100g = dietLine.lipides;
              break;
            case 'acides_gras_satures':
              valueFor100g = dietLine.acidesGrasSatures;
              break;
            case 'acides_gras_mono':
              valueFor100g = dietLine.acidesGrasMono;
              break;
            case 'acides_gras_poly':
              valueFor100g = dietLine.acidesGrasPoly;
              break;
            case 'acides_gras_omega_3':
              valueFor100g = dietLine.acidesGrasOmega3;
              break;
            case 'acides_gras_omega_6':
              valueFor100g = dietLine.acidesGrasOmega6;
              break;
            case 'acides_lino':
              valueFor100g = dietLine.acidesLino;
              break;
            case 'acides_gras_trans':
              valueFor100g = dietLine.acidesGrasTrans;
              break;
            case 'cholesterol':
              valueFor100g = dietLine.cholesterol;
              break;
            case 'glucides_digestibles':
              valueFor100g = dietLine.glucidesDigestibles;
              break;
            case 'sucres':
              valueFor100g = dietLine.sucres;
              break;
            case 'amidon':
              valueFor100g = dietLine.amidon;
              break;
            case 'fibres':
              valueFor100g = dietLine.fibres;
              break;
            case 'eau':
              valueFor100g = dietLine.eau;
              break;
            case 'sodium':
              valueFor100g = dietLine.sodium;
              break;
            case 'potassium':
              valueFor100g = dietLine.potassium;
              break;
            case 'calcium':
              valueFor100g = dietLine.calcium;
              break;
            case 'phosphore':
              valueFor100g = dietLine.phosphore;
              break;
            case 'magnesium':
              valueFor100g = dietLine.magnesium;
              break;
            case 'fer':
              valueFor100g = dietLine.fer;
              break;
            case 'cuivre':
              valueFor100g = dietLine.cuivre;
              break;
            case 'zinc':
              valueFor100g = dietLine.zinc;
              break;
            case 'selenium':
              valueFor100g = dietLine.selenium;
              break;
            case 'vit_a_eq':
              valueFor100g = dietLine.vitAeq;
              break;
            case 'vit_b1':
              valueFor100g = dietLine.vitB1;
              break;
            case 'vit_b2':
              valueFor100g = dietLine.vitB2;
              break;
            case 'vit_b12':
              valueFor100g = dietLine.vitB12;
              break;
            case 'vit_c':
              valueFor100g = dietLine.vitC;
              break;
            case 'vit_d':
              valueFor100g = dietLine.vitD;
              break;
          }
          
          if (valueFor100g != null) {
            total += (valueFor100g * quantity * frequency) / 100.0;
          }
        }
      }
      totals[column.field] = total;
    }
    
    return totals;
  }

  @override
  DataRow? getRow(int i) {
    // Ligne de totaux en première position (i==0)
    if (i == 0) {
      final totals = _calculateTotals();
      return DataRow.byIndex(
        index: i,
        cells: [
          DataCell(
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'TOTAUX',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          DataCell(Container(width: double.infinity, height: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200, width: 0.5))),),
          DataCell(Container(width: double.infinity, height: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200, width: 0.5))),),
          DataCell(Container(width: double.infinity, height: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200, width: 0.5))),),
          ...List.generate(kAlimentColumns.length, (j) {
            final column = kAlimentColumns[j];
            String displayValue = '';
            if (column.field != 'source') {
              final total = totals[column.field];
              displayValue = (total != null && total > 0) ? total.toStringAsFixed(1) : '0.0';
            }
            return DataCell(
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }),
          DataCell(Container(width: double.infinity, height: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200, width: 0.5))),),
        ],
      );
    }
    // Lignes de données normales
    int dataIndex = i - 1;
    if (dataIndex < 0 || dataIndex >= dietLines.length) return null;
    final dietLine = dietLines[dataIndex];
    return DataRow.byIndex(
      index: i,
      cells: [
        // ───────────── première colonne : ALIMENT ─────────────
        DataCell(
          GestureDetector(
            onSecondaryTapDown: (details) => onShowContextMenu(details.globalPosition, dietLine),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    dietLine.libelle ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ───────────── colonne QUANTITÉ ─────────────
        DataCell(
          EditableDietCell(
            initialValue: dietLine.quantity == 0 ? '' : dietLine.quantity.toString(),
            onSave: (newValue) => onUpdateField(dietLine, 'quantity', newValue),
            isNumeric: true,
            textAlign: TextAlign.center,
            dietLine: dietLine,
            onShowContextMenu: onShowContextMenu,
          ),
        ),

        // ───────────── colonne UNITÉ ─────────────
        DataCell(
          GestureDetector(
            onSecondaryTapDown: (details) => onShowContextMenu(details.globalPosition, dietLine),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                    dietLine.unity ?? 'g',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),

        // ───────────── colonne FRÉQUENCE ─────────────
        DataCell(
          EditableDietCell(
            initialValue: dietLine.frequency?.toString() ?? '1',
            onSave: (newValue) => onUpdateField(dietLine, 'frequency', newValue),
            isNumeric: true,
            textAlign: TextAlign.center,
            dietLine: dietLine,
            onShowContextMenu: onShowContextMenu,
          ),
        ),

        // ───────────── autres cellules ─────────────
        ...List.generate(kAlimentColumns.length, (j) {
          final column = kAlimentColumns[j];
          return DataCell(
            GestureDetector(
              onSecondaryTapDown: (details) => onShowContextMenu(details.globalPosition, dietLine),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 0.5),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(
                    _getNutritionalValue(dietLine, column) ?? '',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  ),
                ),
              ),
            ),
          );
        }),

        // ───────────── colonne poubelle ─────────────
        DataCell(
          SizedBox(
            width: double.infinity,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => onRemoveAliment(dietLine),
                tooltip: 'Supprimer',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => dietLines.length + 1; // +1 pour la ligne de totaux
  @override
  int get selectedRowCount => 0;
}

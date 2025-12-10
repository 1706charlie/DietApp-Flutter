import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/aliment.dart';
import 'aliment_columns.dart';

/*────────────────────────── widget cellule éditable ──────────────────────────*/
class EditableCell extends StatefulWidget {
  const EditableCell({
    super.key,
    required this.initialValue,
    required this.onSave,
    required this.isNumeric,
    this.textAlign = TextAlign.center,
    this.aliment,
    this.onDelete,
    this.autoEdit = false,          // ← NOUVEAU
  });

  final String initialValue;
  final Future<void> Function(String) onSave;
  final bool isNumeric;
  final TextAlign textAlign;
  final Aliment? aliment; // L'aliment associé à cette cellule
  final Future<void> Function(Aliment)? onDelete; // Callback pour supprimer l'aliment
  final bool autoEdit;              // ← NOUVEAU

  @override
  State<EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<EditableCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    // Initialiser avec une chaîne vide pour permettre l'édition des cellules vides
    final initialText = widget.initialValue == '-' || widget.initialValue.isEmpty ? '' : widget.initialValue;
    _controller = TextEditingController(text: initialText);
    _focusNode = FocusNode();
    // Normaliser la valeur originale pour la comparaison
    _originalValue = widget.initialValue == '-' || widget.initialValue.isEmpty ? '' : widget.initialValue;
    
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveChanges();
      }
      _onFocusChange();
    });

    if (widget.autoEdit) {
      _isEditing = true;                           // montre directement le TextField
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();                 // place le curseur
        // Positionner le curseur à la fin du texte
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }
  }

  @override
  void didUpdateWidget(EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mettre à jour le contrôleur si la valeur initiale a changé et qu'on n'est pas en train d'éditer
    if (oldWidget.initialValue != widget.initialValue && !_isEditing) {
      final newText = widget.initialValue == '-' || widget.initialValue.isEmpty ? '' : widget.initialValue;
      _controller.text = newText;
      _originalValue = newText;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.aliment?.id == -1) {
      final empty = _controller.text.trim().isEmpty;
      if (empty) {
        // Supprimer la ligne fantôme si elle est vide
        // Cette logique sera gérée par le parent via onSave
      }
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
    
    // Positionner le curseur à la fin du texte
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
    
    // Pour les lignes fantômes, toujours appeler onSave même si la valeur n'a pas changé
    // car onSave gère la suppression de la ligne vide
    final isGhostRow = widget.aliment?.id == -1;
    
    // Si la valeur n'a pas changé et que ce n'est pas une ligne fantôme, ne rien faire
    if (newValue == _originalValue && !isGhostRow) return;

    // Validation pour les champs numériques
    if (widget.isNumeric && newValue.isNotEmpty) {
      final double? parsedValue = double.tryParse(newValue);
      if (parsedValue == null) {
        // Restaurer la valeur originale si invalide
        _controller.text = _originalValue;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Valeur numérique invalide'),
          ),
        );
        return;
      }
    }

    // Si la valeur est vide, la traiter comme une suppression (null)
    final valueToSave = newValue.isEmpty ? '' : newValue;

    try {
      await widget.onSave(valueToSave);
      _originalValue = newValue;
    } catch (e) {
      // En cas d'erreur, restaurer la valeur originale
      _controller.text = _originalValue;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
        ),
      );
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _controller.text = _originalValue;
    _focusNode.unfocus();
  }

  void _showContextMenu(Offset globalPosition) {
    if (widget.aliment == null || widget.onDelete == null) return;
    
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
    if (widget.aliment == null || widget.onDelete == null) return;
    
    // Appeler directement onDelete sans boîte de dialogue supplémentaire
    // Les pages gèrent déjà leur propre boîte de dialogue de confirmation
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
    if (_isEditing) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        // Utiliser le même alignement que la vue lecture pour éviter le décalage
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
            contentPadding: EdgeInsets.zero, // Pas de padding interne pour éviter le double padding
          ),
          onSubmitted: (_) => _saveChanges(),
          onEditingComplete: _saveChanges,
        ),
      );
    }

    // Afficher la valeur ou "-" si null/vide
    final displayValue = widget.initialValue.isEmpty ? '-' : widget.initialValue;

    return GestureDetector(
      onTap: _startEditing,
      onSecondaryTapDown: widget.aliment != null && widget.onDelete != null ? (details) => _showContextMenu(details.globalPosition) : null,
      behavior: HitTestBehavior.opaque, // Assure que le GestureDetector fonctionne même sur les zones vides
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Ajouter une bordure subtile pour les cellules vides pour les rendre plus visibles
          border: displayValue.isEmpty 
              ? Border.all(color: Colors.grey.shade200, width: 0.5)
              : null,
        ),
        child: widget.textAlign == TextAlign.start 
          ? LayoutBuilder(
              builder: (context, constraints) {
                // Teste si le texte déborde (2 lignes max)
                final tp = TextPainter(
                  text: TextSpan(text: displayValue, style: const TextStyle(fontSize: 14)),
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth - 10); // padding left/right
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
                      style: const TextStyle(
                        fontSize: 14,
                      ),
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
                // Teste si le texte déborde (2 lignes max)
                final tp = TextPainter(
                  text: TextSpan(text: displayValue, style: const TextStyle(fontSize: 14)),
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth - 10); // padding left/right
                final needsTooltip = tp.didExceedMaxLines;
                final textWidget = Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      displayValue,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: widget.textAlign,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
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



/*────────────────────────── widget nom d'aliment ──────────────────────────*/
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

/*────────────────────────── data-source ──────────────────────────*/
class _AlimentsDS extends DataTableSource {
  _AlimentsDS(this.aliments, this.onValueChange, this.onDelete);

  final List<Aliment> aliments;
  final Future<void> Function(Aliment, String, String) onValueChange;
  final Future<void> Function(Aliment)? onDelete;

  bool _isOverflowing({
    required String text,
    required double maxWidth,
    int maxLines = 2,
    TextStyle style = const TextStyle(fontSize: 14),
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return tp.didExceedMaxLines;
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
              autoEdit: isGhost,          // ← on active l'auto-édition
            ),
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

/*──────────────────────────── widget ────────────────────────────*/
class AlimentsGrid extends StatefulWidget {
  const AlimentsGrid({
    super.key,
    required this.aliments,
    required this.onValueChange,
    this.onDelete,
    this.onAdd,
    this.currentGroup,
  });

  final List<Aliment> aliments;
  final Future<void> Function(Aliment, String, String) onValueChange;
  final Future<void> Function(Aliment)? onDelete;
  final Future<void> Function(String, String)? onAdd;
  final String? currentGroup; // Groupe actuel si on est sur une page de catégorie

  @override
  State<AlimentsGrid> createState() => _AlimentsGridState();
}

class _AlimentsGridState extends State<AlimentsGrid> {
  final _hCtrl = ScrollController();
  final _searchController = TextEditingController();
  List<Aliment> _filteredAliments = [];

  @override
  void initState() {
    super.initState();
    _filteredAliments = widget.aliments;
  }

  @override
  void didUpdateWidget(AlimentsGrid oldWidget) {
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
    final fake = Aliment(id: -1, libelle: '', groupeAlimentaire: widget.currentGroup);
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

  void _showAddAlimentDialog() {
    final textController = TextEditingController();
    String selectedGroup = widget.currentGroup ?? 'Divers'; // Utiliser le groupe actuel s'il est disponible
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter un nouvel aliment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nom de l\'aliment',
                    ),
                    autofocus: true,
                    onSubmitted: (_) => _addAlimentWithContext(textController, selectedGroup, dialogContext),
                  ),
                  // Afficher le sélecteur de groupe seulement si on n'est pas sur une page de catégorie
                  if (widget.currentGroup == null) ...[
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: Aliment.getGroupesAlimentaires(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        
                        if (snapshot.hasError || !snapshot.hasData) {
                          return const Text('Erreur lors du chargement des groupes');
                        }
                        
                        final groupes = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: selectedGroup,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Groupe alimentaire',
                          ),
                          items: groupes.map((groupe) {
                            return DropdownMenuItem<String>(
                              value: groupe['libelle'] as String,
                              child: Text(groupe['libelle'] as String),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedGroup = value;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => _addAlimentWithContext(textController, selectedGroup, dialogContext),
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addAlimentWithContext(TextEditingController textController, String groupeAlimentaire, BuildContext dialogContext) async {
    final alimentName = textController.text.trim();
    
    if (alimentName.isNotEmpty && widget.onAdd != null) {
      try {
        await widget.onAdd!(alimentName, groupeAlimentaire);
        
        // Fermer la boîte de dialogue immédiatement après l'ajout réussi
        Navigator.of(dialogContext).pop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aliment "$alimentName" ajouté avec succès'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (alimentName.isEmpty) {
      // Afficher un message si le champ est vide
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir un nom d\'aliment'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _addAliment(TextEditingController textController, String groupeAlimentaire) async {
    final alimentName = textController.text.trim();
    
    if (alimentName.isNotEmpty && widget.onAdd != null) {
      try {
        await widget.onAdd!(alimentName, groupeAlimentaire);
        
        // Fermer la boîte de dialogue immédiatement après l'ajout réussi
        if (mounted) {
          // Utiliser le contexte du dialog
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aliment "$alimentName" ajouté avec succès'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (alimentName.isEmpty) {
      // Afficher un message si le champ est vide
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir un nom d\'aliment'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
          child: Stack(
            children: [
              Column(
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
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _insertEmptyRow,
                  tooltip: "Ajouter",
                ),
              ),
            ],
          ),
        ),
      ),
      size: ColumnSize.L,
      fixedWidth: 170,
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
    final minWidth =
        kNameColWidth + kNumColWidth * kAlimentColumns.length + 50; // +50 pour la colonne poubelle

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
                                onChanged: _filterAliments,
          ),
                ),
              ],
            ),
          ),
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
                  key: ValueKey('aliments_grid_${_filteredAliments.length}'), // Force reconstruction
                  headingRowHeight : 100,
                  dataRowHeight    : 44,
                  columnSpacing    : 0,
                  horizontalMargin : 0,
                  horizontalScrollController: _hCtrl,
                  hidePaginator    : true,
                  rowsPerPage      : _filteredAliments.length > 0 ? _filteredAliments.length : 1,
                  availableRowsPerPage: const <int>[],
                  fixedLeftColumns : 1,
                  minWidth         : minWidth,
                  columns          : _buildColumns(),
                  source           : _AlimentsDS(_filteredAliments, _onValueChange, widget.onDelete),
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
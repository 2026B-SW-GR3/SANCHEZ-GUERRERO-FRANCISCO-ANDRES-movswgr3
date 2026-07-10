import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/destination.dart';
import '../../../../data/models/wishlist_collection.dart';
import '../../../../data/repositories/explore_repository.dart';

/// WishlistPickerSheet — la mejora de UX de Fase 4.
///
/// Reemplaza el toggle "ciego" del corazón por un picker explícito con:
///   1. Información del destino arriba (nombre + foto + ubicación).
///   2. Lista de wishlists del usuario con check si el destino ya está ahí.
///   3. Creación inline de una nueva wishlist (sin salir del feed).
///   4. Snackbar global con UNDO después de guardar (4s).
///
/// Aparece con `WishlistPickerSheet.show(context, destination)` y devuelve
/// `true` si hubo cambios en alguna colección. El padre puede usarlo para
/// refrescar el estado de los corazones en el feed.
class WishlistPickerSheet extends StatefulWidget {
  final Destination destination;

  const WishlistPickerSheet({
    super.key,
    required this.destination,
  });

  /// Helper de show con la configuración correcta del modal.
  /// Devuelve `true` si el usuario modificó el estado de wishlist del destino.
  static Future<bool> show({
    required BuildContext context,
    required Destination destination,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.45),
      builder: (_) => WishlistPickerSheet(destination: destination),
    );
    return result == true;
  }

  @override
  State<WishlistPickerSheet> createState() => _WishlistPickerSheetState();
}

class _WishlistPickerSheetState extends State<WishlistPickerSheet> {
  final _repo = ExploreRepository();

  // ─── Estado del sheet ──────────────────────────────────
  List<WishlistCollection> _collections = const [];
  bool _loading = true;
  bool _creatingNew = false;
  bool _didChange = false; // ← para saber si devolvemos true al cerrar
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cols = await _repo.getCollections();
    if (!mounted) return;
    setState(() {
      _collections = List.of(cols);
      _loading = false;
    });
  }

  // ─── Toggle del destino en una collection ──────────────
  Future<void> _toggle(WishlistCollection col) async {
    final wasIn = col.contains(widget.destination.id);
    HapticFeedback.lightImpact(); // feedback táctil sutil (Material guideline)

    // Optimistic update: actualiza UI al toque, sin esperar al backend.
    setState(() {
      final next = Set<String>.from(col.destinationIds);
      if (wasIn) {
        next.remove(widget.destination.id);
      } else {
        next.add(widget.destination.id);
      }
      _collections = _collections
          .map((c) => c.id == col.id
              ? c.copyWith(destinationIds: next)
              : c)
          .toList(growable: false);
      _didChange = true;
    });

    // Llamada real al repo (mocks: ~80ms; HTTP en prod).
    if (wasIn) {
      await _repo.removeFromCollection(
        collectionId: col.id,
        destinationId: widget.destination.id,
      );
    } else {
      await _repo.addToCollection(
        collectionId: col.id,
        destinationId: widget.destination.id,
      );
    }

    if (!mounted) return;

    // Cierra el sheet y emite el snackbar global con UNDO.
    Navigator.of(context).pop(true);
    _emitUndoSnackbar(colName: col.name, wasIn: wasIn, action: wasIn ? 'remove' : 'add');
  }

  Future<void> _createAndSelect() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final created = await _repo.createCollection(name: name);
    if (!mounted) return;
    await _repo.addToCollection(
      collectionId: created.id,
      destinationId: widget.destination.id,
    );
    if (!mounted) return;
    setState(() => _didChange = true);
    Navigator.of(context).pop(true);
    _emitUndoSnackbar(colName: created.name, wasIn: false, action: 'add');
  }

  /// Muestra un snackbar con UNDO. Si el usuario deshace, revertimos la op.
  void _emitUndoSnackbar({
    required String colName,
    required bool wasIn,
    required String action,
  }) {
    // Para no acumular muchos snackbars, limpiamos los previos.
    ScaffoldMessenger.of(context).clearSnackBars();

    final verb = action == 'add' ? 'Guardado' : 'Eliminado de';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.canvas, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$verb "$colName"',
                style: const TextStyle(color: AppColors.canvas, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        action: SnackBarAction(
          label: 'DESHACER',
          textColor: AppColors.rausch,
          onPressed: () async {
            // UNDO: si fue ADD → quitar; si fue REMOVE → volver a agregar.
            // En Fase 4 real: revalidar el repo + actualizar el feed.
            try {
              final cols = await _repo.getCollections();
              final col = cols.firstWhere((c) => c.name == colName);
              if (action == 'add') {
                await _repo.removeFromCollection(
                  collectionId: col.id,
                  destinationId: widget.destination.id,
                );
              } else {
                await _repo.addToCollection(
                  collectionId: col.id,
                  destinationId: widget.destination.id,
                );
              }
              // Emitimos un segundo snackbar para confirmar el undo.
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Acción deshecha'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (_) {
              // En Fase 4: notificar al backend que revalidó.
            }
          },
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sheetHeight = mq.size.height * 0.75;
    return AnimatedPadding(
      // Animación cuando aparece el teclado (no pisarlo).
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        height: _creatingNew ? sheetHeight : null,
        constraints: BoxConstraints(maxHeight: sheetHeight),
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DragHandle(),
              // CORRECCIÓN 1: Pasar _didChange como parámetro a _Header
              _Header(
                destination: widget.destination,
                didChange: _didChange,
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.hairline),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.foggy),
                      )
                    : _CollectionsList(
                        collections: _collections,
                        destinationId: widget.destination.id,
                        onToggle: _toggle,
                      ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.hairline),
              _CreateNewRow(
                creatingNew: _creatingNew,
                controller: _nameController,
                focusNode: _nameFocus,
                onToggleCreate: () {
                  setState(() => _creatingNew = !_creatingNew);
                  if (_creatingNew) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _nameFocus.requestFocus();
                    });
                  }
                },
                onCancelCreate: () {
                  setState(() {
                    _creatingNew = false;
                    _nameController.clear();
                  });
                },
                onCreate: _createAndSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill superior para afford de drag (estilo Material modal sheet).
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.hairline,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// CORRECCIÓN 1: _Header ahora recibe didChange como parámetro
class _Header extends StatelessWidget {
  final Destination destination;
  final bool didChange;

  const _Header({
    required this.destination,
    required this.didChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guardar en una wishlist',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CachedNetworkImage(
                          imageUrl: destination.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 200,
                          placeholder: (_, __) =>
                              Container(color: AppColors.softSurface),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.softSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${destination.location.display} · \$${destination.price.toStringAsFixed(0)} USD',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.foggy,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.ink, size: 22),
            // CORRECCIÓN 1: Usar didChange en lugar de _didChange
            onPressed: () => Navigator.of(context).pop(didChange),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

class _CollectionsList extends StatelessWidget {
  final List<WishlistCollection> collections;
  final String destinationId;
  final Future<void> Function(WishlistCollection) onToggle;

  const _CollectionsList({
    required this.collections,
    required this.destinationId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No tienes wishlists todavía.\nTocá "+ Crear nueva wishlist" abajo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.foggy, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      // ListView.builder (no ListView) → lazy, solo los items visibles.
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: collections.length,
      itemBuilder: (context, i) {
        final c = collections[i];
        final isChecked = c.contains(destinationId);
        return _CollectionRow(
          collection: c,
          isChecked: isChecked,
          onTap: () => onToggle(c),
        );
      },
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final WishlistCollection collection;
  final bool isChecked;
  final VoidCallback onTap;

  const _CollectionRow({
    required this.collection,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.rausch.withOpacity(.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Checkbox animado
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.rausch : Colors.transparent,
                  border: Border.all(
                    color: isChecked ? AppColors.rausch : AppColors.hof,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 14, color: AppColors.canvas)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collection.count == 0
                          ? 'Vacía'
                          : '${collection.count} ${collection.count == 1 ? 'alojamiento' : 'alojamientos'}',
                      style: const TextStyle(
                        color: AppColors.foggy,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (collection.isPrivate)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.lock_outline,
                      size: 16, color: AppColors.foggy),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateNewRow extends StatelessWidget {
  final bool creatingNew;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onToggleCreate;
  final VoidCallback onCancelCreate;
  final VoidCallback onCreate;

  const _CreateNewRow({
    required this.creatingNew,
    required this.controller,
    required this.focusNode,
    required this.onToggleCreate,
    required this.onCancelCreate,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: AnimatedCrossFade(
        firstChild: Row(
          children: [
            const Icon(Icons.add, color: AppColors.rausch, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onToggleCreate,
                child: const Text(
                  'Crear nueva wishlist',
                  style: TextStyle(
                    color: AppColors.rausch,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        secondChild: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(
                  color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Nombre de la wishlist',
                  hintStyle: const TextStyle(
                    color: AppColors.foggy, fontSize: 15,
                    fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: AppColors.softSurface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onCreate(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.foggy),
              onPressed: onCancelCreate,
              tooltip: 'Cancelar',
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.rausch,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: onCreate,
              child: const Text(
                'Crear',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        crossFadeState:
            creatingNew ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 220),
        // CORRECCIONES 2 y 3: layoutBuilder con firma correcta de AnimatedCrossFadeBuilder
        layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              topChild,
              bottomChild,
            ],
          );
        },
      ),
    );
  }
}
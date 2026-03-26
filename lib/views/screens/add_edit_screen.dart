import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/wishlist_item.dart';
import '../../models/priority.dart';
import '../../viewmodels/wishlist_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// [AddEditScreen] provee un formulario pulido e intuitivo para 
/// la creación o modificación de un ítem de la lista de deseos.
/// Se centra en la claridad y el diseño limpio, usando tarjetas y
/// campos de texto bien espaciados.
class AddEditScreen extends ConsumerStatefulWidget {
  /// Identificador opcional del ítem. Si es nulo, la pantalla entra en modo de "Creación".
  final String? itemId;

  const AddEditScreen({super.key, this.itemId});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  // Clave del formulario para manejar la validación global de los campos.
  final _formKey = GlobalKey<FormState>();
  
  // Controladores de los campos de texto
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  
  Priority _priority = Priority.necessity;
  DateTime _expectedDate = DateTime.now().add(const Duration(days: 30));
  WishlistItem? _existingItem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();

    // Si recibimos un ID, buscamos el ítem existente en el estado para precargar los datos.
    if (widget.itemId != null) {
      final items = ref.read(wishlistViewModelProvider).items;
      final matches = items.where((i) => i.id == widget.itemId);
      if (matches.isNotEmpty) {
        _existingItem = matches.first;
        _nameController.text = _existingItem!.name;
        _priceController.text = _existingItem!.price.toString();
        _locationController.text = _existingItem!.purchaseLocation;
        _notesController.text = _existingItem!.notes;
        _priority = _existingItem!.priority;
        _expectedDate = _existingItem!.expectedDate;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Despliega el selector de fecha nativo de Material 3.
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expectedDate = picked);
    }
  }

  /// Valida el formulario y despacha la acción a Riverpod para guardar/actualizar en DB.
  void _save() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      
      if (_existingItem != null) {
        final updated = _existingItem!.copyWith(
          name: _nameController.text,
          priority: _priority,
          price: price,
          purchaseLocation: _locationController.text,
          expectedDate: _expectedDate,
          notes: _notesController.text,
        );
        ref.read(wishlistViewModelProvider.notifier).updateItem(updated);
      } else {
        final newItem = WishlistItem(
          name: _nameController.text,
          priority: _priority,
          price: price,
          purchaseLocation: _locationController.text,
          expectedDate: _expectedDate,
          notes: _notesController.text,
        );
        ref.read(wishlistViewModelProvider.notifier).addItem(newItem);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingItem != null;
    final dateFormat = DateFormat.yMMMd('es');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Deseo' : 'Nuevo Deseo'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              onPressed: () {
                // TODO: En producción real, mostraríamos un diálogo de confirmación aquí
                ref.read(wishlistViewModelProvider.notifier).deleteItem(_existingItem!.id);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Agrupamiento visual encajado en un Card
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Nombre del Producto
                      TextFormField(
                        controller: _nameController,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        decoration: _buildInputDecoration('Producto / Deseo', Icons.star_border, colorScheme),
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                      ).animate().fadeIn(delay: 100.ms).slideX(),
                      
                      const SizedBox(height: 24),
                      
                      // Prioridad
                      DropdownButtonFormField<Priority>(
                        initialValue: _priority,
                        decoration: _buildInputDecoration('Prioridad', Icons.low_priority, colorScheme),
                        icon: const Icon(Icons.expand_more_rounded),
                        items: Priority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Icon(p.icon, color: p.color, size: 20),
                                const SizedBox(width: 12),
                                Text(p.label, style: TextStyle(color: p.color, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _priority = val);
                        },
                      ).animate().fadeIn(delay: 200.ms).slideX(),
                      
                      const SizedBox(height: 24),
                      
                      // Precio Estimado
                      TextFormField(
                        controller: _priceController,
                        style: theme.textTheme.titleMedium,
                        decoration: _buildInputDecoration('Precio estimado', Icons.euro_symbol_rounded, colorScheme),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val == null || double.tryParse(val) == null ? 'Número válido requerido' : null,
                      ).animate().fadeIn(delay: 300.ms).slideX(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              
              Card(
                elevation: 0,
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Tienda / URL
                      TextFormField(
                        controller: _locationController,
                        decoration: _buildInputDecoration('Tienda o URL', Icons.storefront_rounded, colorScheme),
                      ).animate().fadeIn(delay: 400.ms).slideX(),
                      
                      const SizedBox(height: 24),
                      
                      // Fecha Estimada
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: _buildInputDecoration('Fecha esperada de compra', Icons.calendar_today_rounded, colorScheme),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateFormat.format(_expectedDate), style: theme.textTheme.titleMedium),
                              Icon(Icons.edit_calendar_rounded, size: 20, color: colorScheme.primary),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(),
                      
                      const SizedBox(height: 24),
                      
                      // Notas
                      TextFormField(
                        controller: _notesController,
                        decoration: _buildInputDecoration('Notas o justificación', Icons.notes_rounded, colorScheme),
                        maxLines: 3,
                      ).animate().fadeIn(delay: 600.ms).slideX(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Botón de Acción Principal
              FilledButton.icon(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: colorScheme.primary.withOpacity(0.4),
                ),
                icon: const Icon(Icons.save_rounded, size: 24),
                label: Text(
                  isEditing ? 'Guardar Cambios' : 'Añadir a la Lista',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 1.0),
              
              const SizedBox(height: 48), // Padding inferior
            ],
          ),
        ),
      ),
    );
  }

  /// Helper paramétrico para construir decoraciones de cajas de texto (inputs) uniformemente.
  InputDecoration _buildInputDecoration(String label, IconData icon, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }
}

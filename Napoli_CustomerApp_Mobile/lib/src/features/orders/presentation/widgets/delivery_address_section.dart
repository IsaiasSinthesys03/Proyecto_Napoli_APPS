import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';

class DeliveryAddressSection extends StatelessWidget {
  final List<AddressModel> savedAddresses;
  final AddressModel? selectedAddress;
  final bool useManualAddress;
  final TextEditingController phoneController;
  final TextEditingController notesController;
  final TextEditingController addressController;
  final VoidCallback onChangeAddress;
  final ValueChanged<bool> onManualAddressToggle;

  const DeliveryAddressSection({
    super.key,
    required this.savedAddresses,
    required this.selectedAddress,
    required this.useManualAddress,
    required this.phoneController,
    required this.notesController,
    required this.addressController,
    required this.onChangeAddress,
    required this.onManualAddressToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Text(
              l10n.deliveryAddress,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            if (savedAddresses.isNotEmpty)
              TextButton.icon(
                onPressed: onChangeAddress,
                icon: const Icon(Icons.location_on, size: 16),
                label: Text(l10n.change),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Direcciones guardadas o formulario manual
        if (savedAddresses.isNotEmpty && !useManualAddress) ...[
          // Mostrar dirección seleccionada
          _buildSelectedAddressCard(context, theme, l10n),
          const SizedBox(height: 12),

          // Opción para usar dirección manual
          TextButton.icon(
            onPressed: () => onManualAddressToggle(true),
            icon: const Icon(Icons.edit_location, size: 16),
            label: Text(l10n.useDifferentAddress),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
              textStyle: theme.textTheme.bodySmall,
            ),
          ),
        ] else ...[
          // Formulario manual
          _buildManualAddressForm(context, theme, l10n),

          // Botón para volver a direcciones guardadas
          if (savedAddresses.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => onManualAddressToggle(false),
              icon: const Icon(Icons.bookmark, size: 16),
              label: Text(l10n.useSavedAddresses),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ],

        const SizedBox(height: 16),

        // Teléfono (siempre visible)
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phone,
            hintText: l10n.phoneHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),

        // Notas especiales
        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.specialNotes,
            hintText: l10n.specialNotesHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedAddressCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (selectedAddress == null) return Container();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getLabelIcon(selectedAddress!.label),
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selectedAddress!.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (selectedAddress!.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.defaultLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedAddress!.address}, ${selectedAddress!.city}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (selectedAddress!.details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              selectedAddress!.details,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualAddressForm(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Mensaje informativo
        if (savedAddresses.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.secondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.manualAddressInfo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Calle
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: l10n.street,
            hintText: l10n.streetHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'casa':
      case 'home':
        return Icons.home;
      case 'trabajo':
      case 'work':
        return Icons.work;
      case 'universidad':
      case 'uni':
      case 'escuela':
        return Icons.school;
      case 'gimnasio':
        return Icons.fitness_center;
      case 'familia':
        return Icons.family_restroom;
      case 'amigos':
        return Icons.people;
      case 'otro':
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }
}

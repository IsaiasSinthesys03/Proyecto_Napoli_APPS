import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/screens/saved_addresses_screen.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/utils/address_utils.dart';

class AddressSelectionDialog extends StatelessWidget {
  final List<AddressModel> savedAddresses;
  final AddressModel? selectedAddress;
  final ValueChanged<AddressModel> onAddressSelected;

  const AddressSelectionDialog({
    super.key,
    required this.savedAddresses,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Seleccionar Dirección'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: savedAddresses.length,
          itemBuilder: (context, index) {
            final address = savedAddresses[index];
            final isSelected = selectedAddress?.id == address.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AddressUtils.getLabelColor(
                      address.label,
                      theme,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    AddressUtils.getLabelIcon(address.label),
                    color: AddressUtils.getLabelColor(address.label, theme),
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      address.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (address.isDefault) ...[
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
                          'Predeterminada',
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${address.address}, ${address.city}'),
                    if (address.details.isNotEmpty)
                      Text(
                        address.details,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                onTap: () {
                  onAddressSelected(address);
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SavedAddressesScreen(),
              ),
            );
          },
          child: const Text('Gestionar Direcciones'),
        ),
      ],
    );
  }
}

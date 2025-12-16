import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';

class AddressFormDialog extends StatefulWidget {
  final AddressModel? address;
  final bool isFirstAddress;

  const AddressFormDialog({
    super.key,
    this.address,
    this.isFirstAddress = false,
  });

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  late TextEditingController labelController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController detailsController;
  late bool isDefault;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    labelController = TextEditingController(text: address?.label ?? '');
    addressController = TextEditingController(text: address?.address ?? '');
    cityController = TextEditingController(text: address?.city ?? '');
    detailsController = TextEditingController(text: address?.details ?? '');
    isDefault = address?.isDefault ?? widget.isFirstAddress;
  }

  @override
  void dispose() {
    labelController.dispose();
    addressController.dispose();
    cityController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.address != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.editAddressTitle : l10n.addAddressTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Etiqueta
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: l10n.labelLabel,
                hintText: l10n.labelHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dirección
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: l10n.addressLabel,
                hintText: l10n.addressHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Ciudad
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: l10n.cityLabel,
                hintText: l10n.cityHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Detalles adicionales
            TextField(
              controller: detailsController,
              decoration: InputDecoration(
                labelText: l10n.detailsLabel,
                hintText: l10n.detailsHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Hacer predeterminada
            CheckboxListTile(
              title: Text(l10n.setAsDefaultLabel),
              value: isDefault,
              onChanged: (value) {
                setState(() {
                  isDefault = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (labelController.text.isNotEmpty &&
                addressController.text.isNotEmpty &&
                cityController.text.isNotEmpty) {
              final newAddress = AddressModel(
                id: widget.address?.id ?? const Uuid().v4(),
                label: labelController.text,
                address: addressController.text,
                city: cityController.text,
                details: detailsController.text,
                isDefault: isDefault,
              );

              Navigator.pop(context, newAddress);
            }
          },
          child: Text(isEditing ? l10n.updateAction : l10n.addAction),
        ),
      ],
    );
  }
}

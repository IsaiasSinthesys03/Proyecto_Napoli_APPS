import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';
import '../widgets/address_card.dart';
import '../widgets/address_form_dialog.dart';
import '../widgets/address_empty_state.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.savedAddresses,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final addresses = state is Authenticated
              ? state.user.savedAddresses
              : <AddressModel>[];

          if (addresses.isEmpty) {
            return AddressEmptyState(
              onAddAddress: () => _showAddAddressDialog(context, addresses),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                address: address,
                index: index,
                onAction: (action, addr, idx) =>
                    _handleAddressAction(context, action, addr, idx, addresses),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final addresses = state is Authenticated
              ? state.user.savedAddresses
              : <AddressModel>[];

          return addresses.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddAddressDialog(context, addresses),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  icon: const Icon(Icons.add_location),
                  label: Text(l10n.addAddress),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleAddressAction(
    BuildContext context,
    String action,
    AddressModel address,
    int index,
    List<AddressModel> addresses,
  ) {
    switch (action) {
      case 'default':
        _setAsDefault(context, index, addresses);
        break;
      case 'edit':
        _showEditAddressDialog(context, address, index, addresses);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address, index, addresses);
        break;
    }
  }

  void _setAsDefault(
    BuildContext context,
    int index,
    List<AddressModel> addresses,
  ) {
    final updatedAddresses = addresses.asMap().entries.map((entry) {
      return entry.value.copyWith(isDefault: entry.key == index);
    }).toList();

    _updateAddresses(context, updatedAddresses);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
            context,
          )!.addressSetAsDefault(updatedAddresses[index].label),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AddressModel address,
    int index,
    List<AddressModel> addresses,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAddressTitle),
        content: Text(
          AppLocalizations.of(
            context,
          )!.deleteAddressConfirmation(address.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final updatedAddresses = List<AddressModel>.from(addresses)
                ..removeAt(index);
              _updateAddresses(context, updatedAddresses);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.addressDeleted(address.label),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog(
    BuildContext context,
    List<AddressModel> addresses,
  ) {
    _showAddressFormDialog(context, null, null, addresses);
  }

  void _showEditAddressDialog(
    BuildContext context,
    AddressModel address,
    int index,
    List<AddressModel> addresses,
  ) {
    _showAddressFormDialog(context, address, index, addresses);
  }

  Future<void> _showAddressFormDialog(
    BuildContext context,
    AddressModel? address,
    int? index,
    List<AddressModel> addresses,
  ) async {
    final isEditing = address != null;

    final result = await showDialog<AddressModel>(
      context: context,
      builder: (dialogContext) => AddressFormDialog(
        address: address,
        isFirstAddress: addresses.isEmpty,
      ),
    );

    if (result != null && context.mounted) {
      List<AddressModel> updatedAddresses;

      if (result.isDefault) {
        // Clear other defaults
        updatedAddresses = addresses
            .map((addr) => addr.copyWith(isDefault: false))
            .toList();
      } else {
        updatedAddresses = List<AddressModel>.from(addresses);
      }

      if (isEditing && index != null) {
        updatedAddresses[index] = result;
      } else {
        updatedAddresses.add(result);
      }

      _updateAddresses(context, updatedAddresses);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? AppLocalizations.of(context)!.addressUpdated
                : AppLocalizations.of(context)!.addressAdded,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateAddresses(BuildContext context, List<AddressModel> addresses) {
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;
    if (state is Authenticated) {
      final updatedUser = state.user.copyWith(savedAddresses: addresses);
      authCubit.updateProfile(updatedUser);
    }
  }
}

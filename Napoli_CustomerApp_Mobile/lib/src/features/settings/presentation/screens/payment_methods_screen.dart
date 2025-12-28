import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/payment_method.dart';
import '../widgets/payment_methods/add_card_dialog.dart';
import '../widgets/payment_methods/alternative_payment_methods.dart';
import '../widgets/payment_methods/payment_method_card.dart';
import '../widgets/payment_methods/payment_methods_empty_state.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.paymentMethodsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            onPressed: () => _showAddPaymentMethodDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! Authenticated) {
            return Center(child: Text(l10n.errorTitle)); // Basic error handling
          }

          final paymentMethods = state.user.savedCards;

          if (paymentMethods.isEmpty) {
            return PaymentMethodsEmptyState(
              onAddMethod: () => _showAddPaymentMethodDialog(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                paymentMethods.length + 1, // +1 para métodos alternativos
            itemBuilder: (context, index) {
              if (index < paymentMethods.length) {
                return PaymentMethodCard(
                  paymentMethod: paymentMethods[index],
                  onSetDefault: () => _setAsDefault(index, paymentMethods),
                  onEdit: () => _showEditPaymentMethodDialog(
                    context,
                    paymentMethods[index],
                    index,
                    paymentMethods,
                  ),
                  onDelete: () => _showDeleteConfirmation(
                    context,
                    paymentMethods[index],
                    index,
                    paymentMethods,
                  ),
                );
              } else {
                return const AlternativePaymentMethods();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentMethodDialog(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCard),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCardDialog(
        onSave: (paymentMethod) {
          final authCubit = context.read<AuthCubit>();
          final state = authCubit.state;
          if (state is Authenticated) {
            final currentCards = List<PaymentMethodModel>.from(
              state.user.savedCards,
            );
            if (paymentMethod.isDefault) {
              for (var method in currentCards) {
                method.isDefault = false;
              }
            }
            currentCards.add(paymentMethod);
            authCubit.updateProfile(
              state.user.copyWith(savedCards: currentCards),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cardAdded),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showEditPaymentMethodDialog(
    BuildContext context,
    PaymentMethodModel paymentMethod,
    int index,
    List<PaymentMethodModel> currentCards,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddCardDialog(
        paymentMethod: paymentMethod,
        onSave: (updatedMethod) {
          final authCubit = context.read<AuthCubit>();
          final state = authCubit.state;
          if (state is Authenticated) {
            final cards = List<PaymentMethodModel>.from(currentCards);
            if (updatedMethod.isDefault) {
              for (var method in cards) {
                method.isDefault = false;
              }
            }
            cards[index] = updatedMethod;
            authCubit.updateProfile(state.user.copyWith(savedCards: cards));
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cardUpdated),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _setAsDefault(int index, List<PaymentMethodModel> currentCards) {
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;
    if (state is Authenticated) {
      final cards = List<PaymentMethodModel>.from(currentCards);
      for (var i = 0; i < cards.length; i++) {
        cards[i].isDefault = (i == index);
      }
      authCubit.updateProfile(state.user.copyWith(savedCards: cards));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.cardSetAsDefault(
              cards[index].cardBrand ?? 'Card',
              (cards[index].cardNumber ?? '****').split(' ').last,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PaymentMethodModel paymentMethod,
    int index,
    List<PaymentMethodModel> currentCards,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePaymentMethodTitle),
        content: Text(
          AppLocalizations.of(context)!.deletePaymentMethodConfirmation(
            paymentMethod.cardBrand ?? 'Card',
            (paymentMethod.cardNumber ?? '****').split(' ').last,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authCubit = context.read<AuthCubit>();
              final state = authCubit.state;
              if (state is Authenticated) {
                final cards = List<PaymentMethodModel>.from(currentCards);
                cards.removeAt(index);
                authCubit.updateProfile(state.user.copyWith(savedCards: cards));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.paymentMethodDeleted(paymentMethod.cardBrand ?? 'Card'),
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
}

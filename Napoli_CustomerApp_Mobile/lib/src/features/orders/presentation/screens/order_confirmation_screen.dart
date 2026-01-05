// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/cubit/cart_cubit.dart';

import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/payment_method.dart';
import 'bank_transfer_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:napoli_app_v1/src/features/orders/domain/entities/order.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:napoli_app_v1/src/core/services/business_hours.service.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/business_closed_dialog.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import '../widgets/delivery_address_section.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/order_summary.dart';
import '../widgets/estimated_time_widget.dart';
import '../widgets/address_selection_dialog.dart';
import '../widgets/payment_action_button.dart';
import '../widgets/security_note.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<OrdersCubit>()),
        BlocProvider.value(value: getIt<CartCubit>()),
      ],
      child: BlocListener<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state is OrderSaved) {
            context.read<CartCubit>().clearCart();
            context.go('/order-placed');
          } else if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al procesar el pedido: ${state.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: const _OrderConfirmationContent(),
      ),
    );
  }
}

class _OrderConfirmationContent extends StatefulWidget {
  const _OrderConfirmationContent();

  @override
  State<_OrderConfirmationContent> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<_OrderConfirmationContent> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _addressNumberController =
      TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isProcessingPayment = false;
  AddressModel? _selectedAddress;
  bool _useManualAddress = false;

  // Variables para método de pago
  String _selectedPaymentMethod = 'efectivo';
  PaymentMethodModel? _selectedCard;

  // Variables para transferencia bancaria
  bool _transferConfirmed = false;

  // Feature flag: Habilitar/deshabilitar tarjetas guardadas
  static const bool _enableSavedCards = true;

  @override
  void initState() {
    super.initState();
    // Seleccionar automáticamente la dirección predeterminada
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final addresses = authState.user.savedAddresses;
      if (addresses.isNotEmpty) {
        _selectedAddress = addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => addresses.first,
        );
      }

      final cards = authState.user.savedCards;
      if (cards.isNotEmpty) {
        _selectedCard = cards.firstWhere(
          (card) => card.isDefault,
          orElse: () => cards.first,
        );
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressNumberController.dispose();
    _complementController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleTransferTap() async {
    final result =
        await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BankTransferScreen(
                  totalAmount: context.read<CartCubit>().state.total.toDouble(),
                ),
              ),
            )
            as Map<String, dynamic>?;

    if (result != null && result['confirmed'] == true) {
      setState(() {
        _selectedPaymentMethod = 'transferencia';
        _transferConfirmed = true;
        _selectedCard = null;
      });
    }
  }

  void _processPayment() async {
    final l10n = AppLocalizations.of(context)!;
    // Validar horarios de atención
    // Validar horarios de atención
    final businessHoursService = getIt<BusinessHoursService>();
    final isOpen = await businessHoursService.isOpen();

    if (!isOpen) {
      final nextOpeningTime = await businessHoursService.getNextOpeningTime();
      final schedule = await businessHoursService.getBusinessHoursMessage();

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BusinessClosedDialog(
          nextOpeningTime: nextOpeningTime,
          schedule: schedule,
        ),
      );
      return;
    }

    if (!mounted) return;

    // Validar dirección
    if (_selectedAddress == null && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.selectAddressOrManual,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Validar teléfono
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.enterPhoneNumber,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Validar transferencia confirmada
    if (_selectedPaymentMethod == 'transferencia' && !_transferConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.completeTransferData,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    // Obtener usuario actual
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes iniciar sesión para hacer un pedido'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isProcessingPayment = false);
      return;
    }

    final customerId = authState.user.id;

    // Crear orden
    final AddressModel finalAddress =
        _selectedAddress ??
        AddressModel(
          id: 'manual-${DateTime.now().millisecondsSinceEpoch}',
          label: 'Dirección Manual',
          address:
              '${_addressController.text.trim()} ${_addressNumberController.text.trim()}',
          city: '', // Default or inferred?
          details: _complementController.text.trim(),
          isDefault: false,
        );

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: customerId,
      items: context.read<CartCubit>().state.items,
      total: context.read<CartCubit>().state.total,
      status: OrderStatus.pending,
      date: DateTime.now(),
      address: finalAddress,
      paymentMethod: _selectedPaymentMethod,
      customerNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    // Guardar orden en Supabase usando OrdersCubit
    await context.read<OrdersCubit>().saveOrder(order, customerId);

    if (mounted) {
      setState(() => _isProcessingPayment = false);
      // BlocListener handles navigation on success
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Obtener datos del usuario desde AuthCubit
    final authState = context.watch<AuthCubit>().state;
    final List<AddressModel> savedAddresses = authState is Authenticated
        ? authState.user.savedAddresses
        : [];
    final List<PaymentMethodModel> savedCards = authState is Authenticated
        ? authState.user.savedCards
        : [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.confirmOrder,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen del pedido
              const OrderSummary(),
              const SizedBox(height: 20),

              // Tiempo estimado
              const EstimatedTimeWidget(),
              const SizedBox(height: 20),

              // Sección de dirección de envío
              DeliveryAddressSection(
                savedAddresses: savedAddresses,
                selectedAddress: _selectedAddress,
                useManualAddress: _useManualAddress,
                phoneController: _phoneController,
                notesController: _notesController,
                addressController: _addressController,
                onChangeAddress: () =>
                    _showAddressSelectionDialog(theme, savedAddresses),
                onManualAddressToggle: (value) =>
                    setState(() => _useManualAddress = value),
              ),
              const SizedBox(height: 20),

              // Sección de método de pago
              PaymentMethodSelector(
                selectedPaymentMethod: _selectedPaymentMethod,
                transferConfirmed: _transferConfirmed,
                selectedCard: _selectedCard,
                savedCards: savedCards,
                enableSavedCards: _enableSavedCards,
                onMethodChanged: (value) => setState(() {
                  _selectedPaymentMethod = value;
                  _selectedCard = null;
                }),
                onCardSelected: (card) => setState(() {
                  _selectedPaymentMethod = 'card';
                  _selectedCard = card;
                }),
                onTransferTap: _handleTransferTap,
              ),
              const SizedBox(height: 20),

              // Botón de pago
              PaymentActionButton(
                isProcessing: _isProcessingPayment,
                paymentMethod: _selectedPaymentMethod,
                onPressed: _isProcessingPayment ? null : _processPayment,
              ),
              const SizedBox(height: 16),

              // Información de seguridad
              const SecurityNote(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressSelectionDialog(
    ThemeData theme,
    List<AddressModel> savedAddresses,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddressSelectionDialog(
        savedAddresses: savedAddresses,
        selectedAddress: _selectedAddress,
        onAddressSelected: (address) {
          setState(() {
            _selectedAddress = address;
            _useManualAddress = false;
          });
        },
      ),
    );
  }
}

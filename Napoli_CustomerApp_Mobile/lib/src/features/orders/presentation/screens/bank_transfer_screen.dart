import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/services/business_hours.service.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/di.dart';
import '../widgets/bank_instructions.dart';
import '../widgets/payment_proof_upload.dart';
import '../widgets/bank_transfer_closed_view.dart';
import '../widgets/bank_transfer_amount_display.dart';
import '../widgets/bank_transfer_instructions_info.dart';

class BankTransferScreen extends StatefulWidget {
  final double totalAmount;

  const BankTransferScreen({super.key, required this.totalAmount});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  bool _receiptUploaded = false;
  bool _isOpen = true; // Default to true while loading
  bool _isLoading = true;

  // Datos bancarios iniciales vacíos
  Map<String, String> _bankData = {
    'banco': '',
    'titular': '',
    'clabe': '',
    'cuenta': '',
    'concepto': 'PEDIDO-${DateTime.now().millisecondsSinceEpoch}',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isOpen = await getIt<BusinessHoursService>().isOpen();
    final bankDetails = await getIt<RestaurantConfigService>().getBankDetails();

    // Maintain concept dynamic as it depends on timestamp, but use DB details
    final concept = _bankData['concepto']!;

    if (mounted) {
      setState(() {
        _isOpen = isOpen;
        _bankData = {...bankDetails, 'concepto': concept};
        _isLoading = false;
      });
    }
  }

  void _confirmTransfer() {
    if (!_receiptUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor adjunta el comprobante de transferencia',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Regresar confirmación al OrderConfirmationScreen
    Navigator.pop(context, {
      'confirmed': true,
      'receipt': _receiptUploaded,
      'concept': _bankData['concepto'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Transferencia Bancaria',
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
      ),
      body: !_isOpen
          ? const BankTransferClosedView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerta informativa
                  const BankTransferInstructionsInfo(),

                  const SizedBox(height: 24),

                  // Monto a transferir
                  BankTransferAmountDisplay(totalAmount: widget.totalAmount),

                  const SizedBox(height: 24),

                  // Datos bancarios
                  BankInstructions(bankData: _bankData),

                  const SizedBox(height: 24),

                  // Adjuntar comprobante
                  PaymentProofUpload(
                    receiptUploaded: _receiptUploaded,
                    onReceiptChanged: (value) =>
                        setState(() => _receiptUploaded = value),
                  ),

                  const SizedBox(height: 24),

                  // Nota importante
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Importante: Tu pedido será procesado una vez que validemos tu transferencia. Esto puede tardar entre 5 y 30 minutos.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de confirmación
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _confirmTransfer,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirmar Transferencia'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

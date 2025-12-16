import 'package:flutter/material.dart';

class PaymentIconResolver {
  static IconData resolve(String paymentMethod) {
    if (paymentMethod.toLowerCase().contains('visa')) {
      return Icons.credit_card;
    }
    if (paymentMethod.toLowerCase().contains('mastercard')) {
      return Icons.credit_card;
    }
    if (paymentMethod.toLowerCase().contains('efectivo')) {
      return Icons.money;
    }
    if (paymentMethod.toLowerCase().contains('transferencia')) {
      return Icons.account_balance;
    }
    return Icons.payment;
  }
}

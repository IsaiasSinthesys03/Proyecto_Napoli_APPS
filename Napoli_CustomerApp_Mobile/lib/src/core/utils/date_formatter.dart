import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';

class DateFormatter {
  static String formatRelative(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return l10n.timeAgoMinutes(difference.inMinutes);
      }
      return l10n.timeAgoHours(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.timeAgoDays(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

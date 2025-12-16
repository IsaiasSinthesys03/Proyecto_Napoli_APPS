import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/notification_tile.dart';

class NotificationTypesSection extends StatelessWidget {
  final bool enabled;
  final bool orderUpdates;
  final bool promotions;
  final bool newProducts;
  final bool deliveryReminders;
  final bool chatMessages;
  final bool weeklyOffers;
  final bool appUpdates;

  final ValueChanged<bool> onOrderUpdatesChanged;
  final ValueChanged<bool> onPromotionsChanged;
  final ValueChanged<bool> onNewProductsChanged;
  final ValueChanged<bool> onDeliveryRemindersChanged;
  final ValueChanged<bool> onChatMessagesChanged;
  final ValueChanged<bool> onWeeklyOffersChanged;
  final ValueChanged<bool> onAppUpdatesChanged;

  const NotificationTypesSection({
    super.key,
    required this.enabled,
    required this.orderUpdates,
    required this.promotions,
    required this.newProducts,
    required this.deliveryReminders,
    required this.chatMessages,
    required this.weeklyOffers,
    required this.appUpdates,
    required this.onOrderUpdatesChanged,
    required this.onPromotionsChanged,
    required this.onNewProductsChanged,
    required this.onDeliveryRemindersChanged,
    required this.onChatMessagesChanged,
    required this.onWeeklyOffersChanged,
    required this.onAppUpdatesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notificationTypes,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              NotificationTile(
                icon: Icons.delivery_dining,
                title: l10n.orderUpdates,
                subtitle: l10n.orderUpdatesSubtitle,
                value: orderUpdates,
                onChanged: enabled ? onOrderUpdatesChanged : null,
              ),
              NotificationTile(
                icon: Icons.local_offer,
                title: l10n.promotions,
                subtitle: l10n.promotionsSubtitle,
                value: promotions,
                onChanged: enabled ? onPromotionsChanged : null,
              ),
              NotificationTile(
                icon: Icons.new_releases,
                title: l10n.newProducts,
                subtitle: l10n.newProductsSubtitle,
                value: newProducts,
                onChanged: enabled ? onNewProductsChanged : null,
              ),
              NotificationTile(
                icon: Icons.schedule,
                title: l10n.deliveryReminders,
                subtitle: l10n.deliveryRemindersSubtitle,
                value: deliveryReminders,
                onChanged: enabled ? onDeliveryRemindersChanged : null,
              ),
              NotificationTile(
                icon: Icons.chat,
                title: l10n.chatMessages,
                subtitle: l10n.chatMessagesSubtitle,
                value: chatMessages,
                onChanged: enabled ? onChatMessagesChanged : null,
              ),
              NotificationTile(
                icon: Icons.weekend,
                title: l10n.weeklyOffers,
                subtitle: l10n.weeklyOffersSubtitle,
                value: weeklyOffers,
                onChanged: enabled ? onWeeklyOffersChanged : null,
              ),
              NotificationTile(
                icon: Icons.system_update,
                title: l10n.appUpdates,
                subtitle: l10n.appUpdatesSubtitle,
                value: appUpdates,
                onChanged: enabled ? onAppUpdatesChanged : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

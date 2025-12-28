import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:napoli_app_v1/src/di.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../domain/entities/coupon.dart';

class CouponHistoryScreen extends StatefulWidget {
  const CouponHistoryScreen({super.key});

  @override
  State<CouponHistoryScreen> createState() => _CouponHistoryScreenState();
}

class _CouponHistoryScreenState extends State<CouponHistoryScreen> {
  final CouponRepository _repository = getIt<CouponRepository>();
  List<Coupon> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    final result = await _repository.getCoupons();

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
      },
      (coupons) {
        setState(() {
          _coupons = coupons.reversed.toList(); // Más recientes primero
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.confirmTitle),
        content: Text(AppLocalizations.of(context)!.clearHistoryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.clearAll),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _repository.clearHistory();
      _loadCoupons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.historyCleared)),
        );
      }
    }
  }

  /// Get coupon description - uses the description from Supabase
  String _getCouponDescription(Coupon coupon) {
    // Use the actual description from the coupon entity
    if (coupon.description.isNotEmpty) {
      return coupon.description;
    }
    // Fallback: generate description based on discount percentage
    if (coupon.discountPercentage > 0) {
      return '${coupon.discountPercentage}% de descuento';
    }
    return AppLocalizations.of(context)!.specialCoupon;
  }

  /// Get coupon color based on discount percentage
  Color _getCouponColor(BuildContext context, Coupon coupon) {
    final discount = coupon.discountPercentage;
    if (discount >= 50) {
      return Theme.of(context).colorScheme.error;
    } else if (discount >= 20) {
      return Theme.of(context).colorScheme.secondary;
    } else if (discount >= 10) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha((0.6 * 255).round());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myCoupons),
        actions: [
          if (_coupons.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
              tooltip: AppLocalizations.of(context)!.clearHistoryTooltip,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coupons.isEmpty
          ? _buildEmptyState()
          : _buildCouponList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noCouponsTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha((0.75 * 255).round()),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noCouponsSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha((0.65 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(
            context,
          ).colorScheme.primary.withAlpha((0.1 * 255).round()),
          child: Row(
            children: [
              Icon(
                Icons.celebration,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.couponsWon(_coupons.length),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _coupons.length,
            itemBuilder: (context, index) {
              final coupon = _coupons[index];
              final code = coupon.code;
              final timestamp = coupon.receivedDate ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCouponColor(
                        context,
                        coupon,
                      ).withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: _getCouponColor(context, coupon),
                      size: 28,
                    ),
                  ),
                  title: Text(
                    code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        _getCouponDescription(coupon),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.wonDate(
                          DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha((0.7 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.06 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha((0.18 * 255).round()),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.activeStatus,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

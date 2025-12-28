import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:uuid/uuid.dart';
import 'package:napoli_app_v1/src/features/cart/domain/entities/cart_item.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/order_history.dart';
import 'package:napoli_app_v1/src/features/settings/domain/repositories/order_history_repository.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/favorite_products_list.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/order_details_sheet.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/purchase_history_filters.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/recent_orders_list.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/empty_orders_state.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<OrderHistory> orders = [];
  bool _isLoading = true;
  String? _error;
  String selectedFilter = 'all';

  final List<String> filters = ['all', 'delivered', 'in_progress', 'cancelled'];
  late final OrderHistoryRepository _repository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = getIt<OrderHistoryRepository>();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get customer ID from auth state
      final authCubit = getIt<AuthCubit>();
      final authState = authCubit.state;
      if (authState is Authenticated) {
        final customerId = authState.user.id;
        final loadedOrders = await _repository.getOrders(customerId);
        setState(() {
          orders = loadedOrders;
          _isLoading = false;
        });
      } else {
        setState(() {
          orders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar pedidos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderHistory> get filteredOrders {
    switch (selectedFilter) {
      case 'delivered':
        return orders
            .where((order) => order.status == OrderHistoryStatus.delivered)
            .toList();
      case 'in_progress':
        return orders
            .where((order) => order.status == OrderHistoryStatus.inProgress)
            .toList();
      case 'cancelled':
        return orders
            .where((order) => order.status == OrderHistoryStatus.cancelled)
            .toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.purchaseHistoryTitle,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          indicatorColor: theme.colorScheme.primary,
          tabs: [
            Tab(text: l10n.recentTab),
            Tab(text: l10n.favoritesTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Recientes
          _buildRecentOrdersTab(theme),
          // Tab Favoritos
          _buildFavoritesTab(theme),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTab(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filtros
        PurchaseHistoryFilters(
          selectedFilter: selectedFilter,
          filters: filters,
          onFilterSelected: (filter) => setState(() => selectedFilter = filter),
        ),

        // Lista de órdenes
        Expanded(
          child: filteredOrders.isEmpty
              ? EmptyOrdersState(selectedFilter: selectedFilter)
              : RecentOrdersList(
                  orders: filteredOrders,
                  onTap: (order) => _showOrderDetails(context, order),
                  onReorder: (order) => _reorderItems(context, order),
                  onTrack: (order) => _trackOrder(context, order),
                  onRate: (order, rating) => _handleRateOrder(order, rating),
                ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourFavorites,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.favoritesDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          FavoriteProductsList(orders: orders),

          const SizedBox(height: 32),

          // Acción para reordenar favoritos
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _reorderFavorites(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.orderFavorites),
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  void _showOrderDetails(BuildContext context, OrderHistory order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(
        order: order,
        onReorder: () => _reorderItems(context, order),
      ),
    );
  }

  Future<void> _handleRateOrder(OrderHistory order, int rating) async {
    try {
      await _repository.updateOrderRating(order.id, rating);

      if (mounted) {
        setState(() {
          final index = orders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            orders[index] = orders[index].copyWith(rating: rating);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gracias por tu calificación de $rating estrellas',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al calificar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _trackOrder(BuildContext context, OrderHistory order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rastreando pedido ${order.id}...'),
        action: SnackBarAction(
          label: 'Ver en mapa',
          onPressed: () {
            // Navegar a pantalla de tracking
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reorderItems(BuildContext context, OrderHistory order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pedir de nuevo'),
        content: const Text(
          '¿Quieres agregar los productos de este pedido al carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final cartCubit = context.read<CartCubit>();
              
              for (var item in order.items) {
                cartCubit.addItem(CartItem(
                  id: const Uuid().v4(), 
                  name: item.name,
                  image: '',
                  price: (item.price * 100).toInt(),
                  quantity: item.quantity,
                ));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Productos agregados al carrito'),
                  action: SnackBarAction(
                    label: 'Ver Carrito',
                    onPressed: () {
                       // Navegar al carrito
                    },
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Agregar al Carrito'),
          ),
        ],
      ),
    );
  }

  void _reorderFavorites(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Agregando favoritos al carrito...'),
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: () {
            // Navegar al carrito
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

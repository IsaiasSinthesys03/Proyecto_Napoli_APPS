import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../../core/services/location_service.dart';
import 'orders_state.dart';

/// Cubit para gestionar pedidos
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;
  Order? _currentOrder; // Guardar la orden actual para mantener datos
  Timer? _locationTimer;
  String? _trackingDriverId;
  // Modo de prueba: enviar sólo una ubicación al aceptar pedido
  // Para producción, establecer en false para iniciar el envío periódico cada 10s
  final bool _testingSingleSend = false;

  OrdersCubit(this.repository) : super(const OrdersInitial()) {
    debugPrint('📦 OrdersCubit created');
  }

  @override
  Future<void> close() {
    _stopLocationTracking();
    return super.close();
  }

  /// Carga todos los pedidos (disponibles y activos) - Sin mostrar loading para mantener smooth
  Future<void> loadOrders(String driverId) async {
    debugPrint('📦 OrdersCubit.loadOrders called for driver: $driverId');
    // NO emitimos OrdersLoading() aquí para mantener la UI suave

    try {
      final availableResult = await repository.getAvailableOrders();
      debugPrint('📦 OrdersCubit got available orders result');

      final activeResult = await repository.getActiveOrders(driverId);
      debugPrint('📦 OrdersCubit got active orders result');

      availableResult.fold(
        (error) {
          debugPrint('❌ OrdersCubit error loading available orders: $error');
          // Emit error pero sin bloquear la UI completamente
        },
        (availableOrders) {
          debugPrint(
            '✅ OrdersCubit loaded ${availableOrders.length} available orders',
          );
          activeResult.fold(
            (error) {
              debugPrint('❌ OrdersCubit error loading active orders: $error');
              // Emit error pero sin bloquear la UI completamente
            },
            (activeOrders) {
              debugPrint(
                '✅ OrdersCubit loaded ${activeOrders.length} active orders',
              );
              // Emitir silenciosamente sin mostrar loading
              emit(
                OrdersLoaded(
                  availableOrders: availableOrders,
                  activeOrders: activeOrders,
                ),
              );
              debugPrint(
                '📦 OrdersCubit emitted OrdersLoaded state (smooth update)',
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('❌ OrdersCubit exception in loadOrders: $e');
      // No emitimos error aquí para mantener la UI suave
    }
  }

  /// Carga un pedido específico
  Future<void> loadOrderDetail(String orderId) async {
    // NO emitir loading aquí para no perder los datos de la orden actual
    debugPrint('📦 loadOrderDetail: Cargando detalles completos para $orderId');

    final result = await repository.getOrderById(orderId);

    result.fold(
      (error) {
        debugPrint('❌ loadOrderDetail error: $error');
        emit(OrdersError(error));
      },
      (order) {
        debugPrint(
          '✅ loadOrderDetail: Orden cargada del backend con customerPhone="${order.customerPhone}"',
        );
        // Simplemente emitir la orden cargada del backend
        // que ya tiene todos los datos incluyendo el teléfono
        emit(OrderDetailLoaded(order));
      },
    );
  }

  /// Establece la orden actual (se usa para preservar datos si es necesario)
  void setCurrentOrder(Order order) {
    _currentOrder = order;
    debugPrint(
      '📦 OrdersCubit.setCurrentOrder: Guardada orden ${order.id} con customerPhone="${order.customerPhone}"',
    );
  }

  /// Inicia el envío periódico de ubicación cada 10 segundos para el `driverId`
  void _startLocationTracking(String driverId) {
    try {
      if (_trackingDriverId == driverId && _locationTimer != null) {
        return; // Ya está en tracking
      }

      _stopLocationTracking();
      _trackingDriverId = driverId;

      // Enviar inmediatamente
      _sendLocation(driverId);

      // Luego cada 10 segundos
      _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _sendLocation(driverId);
      });
      debugPrint('📡 Started location tracking for $driverId');
    } catch (e) {
      debugPrint('❌ _startLocationTracking error: $e');
    }
  }

  /// Detiene el envío periódico de ubicación
  void _stopLocationTracking() {
    try {
      _locationTimer?.cancel();
      _locationTimer = null;
      _trackingDriverId = null;
      debugPrint('📡 Stopped location tracking');
    } catch (e) {
      debugPrint('❌ _stopLocationTracking error: $e');
    }
  }

  Future<void> _sendLocation(String driverId) async {
    try {
      final position = await LocationService.getCurrentPosition();
      final profileRepo = GetIt.I.get<ProfileRepository>();
      final result = await profileRepo.updateDriverLocation(
        driverId,
        position.latitude,
        position.longitude,
        DateTime.now().toUtc(),
      );

      result.fold((l) {
        debugPrint('❌ Failed to update driver location: $l');
      }, (driver) {
        debugPrint('✅ Location updated for driver ${driver.id}');
      });
    } catch (e) {
      debugPrint('⚠️ _sendLocation error: $e');
    }
  }

  /// Acepta un pedido
  Future<void> acceptOrder(String orderId, String driverId) async {
    try {
      final result = await repository.acceptOrder(orderId, driverId);

      result.fold(
        (error) {
          emit(OrdersError(error));
        },
        (updatedOrder) {
          // Fusionar con los datos de la orden anterior para mantener info completa
          final mergedOrder = _mergeOrderData(_currentOrder, updatedOrder);
          _currentOrder = mergedOrder;

          // Mostrar el pedido aceptado inmediatamente
          emit(OrderDetailLoaded(mergedOrder));
          // En modo prueba, enviar sólo una ubicación inmediatamente al aceptar
          try {
            if (_testingSingleSend) {
              _sendLocation(driverId).then((_) {
                debugPrint('📡 Sent single test location on accept for $driverId');
              }).catchError((e) {
                debugPrint('⚠️ _sendLocation error during accept: $e');
              });
            } else {
              _startLocationTracking(driverId);
            }
          } catch (e) {
            debugPrint('⚠️ Failed to start/perform location send: $e');
          }
          // Dar tiempo a la UI de procesar el estado
          Future.delayed(const Duration(milliseconds: 300), () {
            // Luego recargar la lista completa en background sin bloquear UI
            loadOrders(driverId);
          });
        },
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
    // Dar tiempo a que la UI procese el estado
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Confirma recogida del pedido
  Future<void> confirmPickup(String orderId, String driverId) async {
    try {
      final result = await repository.pickupOrder(orderId, driverId);

      result.fold(
        (error) {
          emit(OrdersError(error));
        },
        (updatedOrder) {
          // Fusionar con los datos de la orden anterior para mantener info completa
          final mergedOrder = _mergeOrderData(_currentOrder, updatedOrder);
          _currentOrder = mergedOrder;

          // Mostrar el pedido actualizado inmediatamente
          emit(OrderDetailLoaded(mergedOrder));
          // Dar tiempo a la UI de procesar el estado
          Future.delayed(const Duration(milliseconds: 300), () {
            // Luego recargar la lista completa en background sin bloquear UI
            loadOrders(driverId);
          });
        },
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
    // Dar tiempo a que la UI procese el estado
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Marca pedido en camino (same as confirmPickup in our flow)
  Future<void> markOnTheWay(String orderId, String driverId) async {
    await confirmPickup(orderId, driverId);
  }

  /// Marca pedido como entregado
  Future<void> markDelivered(String orderId, String driverId) async {
    try {
      final result = await repository.completeOrder(orderId, driverId);

      result.fold(
        (error) {
          emit(OrdersError(error));
        },
        (updatedOrder) {
          // Fusionar con los datos de la orden anterior para mantener info completa
          final mergedOrder = _mergeOrderData(_currentOrder, updatedOrder);
          _currentOrder = mergedOrder;

          // Mostrar el pedido entregado inmediatamente
          emit(OrderDetailLoaded(mergedOrder));
          // Al marcar entregado, detener el envío periódico de ubicación
          try {
            _stopLocationTracking();
          } catch (e) {
            debugPrint('⚠️ Failed to stop location tracking: $e');
          }
          // Dar tiempo a la UI de procesar el estado
          Future.delayed(const Duration(milliseconds: 300), () {
            // Luego recargar la lista completa en background sin bloquear UI
            loadOrders(driverId);
          });
        },
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
    // Dar tiempo a que la UI procese el estado
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Fusiona datos de dos órdenes, preservando campos no vacíos de la orden original
  Order _mergeOrderData(Order? originalOrder, Order updatedOrder) {
    if (originalOrder == null) {
      debugPrint(
        '⚠️ _mergeOrderData: originalOrder es null, retornando updatedOrder',
      );
      return updatedOrder;
    }

    debugPrint(
      '📋 _mergeOrderData: originalPhone="${originalOrder.customerPhone}", updatedPhone="${updatedOrder.customerPhone}"',
    );

    final merged = updatedOrder.copyWith(
      customerPhone:
          updatedOrder.customerPhone.isEmpty || updatedOrder.customerPhone == ""
          ? originalOrder.customerPhone
          : updatedOrder.customerPhone,
      customerName: updatedOrder.customerName.isEmpty
          ? originalOrder.customerName
          : updatedOrder.customerName,
    );

    debugPrint(
      '📋 _mergeOrderData: MERGED customerPhone="${merged.customerPhone}"',
    );
    return merged;
  }
}

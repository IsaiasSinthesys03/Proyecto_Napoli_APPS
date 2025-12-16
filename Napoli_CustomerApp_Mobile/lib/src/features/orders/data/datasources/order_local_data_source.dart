import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_storage_service.dart';
import '../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<void> saveOrder(OrderModel order);
}

@LazySingleton(as: OrderLocalDataSource)
class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  final LocalStorageService _localStorageService;
  static const String _ordersKey = 'orders';

  OrderLocalDataSourceImpl(this._localStorageService);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final jsonString = _localStorageService.getString(_ordersKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((e) => OrderModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveOrder(OrderModel order) async {
    try {
      final orders = await getOrders();
      orders.add(order);
      final jsonString = jsonEncode(orders.map((e) => e.toJson()).toList());
      await _localStorageService.setString(_ordersKey, jsonString);
    } catch (e) {
      throw CacheException();
    }
  }
}

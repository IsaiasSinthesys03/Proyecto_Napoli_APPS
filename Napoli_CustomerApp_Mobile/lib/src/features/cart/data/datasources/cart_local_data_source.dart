import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_storage_service.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> items);
  Future<void> clearCart();
}

@LazySingleton(as: CartLocalDataSource)
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final LocalStorageService _localStorageService;
  static const String _cartKey = 'cart_items';

  CartLocalDataSourceImpl(this._localStorageService);

  @override
  Future<List<CartItemModel>> getCart() async {
    try {
      final jsonString = _localStorageService.getString(_cartKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((e) => CartItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> saveCart(List<CartItemModel> items) async {
    try {
      final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
      await _localStorageService.setString(_cartKey, jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _localStorageService.remove(_cartKey);
    } catch (e) {
      throw CacheException();
    }
  }
}

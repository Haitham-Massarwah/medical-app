import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/appointment_cart.dart';

class CartService {
  static const String _cartKey = 'appointment_cart';

  /// Load cart from storage
  Future<AppointmentCart?> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson == null) {
        return null;
      }
      
      final Map<String, dynamic> decoded = json.decode(cartJson);
      return AppointmentCart.fromJson(decoded);
    } catch (e) {
      print('Error loading cart: $e');
      return null;
    }
  }

  /// Save cart to storage
  Future<bool> saveCart(AppointmentCart cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(cart.toJson());
      return await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart: $e');
      return false;
    }
  }

  /// Clear cart from storage
  Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_cartKey);
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(int index) async {
    try {
      final cart = await loadCart();
      if (cart != null && index >= 0 && index < cart.items.length) {
        cart.removeItem(index);
        return await saveCart(cart);
      }
      return false;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import './shopping_cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({this.dateTime, this.id, this.total, this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userId;
  Orders(this.token,this._orders,this.userId);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = 'https://shop-f08a6.firebaseio.com/orders/$userId.json?auth=$token';
    var response = await http.get(url);
    final orderData = json.decode(response.body) as Map<String, dynamic>;
    if (orderData == null) {
      return;
    }
    final List<OrderItem> loadedItems = [];
    orderData.forEach((key, value) {
      loadedItems.add(OrderItem(
        id: key,
        total: value['total'],
        dateTime: DateTime.parse(value['dateTime']),
        products: (value['products'] as List<dynamic>).map((item) {
          CartItem(
              id: item['id'],
              title: item['title'],
              price: item['price'],
              quantity: item['quantity']);
        }).toList(),
      ));
    });
    _orders = loadedItems.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> products, double amount) async {
    final timeStamp = DateTime.now();
    final url = 'https://shop-f08a6.firebaseio.com/orders/$userId.json?auth=$token';
    final response = await http.post(url,
        body: json.encode({
          'total': amount,
          'dateTime': timeStamp.toIso8601String(),
          'products': products
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          total: amount,
          products: products,
          dateTime: DateTime.now(),
        ));
    notifyListeners();
  }
}

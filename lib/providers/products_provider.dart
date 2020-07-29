import 'package:clothshopapp/models/http_exception.dart';

import 'product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  final token;
  final userId;
  List<Product> _items = [
//    Product(
//      id: 'p1',
//      title: 'Red Shirt',
//      description: 'A red shirt - it is pretty red!',
//      price: 29.99,
//      imageUrl:
//          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];
  Products(this.token,this._items,this.userId);

  List<Product> get items {
    return [
      ..._items
    ]; //a copy of items spread operator expands an iterable into individual elements
  }

  Future<void> fetchItems([bool filterByUser = false]) async {
    final filter = filterByUser==true?'orderBy="creatorId"&equalTo="$userId"':'';
    final url = 'https://shop-f08a6.firebaseio.com/products.json?auth=$token&$filter';
    try {
      final response = await http.get(url);
      final fetchedData = json.decode(response.body) as Map<String, dynamic>;

      if(fetchedData==null){
        return;
      }
      final url2 = 'https://shop-f08a6.firebaseio.com/userFav/$userId.json?auth=$token';
      final favResponse = await http.get(url2);
      final favResponse2 = json.decode(favResponse.body);
      final List<Product> loadedItems = [];
      fetchedData.forEach((key, value) {
        loadedItems.add(Product(
            id: key,
            title: value['title'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            description: value['description'],
            isFavourite: favResponse2==null?false:favResponse2[key]??false,
        ));
      });
      _items = loadedItems;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addItem(Product product) async {
    final url = 'https://shop-f08a6.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId':userId,
            //'isFavourite': product.isFavourite
          }));
      _items.add(Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          price: product.price,
          imageUrl: product.imageUrl,
          description: product.description));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get favItems {
    return _items.where((item) => item.isFavourite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    final url = 'https://shop-f08a6.firebaseio.com/products/$id.json?auth=$token';
    await http.patch(url,
        body: json.encode({
          'title': product.title,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'description': product.description
        }));
    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-f08a6.firebaseio.com/products/$id.json?auth=$token';
    final currentProductIndex = _items.indexWhere((prod) => prod.id == id);
    var currentProduct = _items[currentProductIndex];
    _items.removeAt(currentProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if(response.statusCode>=400){
      _items.insert(currentProductIndex, currentProduct);
      notifyListeners();
      throw HttpException('Could not delete product!');
    }
    currentProduct = null;
  }
}

import 'package:clothshopapp/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Product with ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  Product({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.imageUrl,
    @required this.description,
    this.isFavourite=false,
});

  Future<void> toggleFavourite(String token,String userId) async {
    isFavourite=!isFavourite;
    notifyListeners();
    final url = 'https://shop-f08a6.firebaseio.com/userFav/$userId/$id.json?auth=$token';
    final response = await http.put(url,body:json.encode(isFavourite));
    if(response.statusCode>=400){
      isFavourite=!isFavourite;
      notifyListeners();
      throw HttpException('Not added in Favourites!');
    }
  }
}
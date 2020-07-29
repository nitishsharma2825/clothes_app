import 'package:clothshopapp/models/http_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String token;
  String userId;
  DateTime expiryDate;
  Timer _authTimer;

  bool get isAuth{
    if(getToken!=null){
      return true;
    }
    else{
      return false;
    }
  }
  String get getUserId{
    return userId;
  }
  String get getToken{
    if(token!=null && expiryDate!=null && expiryDate.isAfter(DateTime.now())){
      return token;
    }
    return null;
  }

  Future<bool> tryAutoLogin() async {
  final prefs = await SharedPreferences.getInstance();
  if(!prefs.containsKey('userData')){
    return false;
  }
  final extractedData = json.decode(prefs.getString('userData')) as Map<String,dynamic>;
  final endDate = DateTime.parse(extractedData['expiryDate']);
  if(endDate.isBefore(DateTime.now())){
    return false;
  }
  token = extractedData['token'];
  userId=extractedData['userId'];
  expiryDate=extractedData['expiryDate'];
  notifyListeners();
  autoLogout();
  return true;
  }

  Future<void> authenticate(String email, String password,
      String urlFunc) async {
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlFunc?key=AIzaSyDtzbGEqB0HHYrtd98A0iKSMLDQVyLnJ8Y';
    try {
      final response = await http.post(
          url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      token = responseData['idToken'];
      userId = responseData['localId'];
      expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', json.encode({
        'token':token,
        'userId':userId,
        'expiryDate':expiryDate
      }));
    } catch (error) {
      throw error;
    }
  }


  Future<void> signup(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    token=null;
    userId=null;
    expiryDate=null;
    if(_authTimer!=null){
      _authTimer.cancel();
    }
    _authTimer=null;
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }
  void autoLogout(){
    if(_authTimer!=null){
      _authTimer.cancel();
    }
    final timeToExpiry = expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry),logout);
  }


}


import 'package:clothshopapp/providers/auth.dart';
import 'package:clothshopapp/screens/auth_screen.dart';
import 'package:clothshopapp/screens/cart-items-screen.dart';
import 'package:clothshopapp/screens/orders-screen.dart';
import 'package:clothshopapp/widgets/splash_screen.dart';
import 'package:flutter/cupertino.dart';

import './providers/shopping_cart.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/products_provider.dart';
import './providers/orders.dart';
import './screens/user-products-screen.dart';
import './screens/edit-products-screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, auth, previousProducts) => Products(
              auth.getToken,
              previousProducts == null ? [] : previousProducts.items,
              auth.getUserId),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrders) => Orders(auth.getToken,
              previousOrders == null ? [] : previousOrders.orders, auth.userId),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'Shop',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Lato',
              textTheme: ThemeData.light().textTheme.copyWith(
                    headline6: TextStyle(fontFamily: 'Anton'),
                  )),
          home: auth.isAuth
              ? ProductScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()
          ),
          routes: {
            '/product-detail-screen': (context) => ProductDetailScreen(),
            '/cart-items-screen': (context) => CartScreen(),
            '/orders-screen': (context) => OrderScreen(),
            '/user-products-screen': (context) => UserProductsScreen(),
            '/edit-products-screen': (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

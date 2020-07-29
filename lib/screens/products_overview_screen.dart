import 'package:clothshopapp/providers/products_provider.dart';
import 'package:clothshopapp/widgets/app_drawer.dart';
import 'package:clothshopapp/widgets/badge.dart';
import 'package:clothshopapp/widgets/product_item.dart';
import 'package:clothshopapp/widgets/products_grid.dart';
import '../providers/shopping_cart.dart';
import '../providers/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


enum options {
  favourites,
  all,
}

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool showFav = false;
  bool isLoading= false;
  @override
  void initState() {
    setState(() {
      isLoading=true;
    });
    Provider.of<Products>(context,listen: false).fetchItems().then((value){
      setState(() {
        isLoading=false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (context, cart, child) =>Badge(
              child: child,
              value:cart.noOfItems.toString(),
            ),
            child:IconButton(
              icon: Icon(Icons.shopping_cart), onPressed: () {
                Navigator.of(context).pushNamed('/cart-items-screen');
            },
            ) ,
          ),
          PopupMenuButton(
            onSelected: (options selectedValue) {
              setState(() {
                if (selectedValue == options.favourites) {
                  showFav = true;
                }
                if (selectedValue == options.all) {
                  showFav = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                child: Text('Only favourites'),
                value: options.favourites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: options.all,
              )
            ],
          )
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading?Center(child: CircularProgressIndicator(),):ProductsGrid(showFav: showFav),
    );
  }
}

import 'package:clothshopapp/providers/auth.dart';
import 'package:clothshopapp/providers/product.dart';
import 'package:clothshopapp/providers/shopping_cart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
//  final String id;
//  final String title;
//  final String imageUrl;

//  ProductItem({this.imageUrl, this.title, this.id});

  @override
  Widget build(BuildContext context) {
    final snack= Scaffold.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/product-detail-screen', arguments: product.id);
        },
        child: GridTile(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('/assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
              // style: Theme.of(context).textTheme.headline6,
            ),
            leading: Consumer<Product>(
              builder: (context, product, child) => IconButton(
                icon: product.isFavourite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                onPressed:() async {
                  try{
                    await product.toggleFavourite(auth.getToken,auth.userId);
                  } catch(error){
                    snack.showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                },
                color: Theme.of(context).accentColor,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.title, product.price);
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Added item to the cart'),
                  //duration: Duration(seconds: 2),
                  action: SnackBarAction(label: 'Undo', onPressed: (){cart.removeSingleItem(product.id);}),
                ));
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

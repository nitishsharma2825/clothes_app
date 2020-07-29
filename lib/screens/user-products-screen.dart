import 'package:clothshopapp/widgets/app_drawer.dart';
import 'package:clothshopapp/widgets/user_product_item.dart';
import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products_provider.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchItems(true);
  }

  @override
  Widget build(BuildContext context) {
    //final product = Provider.of<Products>(context); //creates an infinite loop
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed('/edit-products-screen');
              })
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () {
                      return _refreshProducts(context);
                    },
                    child: Consumer<Products>(
                      builder: (context,product,_)=> Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (context, index) => UserProductItem(
                            id: product.items[index].id,
                            title: product.items[index].title,
                            imageUrl: product.items[index].imageUrl,
                          ),
                          itemCount: product.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

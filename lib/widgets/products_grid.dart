import 'package:clothshopapp/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_item.dart';
import '../providers/product.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFav;
  const ProductsGrid({
    this.showFav,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData=Provider.of<Products>(context);
    final products=showFav==true?productsData.favItems:productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value:products[index],
        child: ProductItem(
//          title: products[index].title,
//          id: products[index].id,
//          imageUrl: products[index].imageUrl,
        ),
      ),
      itemCount: products.length,
    );
  }
}
import 'package:clothshopapp/providers/orders.dart';
import 'package:clothshopapp/widgets/app_drawer.dart';
import 'package:clothshopapp/widgets/order_item.dart' as ord;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: Provider.of<Orders>(context, listen: false).fetchOrders(),
            builder: (context, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Consumer<Orders>(
                  builder: (context,orderData,child)=>ListView.builder(
                    itemBuilder: (context, index) =>
                        ord.OrderItem(
                          order: orderData.orders[index],
                        ),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
        )
    );
  }
}

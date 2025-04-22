import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/widgets/product_card.dart';

import '../../providers/product_provider.dart';

class ProductListScreen extends StatelessWidget{

  const ProductListScreen ({super.key});

  @override
  Widget build(BuildContext context) {

    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: Text("All Products"),

      ),
      body: GridView.builder(
         padding: const EdgeInsets.all(16),
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context,index){
           final product = products[index];
            return GestureDetector(
              onTap: (){
                context.push('/product-detail',extra:product);
              },
              child: ProductCard(product: product),
            );
         }
      ),
    );
  }

}
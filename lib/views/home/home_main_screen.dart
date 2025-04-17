import 'package:flutter/material.dart';
import 'package:stylerstack/widgets/category_list_wiget.dart';
import 'package:stylerstack/widgets/search_bar_widget.dart';

import '../../widgets/flash_sale_grid_widget.dart';
class  HomeMainScreen extends StatelessWidget{
  const HomeMainScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              SearchBarWidget(),
              SizedBox(height: 25),

              // Banner
          Container(
          height: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
          color: Color(0xFFDCC6B0),
          image: DecorationImage(
            image: AssetImage("assets/images/banner.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("New Collection\nDiscount 50%",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
      SizedBox(height: 20),

      Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E), // Deep Navy Blue
                ),
              ),
              SizedBox(height: 10),
              CategoryListWidget(),
              SizedBox(height: 25),
              Text(
                'Flash Sale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E), // Deep Navy Blue
                ),
              ),
              SizedBox(height: 10),
              FlashSaleGridWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
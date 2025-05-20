import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/widgets/category_list_wiget.dart';
import 'package:stylerstack/widgets/search_bar_widget.dart';
import 'package:stylerstack/widgets/flash_sale_grid_widget.dart';
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'New York, USA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                  Icon(Icons.notifications),
                ],
              ),

              const SizedBox(height: 10),
              const SearchBarWidget(),
              const SizedBox(height: 25),

              // Banner
          Container(
          height: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFDCC6B0),
          image: const DecorationImage(
            image: AssetImage("assets/images/banner.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: const Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("New Collection\nDiscount 50%",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          TextButton(
              onPressed: () {
                context.go('/products');
                },
            child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF795548), // Deep Navy Blue
            ),
          ),
          ),
        ],
      ),
              const SizedBox(height: 10),
              const CategoryListWidget(),
              const SizedBox(height: 25),
              const Text(
                'Flash Sale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548), // Deep Navy Blue
                ),
              ),
              const SizedBox(height: 10),
              const FlashSaleGridWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
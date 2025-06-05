import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/widgets/category_list_wiget.dart';
import 'package:stylerstack/widgets/search_bar/search_bar_widget.dart';
import 'package:stylerstack/widgets/flash_sale_grid_widget.dart';
import '../../widgets/location_card.dart';

class HomeMainScreen extends StatelessWidget {
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
              // Location Section
              const LocationCard(),

              const SizedBox(height: 20),
              const SearchBarWidget(),

              const SizedBox(height: 25),
              // Banner Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFDCC6B0),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/banner.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "New Collection",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Discount 50% On \n All new Products",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () => context.go('/products'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shadowColor: Colors.transparent,
                            backgroundColor: AppColors.background,
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Shop Now'),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/products'),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF795548),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const CategoryListWidget(),
              const SizedBox(height: 25),

              // Flash Sale Section
              const Text(
                'Flash Sale',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548),
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

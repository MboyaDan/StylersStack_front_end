import 'package:flutter/material.dart';

class FlashSaleGridWidget extends StatelessWidget {
  const FlashSaleGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate:
      SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 80),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Item ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("KES 1200", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stylerstack/models/category_type.dart';
import 'package:stylerstack/utils/constants.dart';

class SearchBarInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final CategoryType? selectedCategory;
  final VoidCallback onClearCategory;
  final bool isEnabled;

  const SearchBarInput({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.selectedCategory,
    required this.onClearCategory,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products…',
                  prefixIcon: const Icon(Icons.search, color: Colors.brown),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clear(),
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.brown.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.brown.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide(color: Colors.brown, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: IconButton(
                icon:  Icon(Icons.filter_list, color: AppColors.primary(context)),
                onPressed: onFilterTap,
              ),
            ),
            if (selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Chip(
                  label: Text(selectedCategory!.label),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: onClearCategory,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

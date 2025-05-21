import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stylerstack/models/category_type.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/services/connectivity_service.dart';
import 'package:stylerstack/widgets/search_bar/connectivity_banner.dart';
import 'package:stylerstack/widgets/search_bar/search_bar_input.dart';
import 'package:stylerstack/widgets/search_bar/search_suggestions.dart';

class SearchBarWidget extends StatefulWidget {
  final CategoryType? initialCategory;
  const SearchBarWidget({super.key, this.initialCategory});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final _searchSubject = BehaviorSubject<String>.seeded('');
  final _categorySubject = BehaviorSubject<CategoryType?>();

  late final Stream<List<String>> _suggestionsStream;
  late final ProductProvider productProvider;

  @override
  void initState() {
    super.initState();
    productProvider = context.read<ProductProvider>();

    _categorySubject.add(widget.initialCategory ?? productProvider.selectedCategory);

    _suggestionsStream = Rx.combineLatest2<String, CategoryType?, void>(
      _searchSubject.debounceTime(const Duration(milliseconds: 400)).distinct(),
      _categorySubject.distinct(),
          (query, category) {
        productProvider.searchWithCategory(query: query, category: category);
      },
    ).switchMap((_) => productProvider.searchedProductsStream.map(
          (products) => products.map((p) => p.name).toSet().take(5).toList(),
    ));

    _controller.addListener(() {
      final text = _controller.text.trim();
      if (_searchSubject.value != text) _searchSubject.add(text);
    });
  }

  @override
  Future<void> dispose() async {
    _controller.dispose();
    await _searchSubject.close();
    await _categorySubject.close();
    super.dispose();
  }

  Future<void> _openCategorySheet() async {
    final selected = await showModalBottomSheet<CategoryType?>(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('All Categories'),
            onTap: () => Navigator.pop(context, null),
          ),
          ...CategoryType.values.map(
                (cat) => ListTile(
              title: Text(cat.label),
              onTap: () => Navigator.pop(context, cat),
            ),
          ),
        ],
      ),
    );

    if (selected != _categorySubject.valueOrNull) {
      _categorySubject.add(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = context.watch<ConnectivityService>();

    return StreamBuilder<bool>(
      stream: connectivityService.internetStatusStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isConnected)
              ConnectivityBanner(
                onRetry: () async {
                  final status = await connectivityService.internetStatusStream.first;
                  if (!status) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Still offline')),
                    );
                  }
                },
              ),
            const SizedBox(height: 10),
            StreamBuilder<CategoryType?>(
              stream: _categorySubject,
              builder: (context, snap) {
                final cat = snap.data;
                return SearchBarInput(
                  controller: _controller,
                  selectedCategory: cat,
                  isEnabled: isConnected,
                  onFilterTap: _openCategorySheet,
                  onClearCategory: () => _categorySubject.add(null),
                );
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<String>>(
              stream: _suggestionsStream,
              builder: (context, snapshot) {
                return SearchSuggestions(
                  isLoading: snapshot.connectionState == ConnectionState.waiting,
                  suggestions: snapshot.data ?? [],
                  onSuggestionTap: (s) {
                    _controller.text = s;
                    _searchSubject.add(s);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

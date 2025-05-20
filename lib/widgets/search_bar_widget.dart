import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../providers/product_provider.dart';
import '../models/category_type.dart';
import '../services/connectivity_service.dart';

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

  StreamSubscription<bool>? _internetSub;
  bool? _lastInternetStatus;

  @override
  void initState() {
    super.initState();
    productProvider = context.read<ProductProvider>();

    final initialCat =
        widget.initialCategory ?? productProvider.selectedCategory;
    _categorySubject.add(initialCat);

    // search + category => query stream
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

    // snackbar for connectivity
    final connectivityService = context.read<ConnectivityService>();
    _internetSub = connectivityService.internetStatusStream.listen((hasNet) {
      if (_lastInternetStatus != hasNet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasNet
                ? 'Internet connected'
                : 'Internet lost. Some features may not work.',),
            backgroundColor: hasNet ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        _lastInternetStatus = hasNet;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchSubject.close();
    _categorySubject.close();
    _internetSub?.cancel();
    super.dispose();
  }

  /// Opens bottom-sheet, returns selected (or null for “All”)
  Future<void> _openCategorySheet() async {
    final selected = await showModalBottomSheet<CategoryType?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('All Categories'),
            leading: const Icon(Icons.layers_clear),
            onTap: () => Navigator.pop(context, null),
          ),
          ...CategoryType.values.map(
                (cat) => ListTile(
              title: Text(cat.label),
              leading: const Icon(Icons.label_outline),
              onTap: () => Navigator.pop(context, cat),
            ),
          ),
        ],
      ),
    );

    // update only if changed
    if (selected != _categorySubject.valueOrNull) {
      _categorySubject.add(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = context.watch<ConnectivityService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// === SEARCH BAR + FILTER + CATEGORY CHIP ===
        Row(
          children: [
            // search box
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search products…',
                  prefixIcon: const Icon(Icons.search, color: Colors.brown),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _searchSubject.add('');
                    },
                  )
                      : null,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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

            // filter button
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.brown),
                onPressed: _openCategorySheet,
              ),
            ),

            // selected category chip
            StreamBuilder<CategoryType?>(
              stream: _categorySubject,
              builder: (context, snapshot) {
                final cat = snapshot.data;
                if (cat == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Chip(
                    label: Text(cat.label),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _categorySubject.add(null),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// === SEARCH SUGGESTIONS (only if online) ===
        StreamBuilder<bool>(
          stream: connectivityService.internetStatusStream,
          builder: (context, snap) {
            final hasInternet = snap.data ?? false;
            if (!hasInternet) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'No internet connection. Try again later.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            return StreamBuilder<List<String>>(
              stream: _suggestionsStream,
              builder: (context, snap2) {
                if (!snap2.hasData || snap2.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final suggestions = snap2.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (_, i) {
                    final s = suggestions[i];
                    return ListTile(
                      title: Text(s),
                      onTap: () {
                        _controller.text = s;
                        _searchSubject.add(s);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

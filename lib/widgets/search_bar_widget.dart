import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/models/category_type.dart';
import 'package:stylerstack/services/connectivity_service.dart';

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

    // Optional: initial snackBar for transition feedback
    final connectivityService = context.read<ConnectivityService>();
    _internetSub = connectivityService.internetStatusStream.listen((hasNet) {
      if (_lastInternetStatus != hasNet) {
        setState(() {});
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
            /// Fixed top banner
            if (!isConnected)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'No internet connection',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () async {
                        final status = await connectivityService.internetStatusStream.first;
                        if (!status) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Still offline')),
                          );
                        }
                      },
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            /// === SEARCH BAR + FILTER + CATEGORY CHIP ===
            Opacity(
              opacity: isConnected ? 1 : 0.5,
              child: IgnorePointer(
                ignoring: !isConnected,
                child: Row(
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
              ),
            ),

            const SizedBox(height: 10),

            /// === SEARCH SUGGESTIONS ===
            isConnected
                ? StreamBuilder<List<String>>(
              stream: _suggestionsStream,
              builder: (context, snap2) {
                if (snap2.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
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
            )
                : const SizedBox.shrink(),

            // OPTIONAL: Floating dot for global status (enable if desired)
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 4.0, right: 8.0),
            //     child: CircleAvatar(
            //       radius: 6,
            //       backgroundColor: isConnected ? Colors.green : Colors.red,
            //     ),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}

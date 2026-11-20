import 'package:material_ui/material_ui.dart';

import 'pagination_bar.dart';

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String itemLabel;
  final String emptyMessage;
  final Widget? header;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;
  final Widget Function(int index)? separatorBuilder;
  final Object? resetToken;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemLabel,
    required this.emptyMessage,
    this.header,
    this.padding = const EdgeInsets.all(16),
    this.onRefresh,
    this.separatorBuilder,
    this.resetToken,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  int _page = 0;
  int _pageSize = 10;

  @override
  void didUpdateWidget(covariant PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      _page = 0;
      return;
    }
    final pages = widget.items.isEmpty ? 1 : (widget.items.length / _pageSize).ceil();
    if (_page >= pages) setState(() => _page = pages - 1);
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.items.isEmpty ? 1 : (widget.items.length / _pageSize).ceil();
    final page = _page.clamp(0, pages - 1);
    final visible = pageItems(widget.items, page, _pageSize);
    final list = visible.isEmpty
        ? ListView(
            padding: widget.padding,
            children: [const SizedBox(height: 96), Center(child: Text(widget.emptyMessage))],
          )
        : ListView.separated(
            padding: widget.padding,
            itemCount: visible.length,
            separatorBuilder: (context, index) =>
                widget.separatorBuilder?.call(index) ?? const SizedBox(height: 8),
            itemBuilder: (context, index) => widget.itemBuilder(context, visible[index]),
          );
    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: widget.onRefresh == null
              ? list
              : RefreshIndicator(onRefresh: widget.onRefresh!, child: list),
        ),
        PaginationBar(
          page: page,
          pageSize: _pageSize,
          total: widget.items.length,
          itemLabel: widget.itemLabel,
          onPageChanged: (value) => setState(() => _page = value),
          onPageSizeChanged: (value) => setState(() {
            _pageSize = value;
            _page = 0;
          }),
        ),
      ],
    );
  }
}

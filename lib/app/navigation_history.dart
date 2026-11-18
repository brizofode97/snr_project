class NavigationHistory {
  final List<String> _paths = <String>['/home'];

  bool get canGoBack => _paths.length > 1;

  void push(String path) {
    if (_paths.last == path) return;
    _paths.add(path);
  }

  String? pop() => canGoBack ? _paths.removeLast() : null;

  void reset([String path = '/home']) {
    _paths
      ..clear()
      ..add(path);
  }
}

final NavigationHistory navigationHistory = NavigationHistory();

import 'dart:async';

/// Stub AppLinks for OronBox-Lite.
/// Replaces the removed package:app_links dependency with a no-op stub.

class AppLinks {
  final Stream<Uri> _uriLinkStream = const Stream.empty();

  Stream<Uri> get uriLinkStream => _uriLinkStream;

  Future<String?> getInitialLinkString() async => null;
}

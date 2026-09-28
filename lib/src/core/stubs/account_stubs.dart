import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub account types for OronBox-Lite.
/// Replaces the deleted features/accounts/ module with minimal compilable stubs.

class BandBbsAccountState {
  const BandBbsAccountState({this.userId, this.isSignedIn = false});
  final String? userId;
  final bool isSignedIn;
}

class XiaomiAccountState {
  const XiaomiAccountState();
}

class AmazfitAccountState {
  const AmazfitAccountState();
}

class HostAccountsState {
  const HostAccountsState({
    this.bandbbs = const BandBbsAccountState(),
    this.xiaomi = const XiaomiAccountState(),
    this.amazfit = const AmazfitAccountState(),
    this.noticeRevision = 0,
    this.noticeCode,
  });

  final BandBbsAccountState bandbbs;
  final XiaomiAccountState xiaomi;
  final AmazfitAccountState amazfit;
  final int noticeRevision;
  final String? noticeCode;
}

class HostAccountsNotifier extends Notifier<HostAccountsState> {
  @override
  HostAccountsState build() => const HostAccountsState();

  Future<void> startBandBbsLogin() async {}
  Future<bool> handleBandBbsCallback(Uri uri) async => false;
  Future<void> signOutBandBbs() async {}
  Future<void> signInWithXiaomiCookie(String cookie) async {}
  Future<void> signInWithAmazfitToken(String token) async {}
  Future<void> signOutXiaomi() async {}
  Future<void> signOutAmazfit() async {}
}

final hostAccountsProvider =
    NotifierProvider<HostAccountsNotifier, HostAccountsState>(
  HostAccountsNotifier.new,
);

/// Stub for HostTwoFactorRequired exception from deleted accounts module.
class HostTwoFactorRequired implements Exception {
  const HostTwoFactorRequired({this.message});
  final String? message;
  @override
  String toString() => message ?? 'HostTwoFactorRequired';
}

/// Stub for createMiAccountTwoFactorResolver from deleted accounts module.
Future<String> Function()? createMiAccountTwoFactorResolver() {
  return null;
}

/// Stub creator workspace provider.
class CreatorWorkspaceState {
  const CreatorWorkspaceState();
}

class CreatorWorkspaceNotifier extends Notifier<CreatorWorkspaceState> {
  @override
  CreatorWorkspaceState build() => const CreatorWorkspaceState();
  Future<void> refresh() async {}
}

final creatorWorkspaceProvider =
    NotifierProvider<CreatorWorkspaceNotifier, CreatorWorkspaceState>(
  CreatorWorkspaceNotifier.new,
);

/// Stub showCreatorFailure function.
void showCreatorFailure(BuildContext context, Object error) {}

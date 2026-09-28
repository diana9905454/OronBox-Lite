import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oronbox_lite/src/core/command_bus.dart';

/// Stub daemon types for OronBox-Lite.
/// Replaces the deleted daemon/ module with minimal compilable stubs.

class DaemonTask {
  const DaemonTask({required this.command, this.id = ''});

  final OronBoxCommand command;
  final String id;

  Map<String, Object?> toJson() => {'id': id, 'command': command.toJson()};
}

class DaemonTaskQueue {
  DaemonTaskQueue(
    Object core, {
    Future<void> Function()? onCancelRunning,
    Future<Future<void> Function()> Function(DaemonTask)? beginExecution,
    Future<bool> Function(DaemonTask, CommandResult)? shouldRemoveCompleted,
  });

  Stream<CommandEvent> get events => const Stream.empty();
  String enqueue(OronBoxCommand command, {bool held = false}) => '';
  List<Map<String, Object?>> list() => [];
  DaemonTask? get(String id) => null;
  Future<DaemonTask?> wait(String id) async => null;
  bool cancel(String id) => false;
  void clear() {}
  int startHeld() => 0;
  int holdPending() => 0;
  bool retry(String id) => false;
  bool remove(String id) => false;
  Future<void> close() async {}
}

/// Stub for the deleted daemon client.
class OronBoxDaemonClient implements OronBoxCommandBus {
  OronBoxDaemonClient._();

  static Future<OronBoxDaemonClient> connect({
    Duration? timeout,
  }) async =>
      OronBoxDaemonClient._();

  @override
  Stream<CommandEvent> get events => const Stream.empty();

  @override
  Future<CommandResult> execute(OronBoxCommand command) async =>
      const CommandResult.failure(
        CommandError('daemon_unavailable', 'Daemon is not available in lite mode'),
      );

  @override
  Future<void> close() async {}
}

/// Stub for the deleted LocalCommandBus.
class LocalCommandBus implements OronBoxCommandBus {
  LocalCommandBus(ProviderContainer container);

  @override
  Stream<CommandEvent> get events => const Stream.empty();

  @override
  Future<CommandResult> execute(OronBoxCommand command) async =>
      const CommandResult.failure(
        CommandError('local_bus_unavailable', 'Local command bus is not available in lite mode'),
      );

  @override
  Future<void> close() async {}
}

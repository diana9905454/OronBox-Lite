import 'dart:async';

/// Stub command bus types for OronBox-Lite.
/// Replaces the deleted command_bus/ module with minimal compilable stubs.

class OronBoxCommand {
  const OronBoxCommand({required this.method, this.params = const {}});

  final String method;
  final Map<String, Object?> params;

  factory OronBoxCommand.fromJson(Map<String, Object?> json) {
    return OronBoxCommand(
      method: json['method'] as String? ?? '',
      params: (json['params'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }

  Map<String, Object?> toJson() => {'method': method, 'params': params};
}

class CommandError {
  const CommandError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'CommandError($code: $message)';
}

class CommandResult {
  const CommandResult._({this.ok = false, this.value, this.error});

  const CommandResult.success([this.value])
      : ok = true,
        error = null;

  const CommandResult.failure(CommandError this.error)
      : ok = false,
        value = null;

  final bool ok;
  final Object? value;
  final CommandError? error;
}

class CommandEvent {
  const CommandEvent(this.event, [this.data]);

  final String event;
  final Object? data;
}

abstract class OronBoxCommandBus {
  Stream<CommandEvent> get events;
  Future<CommandResult> execute(OronBoxCommand command);
  Future<void> close();
}

bool isObservableCommand(String method) {
  return !method.startsWith('debug.');
}

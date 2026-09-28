import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub resource queue types for OronBox-Lite.
/// Replaces the deleted features/resources/ module with minimal compilable stubs.

enum ResourceTaskStatus { pending, downloading, installing, completed, failed }

class ResourceTask {
  const ResourceTask({
    this.status = ResourceTaskStatus.completed,
    this.progress = 0,
    this.title = '',
  });

  final ResourceTaskStatus status;
  final double progress;
  final String title;
}

class InstallTask {
  const InstallTask({
    this.status = ResourceTaskStatus.completed,
    this.progress = 0,
    this.name = '',
  });

  final ResourceTaskStatus status;
  final double progress;
  final String name;
}

class InstallQueueState {
  const InstallQueueState({this.tasks = const []});
  final List<InstallTask> tasks;
}

/// Stub download queue notifier that accepts enqueue calls as no-ops.
class DownloadQueueNotifier extends Notifier<List<ResourceTask>> {
  @override
  List<ResourceTask> build() => [];

  void enqueue({
    required Object resource,
    required Object file,
    required String codename,
  }) {}
}

/// Stub install queue notifier.
class InstallQueueNotifier extends Notifier<InstallQueueState> {
  @override
  InstallQueueState build() => const InstallQueueState();
}

/// Stub providers that always return empty queues.
final downloadQueueProvider =
    NotifierProvider<DownloadQueueNotifier, List<ResourceTask>>(
  DownloadQueueNotifier.new,
);

final installQueueProvider =
    NotifierProvider<InstallQueueNotifier, InstallQueueState>(
  InstallQueueNotifier.new,
);

/// Stub for confirmAndEnqueueResourceFile from deleted resources module.
/// Returns false (nothing enqueued) to indicate the operation was a no-op.
Future<bool> confirmAndEnqueueResourceFile({
  required BuildContext context,
  required WidgetRef ref,
  required Object file,
  Object? selectedType,
}) async => false;

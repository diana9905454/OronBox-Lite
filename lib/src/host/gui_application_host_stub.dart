import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oronbox_lite/src/core/command_bus.dart';
import 'package:oronbox_lite/src/core/stubs/daemon_stubs.dart';
import 'package:oronbox_lite/src/host/application_host.dart';

OronBoxCommandBus createGuiApplicationHost() {
  final container = ProviderContainer();
  return ApplicationHost(
    LocalCommandBus(container),
    onClose: container.dispose,
  );
}

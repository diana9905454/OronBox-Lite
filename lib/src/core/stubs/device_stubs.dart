/// Device-related stubs for OronBox-Lite.
/// Replaces types from deleted modules (accounts, etc.).

/// Stub for MiCloudDevice (was in deleted accounts module).
class MiCloudDevice {
  const MiCloudDevice({
    required this.name,
    required this.model,
    required this.mac,
  });

  final String name;
  final String model;
  final String mac;
}

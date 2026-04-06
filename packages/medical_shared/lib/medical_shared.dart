/// Shared library for Medical Appointments (upstream: `medical-app/packages/medical_shared`).
///
/// Move cross-app code here via PRs on `medical-app`, then merge into V2 and depend on this package.
library medical_shared;

export 'card_validators.dart';
export 'loading_state.dart';

/// Package version (bump when adding breaking shared APIs).
const String medicalSharedPackageVersion = '0.2.0';

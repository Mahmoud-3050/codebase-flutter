import 'package:flutter/foundation.dart';

import '../domain/enums/social_provider.dart';

/// Presentation-only FR-029 helper. Domain [SocialProvider] has no platform API.
abstract final class SocialProviderAvailability {
  static bool isOffered(SocialProvider provider, {TargetPlatform? platform}) {
    final TargetPlatform resolved = platform ?? defaultTargetPlatform;
    return switch (provider) {
      SocialProvider.google => true,
      SocialProvider.apple =>
        resolved == TargetPlatform.iOS || resolved == TargetPlatform.macOS,
    };
  }
}

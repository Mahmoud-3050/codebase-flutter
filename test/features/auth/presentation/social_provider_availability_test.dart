import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/domain/enums/social_provider.dart';
import 'package:codebase/features/auth/presentation/social_provider_availability.dart';

void main() {
  test('FR-029 Google is always offered', () {
    expect(
      SocialProviderAvailability.isOffered(
        SocialProvider.google,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
  });

  test('FR-029 Apple is offered on iOS and hidden on Android', () {
    expect(
      SocialProviderAvailability.isOffered(
        SocialProvider.apple,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      SocialProviderAvailability.isOffered(
        SocialProvider.apple,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });
}

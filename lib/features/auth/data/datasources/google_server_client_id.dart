/// OAuth web client id required by `google_sign_in` 7.x on Android.
///
/// Pass it at build or run time:
/// `--dart-define=GOOGLE_SERVER_CLIENT_ID=your-web-client-id`
const String googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
);

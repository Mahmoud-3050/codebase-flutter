// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  // Future<bool> get isConnected async => await InternetConnection().hasInternetAccess;
  Future<bool> get isConnected async => true;
}

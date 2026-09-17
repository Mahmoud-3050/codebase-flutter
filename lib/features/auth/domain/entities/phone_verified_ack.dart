import 'package:equatable/equatable.dart';

/// Empty success payload for phone verification during social completion (FR-033).
final class PhoneVerifiedAck extends Equatable {
  const PhoneVerifiedAck();

  @override
  List<Object?> get props => const <Object?>[];
}

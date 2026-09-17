import '../../../../core/utils/enums.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/registration_draft.dart';

abstract class AuthLocalDataSource {
  Future<void> persistSession(AuthSession session);
  Future<void> clearSession();
  Future<void> markGuest();
  Future<UserType> readVisitorState();
  Future<void> saveRegistrationDraft(RegistrationDraft draft);
  Future<RegistrationDraft?> readRegistrationDraft();
  Future<void> clearRegistrationDraft();
}

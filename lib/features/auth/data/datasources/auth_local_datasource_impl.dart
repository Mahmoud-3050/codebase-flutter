import '../../../../config/language/strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_storage/interfaces/local_storage_interface.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/registration_draft.dart';
import '../models/registration_draft_model.dart';
import 'auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required this.accessTokenStorage,
    required this.userTypeStorage,
    required this.registrationDraftStorage,
  });

  final LocalStorageInterface accessTokenStorage;
  final LocalStorageInterface userTypeStorage;
  final LocalStorageInterface registrationDraftStorage;

  @override
  Future<void> persistSession(AuthSession session) async {
    final bool tokenSaved = await accessTokenStorage.save(
      value: session.accessToken,
    );
    final bool typeSaved = await userTypeStorage.save(
      value: UserType.loggedIn.name,
    );
    await registrationDraftStorage.remove();
    if (!tokenSaved || !typeSaved) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
  }

  @override
  Future<void> clearSession() async {
    await accessTokenStorage.remove();
    final bool typeSaved = await userTypeStorage.save(
      value: UserType.guest.name,
    );
    if (!typeSaved) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
  }

  @override
  Future<void> markGuest() async {
    final bool typeSaved = await userTypeStorage.save(
      value: UserType.guest.name,
    );
    if (!typeSaved) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
  }

  @override
  Future<UserType> readVisitorState() async {
    final String? raw = await userTypeStorage.read();
    if (raw == null || raw.isEmpty) {
      return UserType.firstOpen;
    }
    if (raw == UserType.firstOpen.name) {
      return UserType.firstOpen;
    }
    if (raw == UserType.guest.name) {
      return UserType.guest;
    }
    if (raw == UserType.loggedIn.name) {
      final String? token = await accessTokenStorage.read();
      if (token == null || token.isEmpty) {
        return UserType.firstOpen;
      }
      return UserType.loggedIn;
    }
    return UserType.firstOpen;
  }

  @override
  Future<void> saveRegistrationDraft(RegistrationDraft draft) async {
    final bool saved = await registrationDraftStorage.save(
      value: RegistrationDraftModel.fromEntity(draft).encode(),
    );
    if (!saved) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
  }

  @override
  Future<RegistrationDraft?> readRegistrationDraft() async {
    final String? raw = await registrationDraftStorage.read();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return RegistrationDraftModel.decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearRegistrationDraft() async {
    await registrationDraftStorage.remove();
  }
}

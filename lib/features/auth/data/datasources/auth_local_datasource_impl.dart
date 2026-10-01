import '../../../../config/language/strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/local_storage/interfaces/local_storage_interface.dart';
import '../../../../core/services/session_write_guard.dart';
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
    this.sessionWriteGuard = const IdleSessionWriteGuard(),
  });

  final LocalStorageInterface accessTokenStorage;
  final LocalStorageInterface userTypeStorage;
  final LocalStorageInterface registrationDraftStorage;
  final SessionWriteGuard sessionWriteGuard;

  @override
  Future<void> persistSession(AuthSession session) async {
    if (session.accessToken.isEmpty) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
    return sessionWriteGuard.guardSessionWrite(() async {
      final bool tokenSaved = await accessTokenStorage.save(
        value: session.accessToken,
      );
      if (!tokenSaved) {
        throw CacheException(message: Strings.pleaseTryAgainLater);
      }
      final bool typeSaved = await userTypeStorage.save(
        value: UserType.loggedIn.name,
      );
      if (!typeSaved) {
        final bool removed = await accessTokenStorage.remove();
        if (!removed) {
          throw CacheException(message: Strings.pleaseTryAgainLater);
        }
        throw CacheException(message: Strings.pleaseTryAgainLater);
      }
      await registrationDraftStorage.remove();
    });
  }

  @override
  Future<void> clearSession() async {
    await sessionWriteGuard.guardSessionWrite(() async {
      final String? previousToken = await accessTokenStorage.read();
      final String? previousType = await userTypeStorage.read();
      final bool typeSaved = await userTypeStorage.save(
        value: UserType.guest.name,
      );
      if (!typeSaved) {
        throw CacheException(message: Strings.pleaseTryAgainLater);
      }
      final bool tokenRemoved = await accessTokenStorage.remove();
      if (!tokenRemoved) {
        await _restoreOrFinishSignOut(token: previousToken, type: previousType);
        return;
      }
      final bool draftRemoved = await registrationDraftStorage.remove();
      if (!draftRemoved) {
        await _restoreOrFinishSignOut(token: previousToken, type: previousType);
      }
    });
  }

  @override
  Future<void> markGuest() async {
    await sessionWriteGuard.guardSessionWrite(() async {
      final String? previousToken = await accessTokenStorage.read();
      final String? previousType = await userTypeStorage.read();
      final bool typeSaved = await userTypeStorage.save(
        value: UserType.guest.name,
      );
      if (!typeSaved) {
        throw CacheException(message: Strings.pleaseTryAgainLater);
      }
      final bool tokenRemoved = await accessTokenStorage.remove();
      if (!tokenRemoved) {
        await _restoreOrFinishSignOut(token: previousToken, type: previousType);
      }
    });
  }

  /// Restores the previous session. When a restore write fails, deletes the
  /// token so a guest flag cannot keep a bearer credential, and throws only
  /// if that token is still stored.
  Future<void> _restoreOrFinishSignOut({
    required String? token,
    required String? type,
  }) async {
    if (await _restoreSession(token: token, type: type)) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
    final bool tokenRemoved = await accessTokenStorage.remove();
    if (!tokenRemoved) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
  }

  Future<bool> _restoreSession({
    required String? token,
    required String? type,
  }) async {
    if (token != null && token.isNotEmpty) {
      final bool tokenRestored = await accessTokenStorage.save(value: token);
      if (!tokenRestored) {
        return false;
      }
    }
    if (type != null && type.isNotEmpty) {
      final bool typeRestored = await userTypeStorage.save(value: type);
      if (!typeRestored) {
        return false;
      }
    }
    return true;
  }

  Future<void> _dropLeftoverGuestToken() async {
    if (sessionWriteGuard.isSessionWriteInProgress) {
      return;
    }
    final String? token = await accessTokenStorage.read();
    if (sessionWriteGuard.isSessionWriteInProgress ||
        token == null ||
        token.isEmpty) {
      return;
    }
    final bool removed = await accessTokenStorage.remove();
    if (!removed) {
      throw CacheException(message: Strings.pleaseTryAgainLater);
    }
  }

  @override
  Future<UserType> readVisitorState() async {
    final String? raw = await userTypeStorage.read();
    if (raw == UserType.loggedIn.name) {
      final String? token = await accessTokenStorage.read();
      if (token == null || token.isEmpty) {
        return UserType.firstOpen;
      }
      return UserType.loggedIn;
    }
    await _dropLeftoverGuestToken();
    if (raw == UserType.guest.name) {
      return UserType.guest;
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
    final String? token = await accessTokenStorage.read();
    if (token != null && token.isNotEmpty) {
      return null;
    }
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

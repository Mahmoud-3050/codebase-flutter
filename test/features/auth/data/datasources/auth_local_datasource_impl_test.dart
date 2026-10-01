import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/services/session_write_guard.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:codebase/features/auth/data/models/registration_draft_model.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';

import '../../fixtures.dart';

void main() {
  test('FR-002 missing visitor maps to firstOpen', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.firstOpen);
  });

  test('FR-002 unreadable visitor maps to firstOpen', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage('not-a-user-type'),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.firstOpen);
  });

  test('FR-004 draft-only store is not loggedIn', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(),
      registrationDraftStorage: MemoryStorage(
        RegistrationDraftModel.fromEntity(kPhoneDraft).encode(),
      ),
    );
    expect(await local.readVisitorState(), UserType.firstOpen);
  });

  test('FR-004 loggedIn without token falls back to firstOpen', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(UserType.loggedIn.name),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.firstOpen);
  });

  test(
    'FR-011 persistSession writes token and loggedIn and clears draft',
    () async {
      final MemoryStorage tokens = MemoryStorage();
      final MemoryStorage types = MemoryStorage();
      final MemoryStorage drafts = MemoryStorage('draft');
      final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
        accessTokenStorage: tokens,
        userTypeStorage: types,
        registrationDraftStorage: drafts,
      );
      await local.persistSession(kSession);
      expect(tokens.value, kAccessToken);
      expect(types.value, UserType.loggedIn.name);
      expect(drafts.value, isNull);
    },
  );

  test('FR-038 guest visitor state is persisted', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: MemoryStorage(),
      registrationDraftStorage: MemoryStorage(),
    );
    await local.markGuest();
    expect(tokens.value, isNull);
    expect(await local.readVisitorState(), UserType.guest);
    expect(tokens.value, isNull);
  });

  test(
    'FR-038 markGuest keeps the previous type when token removal fails',
    () async {
      final MemoryStorage tokens = MemoryStorage(kAccessToken)
        ..failRemove = true;
      final MemoryStorage types = MemoryStorage(UserType.loggedIn.name);
      final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
        accessTokenStorage: tokens,
        userTypeStorage: types,
        registrationDraftStorage: MemoryStorage(),
      );
      await expectLater(local.markGuest(), throwsA(isA<CacheException>()));
      expect(tokens.value, kAccessToken);
      expect(types.value, UserType.loggedIn.name);
    },
  );

  test('FR-038 reading a guest drops a leftover access token', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: MemoryStorage(UserType.guest.name),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.guest);
    expect(tokens.value, isNull);
  });

  test('FR-038 a failed leftover-token delete throws', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken)..failRemove = true;
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: MemoryStorage(UserType.guest.name),
      registrationDraftStorage: MemoryStorage(),
    );
    await expectLater(local.readVisitorState(), throwsA(isA<CacheException>()));
    expect(tokens.value, kAccessToken);
  });

  test('FR-038 a guest read during a session write keeps the token', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: MemoryStorage(UserType.guest.name),
      registrationDraftStorage: MemoryStorage(),
      sessionWriteGuard: const _HoldingSessionWriteGuard(),
    );
    expect(await local.readVisitorState(), UserType.guest);
    expect(tokens.value, kAccessToken);
  });

  test('FR-042 loggedIn with token stays loggedIn', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(kAccessToken),
      userTypeStorage: MemoryStorage(UserType.loggedIn.name),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.loggedIn);
  });

  test('FR-002 a first open drops a leftover access token', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: MemoryStorage(UserType.firstOpen.name),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.firstOpen);
    expect(tokens.value, isNull);
  });

  test('FR-002 firstOpen visitor name maps to firstOpen', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(UserType.firstOpen.name),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.firstOpen);
  });

  test('FR-011 persistSession throws when save fails', () async {
    final MemoryStorage tokens = MemoryStorage();
    final MemoryStorage types = MemoryStorage()..failSave = true;
    final MemoryStorage drafts = MemoryStorage(
      RegistrationDraftModel.fromEntity(kPhoneDraft).encode(),
    );
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: types,
      registrationDraftStorage: drafts,
    );
    await expectLater(
      local.persistSession(kSession),
      throwsA(isA<CacheException>()),
    );
    expect(tokens.value, isNull);
    expect(drafts.value, isNotNull);
    expect(
      (await local.readRegistrationDraft())?.registrationToken,
      kPhoneDraft.registrationToken,
    );
  });

  test(
    'FR-026 persistSession keeps the session when draft delete fails',
    () async {
      final MemoryStorage tokens = MemoryStorage();
      final MemoryStorage types = MemoryStorage();
      final MemoryStorage drafts = MemoryStorage(
        RegistrationDraftModel.fromEntity(kPhoneDraft).encode(),
      )..failRemove = true;
      final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
        accessTokenStorage: tokens,
        userTypeStorage: types,
        registrationDraftStorage: drafts,
      );
      await local.persistSession(kSession);
      expect(tokens.value, kAccessToken);
      expect(types.value, UserType.loggedIn.name);
      expect(await local.readRegistrationDraft(), isNull);
      drafts.failRemove = false;
      await local.clearSession();
      expect(drafts.value, isNull);
      expect(await local.readRegistrationDraft(), isNull);
    },
  );

  test(
    'FR-011 persistSession keeps the draft when the token save fails',
    () async {
      final MemoryStorage tokens = MemoryStorage()..failSave = true;
      final MemoryStorage types = MemoryStorage(UserType.firstOpen.name);
      final MemoryStorage drafts = MemoryStorage(
        RegistrationDraftModel.fromEntity(kPhoneDraft).encode(),
      );
      final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
        accessTokenStorage: tokens,
        userTypeStorage: types,
        registrationDraftStorage: drafts,
      );
      await expectLater(
        local.persistSession(kSession),
        throwsA(isA<CacheException>()),
      );
      expect(tokens.value, isNull);
      expect(types.value, UserType.firstOpen.name);
      expect(
        (await local.readRegistrationDraft())?.registrationToken,
        kPhoneDraft.registrationToken,
      );
    },
  );

  test('FR-011 persistSession rejects an empty access token', () async {
    final MemoryStorage types = MemoryStorage();
    final MemoryStorage drafts = MemoryStorage(
      RegistrationDraftModel.fromEntity(kPhoneDraft).encode(),
    );
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: types,
      registrationDraftStorage: drafts,
    );
    await expectLater(
      local.persistSession(AuthSession(accessToken: '', user: kVerifiedUser)),
      throwsA(isA<CacheException>()),
    );
    expect(types.value, isNull);
    expect(
      (await local.readRegistrationDraft())?.registrationToken,
      kPhoneDraft.registrationToken,
    );
  });

  test('FR-043 clearSession writes guest and throws when save fails', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken);
    final MemoryStorage types = MemoryStorage(UserType.loggedIn.name);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: types,
      registrationDraftStorage: MemoryStorage(),
    );
    await local.clearSession();
    expect(types.value, UserType.guest.name);
    expect(tokens.value, isNull);
    types.failSave = true;
    await expectLater(local.clearSession(), throwsA(isA<CacheException>()));
    expect(tokens.value, isNull);
  });

  test(
    'FR-043 clearSession restores the session when draft removal fails',
    () async {
      final MemoryStorage tokens = MemoryStorage(kAccessToken);
      final MemoryStorage types = MemoryStorage(UserType.loggedIn.name);
      final MemoryStorage drafts = MemoryStorage(
        RegistrationDraftModel.fromEntity(kPhoneDraft).encode(),
      )..failRemove = true;
      final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
        accessTokenStorage: tokens,
        userTypeStorage: types,
        registrationDraftStorage: drafts,
      );
      await expectLater(local.clearSession(), throwsA(isA<CacheException>()));
      expect(tokens.value, kAccessToken);
      expect(types.value, UserType.loggedIn.name);
      expect(drafts.value, isNotNull);
    },
  );

  test(
    'FR-043 a failed session restore finishes sign-out when the token can be removed',
    () async {
      final MemoryStorage tokens = MemoryStorage(kAccessToken)
        ..removalsToFail = 1;
      final MemoryStorage types = MemoryStorage(UserType.loggedIn.name)
        ..savesUntilFailure = 1;
      final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
        accessTokenStorage: tokens,
        userTypeStorage: types,
        registrationDraftStorage: MemoryStorage(),
      );
      await local.clearSession();
      expect(tokens.value, isNull);
      expect(types.value, UserType.guest.name);
    },
  );

  test('FR-043 clearSession keeps loggedIn when token removal fails', () async {
    final MemoryStorage tokens = MemoryStorage(kAccessToken)..failRemove = true;
    final MemoryStorage types = MemoryStorage(UserType.loggedIn.name);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: tokens,
      userTypeStorage: types,
      registrationDraftStorage: MemoryStorage(),
    );
    await expectLater(local.clearSession(), throwsA(isA<CacheException>()));
    expect(tokens.value, kAccessToken);
    expect(types.value, UserType.loggedIn.name);
  });

  test('FR-038 markGuest throws when save fails', () async {
    final MemoryStorage types = MemoryStorage()..failSave = true;
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: types,
      registrationDraftStorage: MemoryStorage(),
    );
    await expectLater(local.markGuest(), throwsA(isA<CacheException>()));
  });

  test('FR-026 draft save read and clear', () async {
    final MemoryStorage drafts = MemoryStorage();
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(),
      registrationDraftStorage: drafts,
    );
    expect(await local.readRegistrationDraft(), isNull);
    await local.saveRegistrationDraft(kPhoneDraft);
    expect(
      (await local.readRegistrationDraft())?.registrationToken,
      kPhoneDraft.registrationToken,
    );
    drafts.value = '{not-json';
    expect(await local.readRegistrationDraft(), isNull);
    await local.clearRegistrationDraft();
    expect(drafts.value, isNull);
  });

  test('FR-026 saveRegistrationDraft throws when save fails', () async {
    final MemoryStorage drafts = MemoryStorage()..failSave = true;
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(),
      registrationDraftStorage: drafts,
    );
    await expectLater(
      local.saveRegistrationDraft(kPhoneDraft),
      throwsA(isA<CacheException>()),
    );
  });
}

final class _HoldingSessionWriteGuard implements SessionWriteGuard {
  const _HoldingSessionWriteGuard();

  @override
  bool get isSessionWriteInProgress => true;

  @override
  Future<T> guardSessionWrite<T>(Future<T> Function() action) => action();
}

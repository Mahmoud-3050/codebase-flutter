import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:codebase/features/auth/data/models/registration_draft_model.dart';

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
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: MemoryStorage(),
      registrationDraftStorage: MemoryStorage(),
    );
    await local.markGuest();
    expect(await local.readVisitorState(), UserType.guest);
  });

  test('FR-042 loggedIn with token stays loggedIn', () async {
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(kAccessToken),
      userTypeStorage: MemoryStorage(UserType.loggedIn.name),
      registrationDraftStorage: MemoryStorage(),
    );
    expect(await local.readVisitorState(), UserType.loggedIn);
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
    final MemoryStorage types = MemoryStorage()..failSave = true;
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(),
      userTypeStorage: types,
      registrationDraftStorage: MemoryStorage(),
    );
    await expectLater(
      local.persistSession(kSession),
      throwsA(isA<CacheException>()),
    );
  });

  test('FR-043 clearSession writes guest and throws when save fails', () async {
    final MemoryStorage types = MemoryStorage(UserType.loggedIn.name);
    final AuthLocalDataSourceImpl local = AuthLocalDataSourceImpl(
      accessTokenStorage: MemoryStorage(kAccessToken),
      userTypeStorage: types,
      registrationDraftStorage: MemoryStorage(),
    );
    await local.clearSession();
    expect(types.value, UserType.guest.name);
    types.failSave = true;
    await expectLater(local.clearSession(), throwsA(isA<CacheException>()));
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

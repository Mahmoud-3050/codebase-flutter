# Feature Specification: Authentication (Login, Register, Guest Mode)

**Feature Branch**: `001-auth-login-register`

**Created**: 2026-09-17

**Status**: Draft

**Input**: User description: "Create Authentication feature include Login and Register. Login types: Email and password (email otp is not verified), Phone otp (phone otp for each login) (For new user, add all register fields without phone and otp email), Google sign in, Apple sign in. Register: Avatar, Full name, email, phone, password. Email otp for register. Social login for new user, complete adding all fields without email (verify phone otp). Implement User Guest Mode. Make blank home screen for now to complete cycle."

## Clarifications

### Session 2026-09-17

- Q: Does registration create one single generic account type, or must the user choose a role (for example student versus company) that changes which fields are collected? → A: One generic account type; no role choice. The existing student/company split is example scaffolding to be refactored after auth.
- Q: When a social provider's email, or a phone number, matches an existing account created by a different method, should the system link the new method to that account, or refuse and direct the user to their original method? → A: Auto-link the new method to the existing account and sign the user in, since the provider or one-time code already proved control of that identifier.
- Q: Is forgotten-password recovery part of this feature's scope, or deferred to a separate feature? → A: In scope — request a reset code by email, verify it, then set a new password, reusing the existing code issuing, expiry, and throttling rules.
- Q: What counts as a strong enough password? → A: At least 8 characters containing at least one letter and at least one digit; no upper case, lower case, or symbol requirement.
- Q: What are the avatar image constraints? → A: JPEG and PNG only, downscaled on device to a max edge of 1024 px, rejected above 2 MB after downscaling.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create an account with email and password (Priority: P1)

A new visitor opens the app, chooses to create an account, and fills in their avatar, full name, email, phone number, and password. The system emails them a one-time code, they enter it to prove the email is theirs, and they land on the home screen already signed in.

**Why this priority**: Without account creation there are no accounts to sign in to. This is the entry point of the whole feature and the only story that produces a verified user record, so it must exist first.

**Independent Test**: Can be fully tested on its own by completing the registration form with a fresh email, entering the emailed code, and confirming the user reaches the home screen with an active session that survives an app restart. Delivers value as a standalone MVP: new users can join and stay signed in.

**Acceptance Scenarios**:

1. **Given** a visitor on the registration screen with no account, **When** they submit a valid avatar, full name, email, phone number, and password, **Then** the system creates an unverified account and sends a one-time code to the submitted email address.
2. **Given** a visitor who has just submitted registration details, **When** they enter the correct code before it expires, **Then** their email is marked verified, a signed-in session is created, and they arrive on the home screen.
3. **Given** a visitor on the code entry screen, **When** they enter an incorrect code, **Then** the system rejects it with a clear message, keeps them on the code entry screen, and does not create a session.
4. **Given** a visitor on the code entry screen whose code has expired, **When** they request a new code, **Then** a fresh code is sent, the previous code stops working, and the resend option is unavailable again until the cooldown passes.
5. **Given** a visitor submitting registration details, **When** the email is already tied to an existing account, **Then** the system explains the email is taken and offers to sign in instead, without creating a duplicate account.
6. **Given** a visitor filling the registration form, **When** any required field is empty or malformed (invalid email, weak password, invalid phone number), **Then** the system marks the specific field with a corrective message and does not submit.
7. **Given** a visitor on the registration form, **When** they choose not to add an avatar, **Then** registration still succeeds and a default avatar placeholder represents them.

---

### User Story 2 - Sign in with email and password (Priority: P2)

A returning user enters the email and password they registered with and is taken straight to the home screen. No email code is requested at sign-in time.

**Why this priority**: This is the highest-volume returning-user path and the direct payoff of Story 1, but it depends on an account already existing, so it follows registration.

**Independent Test**: Can be fully tested by signing in with a known verified account and confirming direct arrival on the home screen with no code prompt, plus rejection of a wrong password. Delivers value as returning users regaining access.

**Acceptance Scenarios**:

1. **Given** a registered user with a verified email, **When** they submit the correct email and password, **Then** they are signed in and taken to the home screen without being asked for any one-time code.
2. **Given** a registered user, **When** they submit a wrong password, **Then** the system rejects the attempt with a message that does not reveal whether the email exists, and no session is created.
3. **Given** an email address that has no account, **When** sign-in is attempted with it, **Then** the system rejects the attempt with the same non-revealing message.
4. **Given** a user whose registration was abandoned before email verification, **When** they sign in with correct credentials, **Then** the system routes them to email code entry to finish verification instead of the home screen.
5. **Given** a signed-in user, **When** they close and reopen the app, **Then** they remain signed in and go straight to the home screen without re-entering credentials.

---

### User Story 3 - Continue as a guest (Priority: P3)

A visitor who does not want to create an account yet chooses "continue as guest" and reaches the home screen immediately. They can look around, and any action that needs an identity invites them to sign in or register.

**Why this priority**: It removes the signup wall and completes the entry cycle, and it is small and self-contained. It ranks below the credentialed paths because it grants no account-bound capability.

**Independent Test**: Can be fully tested by launching a fresh install, choosing guest, confirming arrival at the home screen, confirming guest status survives an app restart, and confirming a protected action prompts sign-in. Delivers value as immediate access without commitment.

**Acceptance Scenarios**:

1. **Given** a visitor on the entry screen, **When** they choose to continue as a guest, **Then** they reach the home screen in guest state without providing any credentials.
2. **Given** a guest on the home screen, **When** they close and reopen the app, **Then** they return as a guest without being asked to choose again.
3. **Given** a guest, **When** they attempt an action that requires an identified account, **Then** the system explains an account is needed and offers sign-in and registration, without losing what they were doing where it can be preserved.
4. **Given** a guest, **When** they complete registration or sign-in, **Then** guest state is replaced by the signed-in account and guest-only limitations no longer apply.
5. **Given** a signed-in user, **When** their session ends (sign-out or an expired session that cannot be renewed), **Then** they return to guest state rather than a dead end, and the entry screen is reachable.

---

### User Story 4 - Sign in with a phone one-time code (Priority: P4)

A user enters their phone number, receives a one-time code by SMS, and enters it to sign in. A code is required on every phone sign-in; there is no phone password. If the number belongs to nobody yet, the user finishes registration right after the code is confirmed, without re-entering their phone number and without any email code.

**Why this priority**: It adds a password-free option and a second registration route. It is lower priority because the email paths already cover both new and returning users.

**Independent Test**: Can be fully tested by requesting a code for a known number and signing in, then repeating with an unused number and confirming the completion form appears pre-verified for phone and requires no email code. Delivers value as password-free access.

**Acceptance Scenarios**:

1. **Given** a visitor on the phone sign-in screen, **When** they submit a valid phone number, **Then** a one-time code is sent to that number and a code entry screen appears.
2. **Given** a phone number that belongs to an existing account, **When** the correct code is entered before expiry, **Then** the user is signed in and taken to the home screen.
3. **Given** a returning phone user who signed in yesterday, **When** they sign in again today, **Then** a new code is required again; no prior code or password shortcut is accepted.
4. **Given** a phone number with no existing account, **When** the correct code is entered, **Then** the system presents a completion form asking for avatar, full name, email, and password only, with the verified phone number already established and not editable in that form.
5. **Given** a new phone user on the completion form, **When** they submit valid details, **Then** the account is created with the phone already verified, no email code is requested, and they arrive on the home screen signed in.
6. **Given** a user on the phone code entry screen, **When** the code is wrong or expired, **Then** the attempt is rejected with a clear message and they may request a new code after the cooldown.
7. **Given** a new phone user who abandons the completion form, **When** they return and sign in with the same phone number, **Then** they are returned to the completion form rather than a partially usable account.

---

### User Story 5 - Sign in with Google (Priority: P5)

A user chooses Google sign-in and authorizes with their Google account. Returning users go straight to the home screen. New users finish registration by supplying the details Google did not provide, and verify their phone number with a one-time code; their email is taken from Google and needs no code.

**Why this priority**: It reduces signup friction but duplicates coverage the email and phone paths already provide, and depends on an external provider.

**Independent Test**: Can be fully tested by authorizing with a Google account already linked to an app account (expect the home screen) and with an unlinked one (expect the completion form with email pre-filled and a phone code step). Delivers value as one-tap access.

**Acceptance Scenarios**:

1. **Given** a visitor on the entry screen, **When** they choose Google sign-in and authorize successfully with an account already linked to an app account, **Then** they are signed in and taken to the home screen.
2. **Given** a visitor authorizing with a Google account that has no app account, **When** authorization succeeds, **Then** a completion form appears asking for avatar, full name, phone number, and password, with the email taken from Google and not editable in that form.
3. **Given** a new social user on the completion form, **When** they submit their phone number, **Then** a one-time code is sent to that number and must be entered correctly before the account is created.
4. **Given** a new social user who verified their phone code, **When** the account is created, **Then** the email from the provider is treated as verified without any email code, and they arrive on the home screen signed in.
5. **Given** a visitor starting Google sign-in, **When** they cancel the provider screen or authorization fails, **Then** they return to the entry screen with no partial account created and an option to try again.
6. **Given** a new social user who abandons the completion form, **When** they sign in again with the same provider, **Then** they resume the completion form rather than reaching the home screen.

---

### User Story 6 - Sign in with Apple (Priority: P6)

A user chooses Apple sign-in and authorizes with their Apple ID, following the same shape as Google: returning users reach the home screen, new users complete the remaining details and verify their phone with a one-time code.

**Why this priority**: It behaves like Story 5 and is required for App Store compliance once other social sign-in exists, but it reaches the smallest audience and can ship last.

**Independent Test**: Can be fully tested by authorizing with an Apple ID already linked (expect the home screen) and an unlinked one (expect the completion form plus phone code), including the case where Apple withholds the real email. Delivers value as platform-native access.

**Acceptance Scenarios**:

1. **Given** a visitor on the entry screen, **When** they choose Apple sign-in and authorize with an Apple ID already linked to an app account, **Then** they are signed in and taken to the home screen.
2. **Given** a visitor authorizing with an unlinked Apple ID that shares a real email, **When** authorization succeeds, **Then** the completion form appears with that email established and a phone code step required.
3. **Given** a visitor authorizing with an unlinked Apple ID that withholds the real email (private relay), **When** authorization succeeds, **Then** the account is still created against the relayed address and the user is never blocked from finishing registration.
4. **Given** a visitor on a platform where Apple sign-in is unavailable, **When** they view the entry screen, **Then** the Apple option is not offered and the remaining options work normally.
5. **Given** a visitor starting Apple sign-in, **When** they cancel or authorization fails, **Then** they return to the entry screen with no partial account created.

---

### Edge Cases

- **Identifier already used by another route**: someone registers with email and password, then later signs in with a social provider or phone number that resolves to the same person. The new method is linked to that account and they are signed in, with no completion form and no second account. See FR-041.
- **One-time code abuse**: repeated code requests for the same email or phone must be rate limited, and repeated wrong entries must lock further attempts for a cooldown rather than allowing unlimited guessing.
- **Code arrives late or twice**: only the most recently issued code for an identifier is valid; older codes are rejected even if they arrive after the new one.
- **Connectivity loss mid-flow**: losing network while submitting registration, requesting a code, or verifying a code must surface a retry path and must not leave the user on a blank or frozen screen.
- **Abandoned registration**: a user who verifies a code but closes the app before the account is fully created must be able to resume, and must not occupy the email or phone number in a way that permanently blocks them.
- **Avatar problems**: an image over 2 MB after downscaling, one that is neither JPEG nor PNG, or one whose upload fails must not discard the rest of the registration input; the user can retry or continue without an avatar. See FR-006a through FR-006c.
- **Phone number formatting**: the same number entered with and without country code, or with spaces and dashes, must resolve to the same account rather than creating a second one.
- **Session expiry while in use**: a session that can no longer be renewed while the user is on a screen must return them to guest state with an explanation instead of failing silently or looping.
- **Back navigation during verification**: leaving a code entry screen and returning must not strand the user in a state where no code can be requested and no form can be submitted.
- **Duplicate submissions**: double-tapping submit on registration, sign-in, or code verification must not create two accounts, two sessions, or two code requests.
- **Password reset for an unknown or code-only account**: requesting a reset for an email that has no account, or for an account that has no password because it was created through a social or phone-first path, must respond the same way as a valid request rather than revealing which case it is, and must not strand the user without a way in.
- **Guest with an expired install state**: a returning guest whose stored state is missing or unreadable must be treated as a first-time visitor rather than crashing or showing a broken screen.

## Requirements *(mandatory)*

### Functional Requirements

#### Entry and routing

- **FR-001**: The system MUST present an entry screen offering sign-in with email and password, sign-in with a phone one-time code, Google sign-in, Apple sign-in (where available), registration, and continuing as a guest.
- **FR-002**: The system MUST decide the post-launch destination from stored state: first-time visitors see the entry screen, signed-in users go to the home screen, and guests go to the home screen in guest state.
- **FR-003**: The system MUST provide a home screen that any completed authentication path and guest mode can reach, so the entry-to-home cycle is demonstrable end to end. For this feature the home screen MAY be intentionally empty of product content.
- **FR-004**: The system MUST prevent a user who has not completed an authentication path from reaching the home screen in a signed-in state.

#### Registration with email and password

- **FR-005**: Users MUST be able to register by providing full name, email address, phone number, and password, with an optional avatar image.
- **FR-006**: The system MUST treat full name, email, phone number, and password as required, and MUST treat the avatar as optional.
- **FR-006a**: The system MUST accept only JPEG and PNG avatar images, MUST downscale a chosen image on the device so its longest edge is at most 1024 pixels before uploading, and MUST reject an image still larger than 2 MB after downscaling with a message that states the limit.
- **FR-006b**: The system MUST keep every other field the user already entered when an avatar is rejected or its upload fails, and MUST let the user pick a different image or continue without one.
- **FR-006c**: The system MUST represent a user who provided no avatar, or whose avatar upload failed, with a default placeholder rather than blocking account creation.
- **FR-007**: The system MUST validate the email format, the phone number format including country code, and the password before submitting, and MUST report which field failed and why.
- **FR-007a**: The system MUST accept a password of at least 8 characters that contains at least one letter and at least one digit, and MUST reject anything shorter or missing either kind of character with a message naming the unmet rule. The system MUST NOT require upper case, lower case, or symbol characters.
- **FR-007b**: The system MUST apply the identical password rule everywhere a password is set: email-and-password registration, the phone-first completion form, the social completion form, and password reset.
- **FR-008**: The system MUST reject registration when the email already belongs to an account, and MUST offer sign-in as the next step.
- **FR-009**: The system MUST send a one-time code to the submitted email address and MUST require correct entry of that code before the account is considered verified.
- **FR-010**: The system MUST NOT require verification of the phone number during email-and-password registration; the number is collected and stored as unverified.
- **FR-011**: The system MUST establish a signed-in session and route to the home screen immediately after successful email code verification, without asking the user to sign in again.
- **FR-012**: The system MUST allow the user to request a new email code, MUST enforce a waiting period between requests, and MUST invalidate any previously issued code when a new one is issued.
- **FR-013**: The system MUST expire one-time codes after a limited validity window and MUST reject expired codes with a message that explains how to get a new one.

#### Sign-in with email and password

- **FR-014**: Users MUST be able to sign in with the email address and password from registration.
- **FR-015**: The system MUST NOT request an email one-time code during email-and-password sign-in.
- **FR-016**: The system MUST reject invalid credentials with a message that does not disclose whether the email address is registered.
- **FR-017**: The system MUST route a user with an unverified email to email code verification instead of the home screen when they sign in.
- **FR-018**: The system MUST limit consecutive failed sign-in attempts for an identifier and MUST communicate when further attempts are temporarily blocked.

#### Sign-in and registration with a phone one-time code

- **FR-019**: Users MUST be able to sign in by entering a phone number and then the one-time code sent to it, with no password involved.
- **FR-020**: The system MUST require a freshly issued one-time code on every phone sign-in, including for users who signed in by phone before.
- **FR-021**: The system MUST sign in and route to the home screen when a correct code is entered for a phone number that belongs to an existing account.
- **FR-022**: The system MUST present a completion form when a correct code is entered for a phone number with no account, collecting full name, email, and password, with an optional avatar.
- **FR-023**: The system MUST treat the phone number as verified in the phone-first registration path, MUST NOT ask the user to re-enter it, and MUST NOT allow editing it within the completion form.
- **FR-024**: The system MUST NOT send or require an email one-time code in the phone-first registration path; the email is collected as unverified.
- **FR-025**: The system MUST create the account and establish a signed-in session when the completion form is submitted successfully, then route to the home screen.
- **FR-026**: The system MUST resume the completion form for a phone number whose registration was started but not completed, rather than signing the user into an incomplete account.
- **FR-027**: The system MUST normalize equivalent phone number inputs so the same real number resolves to one account regardless of spacing, punctuation, or country-code formatting.

#### Sign-in and registration with Google and Apple

- **FR-028**: Users MUST be able to sign in with Google, and MUST be able to sign in with Apple where the platform supports it.
- **FR-029**: The system MUST hide or disable a social option on platforms where that provider is unavailable, without breaking the remaining options.
- **FR-030**: The system MUST sign in and route to the home screen when the provider account is already linked to an app account.
- **FR-031**: The system MUST present a completion form only when the provider account is neither already linked nor matched to an existing account by its email address, collecting full name, phone number, and password, with an optional avatar.
- **FR-032**: The system MUST take the email address from the provider in the social registration path, MUST NOT ask the user to enter it, and MUST NOT require an email one-time code for it.
- **FR-033**: The system MUST require verification of the phone number entered in the social completion form by sending a one-time code to it and requiring correct entry before the account is created.
- **FR-034**: The system MUST complete registration successfully when a provider withholds the user's real email address and supplies a private relay address instead.
- **FR-035**: The system MUST return the user to the entry screen with no partial account when provider authorization is cancelled or fails.
- **FR-036**: The system MUST resume the completion form for a provider account whose registration was started but not completed.

#### Guest mode

- **FR-037**: Users MUST be able to continue as a guest from the entry screen and reach the home screen without providing credentials.
- **FR-038**: The system MUST persist guest state so a returning guest is not asked to choose again on relaunch.
- **FR-039**: The system MUST prompt a guest to sign in or register when they attempt an action that requires an identified account, and MUST clearly state why.
- **FR-040**: The system MUST replace guest state with the signed-in account when a guest completes any sign-in or registration path.

#### Account identity and session lifecycle

- **FR-041**: The system MUST attach the new sign-in method to the existing account and sign the user in when an identifier from one path resolves to an account created through another path, so a single person can never end up with two accounts. This applies when a social provider supplies the email of an existing account, and when a verified phone number matches the number on an existing account.
- **FR-041a**: The system MUST mark the matched identifier as verified on the existing account when linking, since the provider or the one-time code proved the user controls it. A phone number previously stored as unverified during email-and-password registration therefore becomes verified once its owner signs in by phone code.
- **FR-041b**: The system MUST NOT present a completion form when linking resolves to an existing account; the user goes straight to the home screen because the account already holds the required fields.
- **FR-042**: The system MUST establish a persistent session on successful authentication so users stay signed in across app restarts until they sign out or the session can no longer be renewed.
- **FR-043**: Users MUST be able to sign out, which MUST clear their session and return them to guest state.
- **FR-044**: The system MUST return the user to guest state with an explanation when a session can no longer be renewed, rather than leaving them on a failing screen.
- **FR-045**: The system MUST NOT display or log passwords or one-time codes in readable form anywhere in the app or its diagnostics.
- **FR-046**: Users MUST be able to recover from a forgotten password by requesting a reset code at their email address, entering it correctly, and then setting a new password.
- **FR-046a**: The system MUST reach password recovery from the email-and-password sign-in screen, so a user who cannot sign in is never left without a next step.
- **FR-046b**: The system MUST apply the same one-time code rules to reset codes as to every other code in this feature: a limited validity window, a resend cooldown, invalidation of any earlier code, a capped number of wrong attempts, and a message that does not disclose whether the email address is registered.
- **FR-046c**: The system MUST validate the new password against the same strength rules as registration, and MUST sign the user in and route them to the home screen once the reset succeeds.
- **FR-046d**: The system MUST reject a reset code that has been used once, so a single code cannot change the password twice.
- **FR-047**: The system MUST create one single generic account type for every registration path, and MUST NOT ask the user to choose a role. Every path collects the same field set, so no registration or completion form varies by role.

#### Cross-cutting behavior

- **FR-048**: The system MUST show a clear progress state during any authentication request and MUST prevent duplicate submissions while one is in flight.
- **FR-049**: The system MUST present every authentication error as an actionable message rather than a raw technical failure, and MUST keep the user's already-entered input where it is safe to do so.
- **FR-050**: The system MUST present all authentication screens and messages in the languages the app already supports, in both reading directions.
- **FR-051**: The system MUST NOT lose an in-progress registration form when the app is briefly backgrounded and resumed.

### Key Entities

- **User Account**: A person's identity in the product. Holds full name, email address, phone number, optional avatar image, whether the email is verified, whether the phone is verified, and when the account was created.
- **Credential**: The secret a user proves themselves with for password-based paths. Belongs to exactly one account and is never readable back to anyone.
- **Social Identity**: A link between one external provider account (Google or Apple) and one User Account, including which provider it is and the email address the provider supplied. One User Account can hold several of these alongside its password and phone credentials, which is what lets a returning person reach the same account through any method.
- **One-Time Code**: A short-lived code issued to a single destination (an email address or a phone number) for a single purpose (verify email, sign in by phone, verify phone during completion, reset a forgotten password). Has an issue time, an expiry, an attempt count, and a used-or-not state; only the newest code per destination is valid.
- **Authentication Session**: Proof that a signed-in user may act as their account, persisted across app restarts, renewable, and revocable by sign-out or expiry.
- **Registration Draft**: The partially completed state of a user who verified an identifier (phone or social provider) but has not yet submitted the remaining required fields. Lets an interrupted signup resume instead of restarting or half-creating an account.
- **Visitor State**: Which of first-time visitor, guest, or signed-in user the app should treat the current person as on launch.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new user can complete registration from opening the entry screen to standing on the home screen in under 3 minutes, including receiving and entering the email code.
- **SC-002**: A returning user can sign in with email and password and reach the home screen in under 15 seconds, and with no more than 3 interactions after the entry screen.
- **SC-003**: A visitor can reach the home screen as a guest in under 5 seconds and with a single interaction from the entry screen.
- **SC-004**: 95% of one-time codes reach the user's inbox or handset within 60 seconds of being requested.
- **SC-005**: 95% of users who start any authentication path finish it on the first attempt, without needing to restart the flow.
- **SC-006**: A signed-in user remains signed in across app restarts for the full session lifetime, with zero unintended sign-outs observed in testing.
- **SC-007**: Every authentication failure a user can trigger, including wrong password, wrong code, expired code, taken email, cancelled social sign-in, and lost connectivity, produces a specific message that names the problem and the next step; no path shows a raw error or a dead end.
- **SC-008**: Registration, sign-in, and one-time code entry are all usable from a fresh install with no prior setup, on both supported platforms, and in both supported languages and reading directions.
- **SC-009**: Repeated one-time code requests and repeated wrong code entries are throttled, so no identifier can be targeted with unlimited codes or unlimited guesses.
- **SC-010**: No password or one-time code appears in any log, diagnostic report, or crash report collected during testing.
- **SC-011**: A guest who registers or signs in keeps a continuous experience: they arrive back on the home screen as a signed-in user with no repeated entry-screen choice.
- **SC-012**: A user who has forgotten their password can go from the sign-in screen to signed in on the home screen with a new password, without contacting support and without using any other sign-in method.
- **SC-013**: Every user story in this specification can be demonstrated independently against the blank home screen, proving the full entry-to-home cycle for each path.

## Assumptions

- **Full name is a single field.** The user asked for "Full name", so registration collects one name value rather than separate first, middle, and last name fields, even though other parts of the product model names in parts.
- **Avatar is optional.** The user listed it first among register fields but did not mark it required; blocking signup on an image upload would hurt completion, so a default placeholder stands in when none is provided. Device-side downscaling means the 2 MB limit is rarely reached by a normal phone photo, so rejection is an edge case rather than a routine outcome.
- **The email code applies only to email-and-password registration.** The description says email OTP is not verified at email sign-in, and explicitly excludes an email code from both the phone-first and social completion paths.
- **The phone code applies to every phone sign-in and to the social completion path.** Phone-first registration inherits the already-verified number, and email-and-password registration does not verify the phone at all.
- **The password rule is enforced on the client for immediate feedback and by the backend as the authority.** The client check exists so the user sees the problem before submitting, not as the security boundary.
- **One-time codes are 6 digits, expire after 10 minutes, allow a small number of wrong attempts, and can be resent after a 60-second cooldown.** These are common defaults; no specific values were given.
- **Sign-out is in scope** even though it was not listed, because the entry-to-home cycle cannot be demonstrated repeatedly or tested without it.
- **The home screen is deliberately blank** for this feature. It exists to prove routing and session state, and its product content is a separate feature.
- **Guest mode grants read-only browsing.** Since the home screen has no content yet, guest limitations are defined by the rule in FR-039 rather than by a list of specific blocked features.
- **Apple sign-in is offered only where the platform supports it**, so its absence on other platforms is expected behavior rather than a defect.
- **The product already has the supporting pieces** this feature builds on: persistent secure storage for session tokens, automatic session renewal, an existing visitor-state concept that already includes a guest value, phone number entry with country code and validation, and translated text for login, registration, verification, and guest wording in both supported languages.
- **The backend supplies the authentication operations** for registration, sign-in, code issuing and verification, social sign-in exchange, session renewal, and sign-out. Confirming the exact contract for each is planning work, not specification work.
- **The existing student and company profile split is example scaffolding, not a product requirement.** The profile feature currently in the codebase demonstrates the architecture rather than the real domain, and will be refactored after this feature to match the single generic account this specification defines. This feature therefore models no roles.
- **Account deletion, biometric sign-in, two-factor authentication beyond the codes described here, and email-address changes are out of scope** for this feature.

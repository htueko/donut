# J'Donuts Flutter Code Test — Analysis & Chunked Build Plan

## 1. What the test is (detailed analysis)

**Task:** Senior Flutter Developer code test (Madivizion, Nov 7 2026). Build a working slice of the J'Donuts customer app: **3 tasks, 10 screens, Android + iOS**, 2-day limit. No backend required; local data only.

**Hard rules:**
- Must run on iOS Simulator *and* Android emulator.
- No design screenshots may be committed to the repo (client property).
- Submission = public Git repo (small commits) + release `.apk` + zipped iOS Simulator `.app` + 2–4 min screen recording + README.
- Fails outright if: doesn't build from README, crashes in main flow, or data hard-coded in widgets.
- AI tools allowed, but candidate must explain every line (walkthrough call).

### Scoring weights (60% is offline + motion + architecture)

| Area | Weight | What they check |
|---|---|---|
| Offline data (Task 2) | 20% | DB as source of truth, airplane mode, refresh + image caching |
| Motion & presentation (Task 3 + flow) | 20% | Smooth purposeful animation, polished Rewards |
| Architecture & code quality | 20% | Clean layers, DI, testable, analyzer clean, naming |
| UI fidelity | 15% | Matches 10 screens: spacing, type, colour, states |
| Validation & flow (Task 1) | 10% | Every rule enforced, clear errors, session across relaunch |
| Tests | 10% | Meaningful unit/widget/integration tests that pass |
| Delivery | 5% | README, builds, recording, commit history |

### Task 1 — Fake auth + real validation
- `AuthRepository` interface + fake impl: ~1s delay, stores users locally, swappable for real API without touching UI.
- Flows: Register = Phone → OTP → Name → DOB → Welcome → Home. Login = Phone → OTP → Home (unknown number → inline message + link to register). Relaunch while logged in → Home; logged out → Onboarding. Log out row in Settings. Back arrow returns to previous step **keeping entered data**. Google/Apple/Facebook/Terms/Privacy = placeholder sheet or snackbar.
- Validation rules (pure functions in domain layer, unit-tested):
  - **Phone:** strip spaces, dashes, one leading 0; then 9 followed by 7–9 digits (`09254135592` → `+959254135592`). Continue disabled until valid; inline error on blur.
  - **OTP:** 6 digits; fake code `123456`; wrong → boxes shake + clear + message; 3 wrong → lock until Resend. Input: auto-advance, backspace back, paste fills all 6, numeric keyboard, SMS autofill hint.
  - **Resend:** countdown 5:00; active at 0:00; restarts timer.
  - **First name:** required, 1–50 after trim, letters+spaces incl. Myanmar script, no digits.
  - **Last name:** optional, same charset.
  - **DOB:** real calendar date (no 31 Apr; Feb 29 only leap years), not future, age ≥ 13 (named constant).
  - **Every step:** Continue shows loading during fake call; double-tap sends one request.

### Task 2 — Home + Product detail, offline-first
- Seed products/banners/sections/shops/member from bundled JSON into local DB on first launch.
- After first launch: fully works in airplane mode (Home, Product detail, Rewards, **images included**).
- On reconnect: background refresh + pull-to-refresh; small offline banner while offline.
- Images: cached on disk, placeholder + error states; seed images bundled as assets.
- **One member record for every screen** (mockups disagree: Home Bronze/1,290 vs Rewards Silver/500 — DB wins).
- Home: member header (name, photo, tier, points to next tier, bell w/ count), auto-play banner carousel, horizontal lists (Seasonal specials, Popular, Order again) with discount badges, nearby shops ("There are 4 J'Donut shops near you"), Explore now / Order online need no action. Skeletons (no spinners); per-section empty + error states.
- Product detail: product code, name, price in MMK with thousands separators (`3,200 MMK`), New badge from data, image, description under "What's this?", quantity stepper (min 1), Add to cart shows live total (qty × price); visual feedback only.

### Task 3 — Rewards (motion showcase)
- Animate at minimum: points ring sweeps 0 → member progress while total counts up to 680,000; tier ladder (Silver→Gold→Platinum) appears in order, current highlighted, line to next fills with progress; tabs (Eat more earn more / Gift) switch with moving indicator + list transition; challenge cards enter staggered, donut colours in by quarters (1/4, 4/4), coffee arc fills to 9/12; Earn active w/ attention cue when 4/4, grey otherwise, press feedback no action; Rewards badge (3) pops in; bottom-nav pill slides Home↔Reward.
- Ring and progress art via CustomPainter (or Rive); donut/coffee photos may be image assets.

### Flow-wide motion minimums
- Onboarding: donut circles drift in; title/buttons staggered.
- Registration: shared-axis/slide between steps; progress ring 25→50→75→100% then morphs into check.
- Inputs: focus/error animate; OTP shake on wrong code.
- Buttons: scale on press; Continue morphs into loading.
- Welcome: donut tiles slide in staggered, title fades up.
- Home: skeleton shimmer; sections staggered; carousel auto-plays.
- Tile → detail: Hero on product image; quantity number animates on change.
- Tab switch: pill slides; Rewards entrance as Task 3.
- 60 fps profile mode; respect `MediaQuery.disableAnimations`; durations/curves as named constants in one motion file; mostly Flutter's own APIs.

### Technical requirements
- Latest stable Flutter/Dart (project: **Flutter 3.47.5 / Dart 3.13.4**), versions in README.
- Feature-first folders (`auth`, `home`, `product`, `rewards`), each split presentation/domain/data; **domain has no Flutter imports**.
- Riverpod or BLoC (choose + explain); DI via providers/get_it; no services created in widgets.
- go_router with auth redirect guard + `/product/:id`.
- Drift (SQLite) recommended, versioned migrations; session in flutter_secure_storage.
- Models: freezed + json_serializable (or Dart 3 sealed classes).
- Errors: typed failures as Result type; no swallowed exceptions; loading/error/empty on every screen.
- Images: cached_network_image w/ disk cache + bundled seed assets.
- connectivity_plus **plus a real reachability check** (not just the event stream).
- Theme: colours/type/spacing as design tokens in one theme; no hard-coded colours.
- Strings in ARB via gen-l10n (Burmese locale = bonus).
- Portrait phones 4.7–6.9", text scale 1.3 without overflow.
- Code quality: analyze clean; functions ~≤20 lines, files ~≤300; named constants; no magic numbers.
- Tests: unit (validators, use cases), widget (login + registration validation), one integration test (Register → Home → Product detail).
- Optional: mock server (/v1, {data, error, meta} envelope, Dio w/ timeouts/retry/logging interceptors); CI running analyze + tests.

### Key traps / gotchas
1. Member data must come from ONE record — both Home and Rewards read it.
2. Works in **airplane mode after first launch** — test this before recording.
3. Images must render offline too → bundle seed images as assets.
4. Don't commit the PDF/design screenshots.
5. Double-tap protection on every Continue; loading morph on buttons.
6. Resend countdown must actually restart at 0:00.
7. Lock OTP entry after 3 wrong codes until Resend.
8. DOB: real calendar validation (Feb 29 leap-year logic), age ≥ 13 as named constant.
9. Reduce Motion respected everywhere.
10. README must build from its steps — verify on a clean checkout.

## 2. Current project state

- Fresh Flutter 3.47.5 / Dart 3.13.4 app `donut` (git repo, 2 commits, boilerplate `lib/main.dart` counter demo).
- `pubspec.yaml` already has: flutter_riverpod, go_router, drift + sqlite3_flutter_libs + path_provider/path, flutter_secure_storage, freezed + json_annotation, cached_network_image, connectivity_plus, intl, cupertino_icons; dev: drift_dev, build_runner, freezed, json_serializable, mocktail, flutter_lints.
- Still to add: `integration_test` (sdk), `flutter_lints` tighten or `very_good_analysis` (keep flutter_lints, it's fine), l10n `generate: true`, assets (seed JSON + images), mock_server/ (Node).

## 3. Target architecture (decisions)

**State management: Riverpod** (already chosen). Rationale for README: compile-safe DI via providers, trivial overrides for tests (fake clock/datasources), `AsyncNotifier`/`StreamNotifier` fit loading/error/empty states, no `BuildContext` lookups in domain.

**Folder map** (feature-first; `catalog` is a shared-data feature so Home/Product/Rewards all read the same local DB):

```
lib/
  main.dart                  # bootstrap: ProviderScope + DB/seed + runApp
  app/
    app.dart                 # DonutApp: MaterialApp.router, theme, l10n
    router.dart              # go_router: redirect guard, ShellRoute (bottom nav), /product/:id
    theme/                   # app_colors / app_typography / app_spacing / app_theme (tokens only)
    motion/app_motion.dart   # ALL durations + curves as named constants
    l10n/app_en.arb, app_my.arb (+ generated)
  core/
    result.dart              # sealed Result<T> + typed Failures
    formatters/price_mmk_formatter.dart   # 3,200 MMK
    widgets/                 # PrimaryButton (press-scale + loading morph), Skeleton shimmer,
                             # OfflineBanner, ErrorRetryView, EmptyStateView, SectionHeader
  features/
    auth/
      domain/                # User/Session entities, validators (pure), AuthRepository,
                             # usecases (RegisterUseCase, LoginUseCase, LogoutUseCase, SessionStatus)
      data/                  # UserDto (freezed), AuthLocalDataSource (Drift users + secure storage),
                             # FakeAuthRemoteDataSource (1s delay, OTP 123456), AuthRepositoryImpl
      presentation/          # providers, onboarding, phone, otp (OtpInputField + countdown),
                             # name, dob, welcome, ProgressRing (→ check morph)
    catalog/
      domain/                # Product, Banner, Shop, Member, Challenge, CatalogSection entities,
                             # CatalogRepository (watchCatalog, refresh, member)
      data/                  # Drift tables/daos/migrations, SeedRunner (assets/seed/catalog.json
                             # + images), CatalogRepositoryImpl, CatalogSync (mock server, optional)
      presentation/          # providers
    home/presentation/       # HomeScreen: MemberHeader, BannerCarousel (auto-play), ProductRow
                             # (Seasonal/Popular/Order again), NearbyShops, skeletons, offline banner
    product/
      domain/                # GetProduct
      presentation/          # ProductDetailScreen: Hero, qty stepper (animated), AddToCart total
    rewards/presentation/    # RewardsScreen: PointsRingPainter, TierLadder, RewardTabs (moving
                             # indicator), ChallengeCard (donut-quarter + coffee-arc painters), Earn
    settings/presentation/   # placeholder tabs (Orders/Cart/Notifications), Settings with Log out
  data/local/                # AppDatabase (Drift), tables/, daos/ (or per-feature data/ as above)
mock_server/                 # Node/Express /v1 endpoints, {data, error, meta} envelope
assets/seed/                 # catalog.json + bundled seed images
test/                        # mirrors lib: validators, usecases, repos, widgets
integration_test/            # register_home_product_test.dart
```

**Database (Drift, schemaVersion 1):** `users`, `member` (single row id=1), `products`, `banners`, `shops`, `challenges`, `app_meta` (seed version). Migrations versioned; seed skipped if already seeded.

**Offline strategy:** DB = single source of truth for UI (streams via DAOs). First launch: seed from bundled JSON + assets. `CatalogSync` (mock server, Dio + timeout/retry/logging interceptors) refreshes in background when `connectivity_plus` event + real reachability check (HEAD with timeout) succeeds, and on pull-to-refresh. Offline banner while `!reachable`. Images: `CachedNetworkImage` (disk cache, placeholder + error widget) — URLs point at mock server or bundled assets on first launch.

**Motion conventions:** every duration/curve from `app/motion/app_motion.dart` (e.g., `kMotionFast = 180ms`, `kMotionBase = 320ms`, `kMotionEmphasis = 550ms`, `kCurveStandard = Curves.easeOutCubic`, `kCurveEmphasized = Cubic(0.2, 0, 0, 1)`). Every animated widget checks `MediaQuery.disableAnimationsOf(context)` and shortens/skips.

## 4. Chunks (each = one small prompt, executed in order)

Each chunk lists: **Goal / Files / Done when**. After every chunk: `flutter analyze` clean + chunk's tests green + commit.

| # | Chunk | Contents |
|---|---|---|
| C0 | **Project scaffold** | Folder skeleton (empty files w/ TODO headers), `analysis_options.yaml` (flutter_lints + strict flags: always_declare_return_types etc.), l10n setup (`generate: true`, en + my ARB with app strings), `app_motion.dart` constants, `.gitignore` assets note. Done: `flutter analyze` clean, `flutter gen-l10n` runs. |
| C1 | **Design tokens & theme** | `app_colors` (donut-brand pink/cream/chocolate defaults — user reviews vs PDF), `app_typography` (TextTheme), `app_spacing` (4/8/12/16/24/32 + radii), `app_theme.dart` assembles ThemeData (filled buttons, inputs). Done: analyze + swap counter demo to themed empty `DonutApp` with l10n. |
| C2 | **Core primitives** | `core/result.dart` (sealed `Result<T>`, `Failure` sealed: NetworkFailure, CacheFailure, ValidationFailure, NotFoundFailure, UnexpectedFailure), `PriceMmkFormatter`, `PrimaryButton` (press scale + loading morph), `Skeleton` shimmer box, `OfflineBanner`, `ErrorRetryView`, `EmptyStateView`, `SectionHeader`. Done: unit tests for Result + formatter; analyze. |
| C3 | **Catalog domain** | freezed entities: `Product`, `Banner`, `Shop`, `Member` (tier enum Bronze/Silver/Gold/Platinum, points, pointsToNext), `Challenge` (kind donut/coffee, current/target), `CatalogSection`; `CatalogRepository` abstract. No Flutter imports. Done: analyze (freezed files generated via build_runner). |
| C4 | **Local DB + seed** | Drift `AppDatabase` v1 + tables/daos; `SeedRunner` reads `assets/seed/catalog.json` + bundled images into DB on first launch (idempotent via `app_meta.seed_version`); in-memory-DB unit test for seeding. Done: test green; app boots and DB file created. |
| C5 | **Auth domain + validators** | `PhoneValidator` (strip/normalize, `^9\d{7,9}$`), `OtpValidator` (6 digits, `123456`), `NameValidator` (1–50 trimmed, unicode letters incl. Myanmar `\u1000-\u109F` + spaces, no digits), `DobValidator` (real date, not future, age ≥ 13 via `kMinimumAge`), `AuthRepository` + `User`/`Session` + use cases (`RegisterUseCase`, `LoginUseCase`, `LogoutUseCase`, `ObserveSession`). Done: **extensive unit tests** (every rule + edge cases). |
| C6 | **Auth data layer** | `FakeAuthRemoteDataSource` (1s delay; register stores in DB; login checks known numbers; OTP always `123456`, tracks attempt count), `AuthLocalDataSource` (secure storage session token), `AuthRepositoryImpl` mapping to `Result`. Done: unit tests (unknown number login fails w/ link-to-register signal, register persists, session round-trips, logout clears). |
| C7 | **Router + bootstrap** | `main.dart` (ProviderScope, DB open + seed, overrides), `router.dart`: `/onboarding`, `/register/phone|otp|name|dob` (step args), `/welcome`, `/home`, `/product/:id`, `/rewards` + ShellRoute w/ bottom nav (Home, Rewards live; Orders/Cart/Notifications placeholders + Settings w/ Log out). Redirect guard: session null → onboarding stack; logged in → /home. Done: app runs, logout/login navigation works. |
| C8 | **Onboarding screen** | Donut circles drift-in (looping gentle float), title + buttons staggered entrance, `Let's get started` → register, `Log in` → login mode, social buttons + Terms/Privacy → placeholder snackbar sheet. Done: analyze; animation checks with reduce-motion. |
| C9 | **Progress ring + Phone screen** | `ProgressRing` (25/50/75/100% + check morph), step transitions (shared-axis), `PhoneScreen`: +95 prefix, input formatting, inline error on blur, Continue disabled/loading/double-tap-safe → OTP. Done: widget test for phone validation states. |
| C10 | **OTP screen** | `OtpInputField` (auto-advance, backspace-back, paste-all, numeric keyboard, `AutofillHints.oneTimeCode`), wrong → shake + clear + message, 3 strikes → lock until Resend, countdown 5:00 → resend restarts; login mode: unknown number → inline message + "Register" link. Done: widget tests (wrong code, lock, resend enable at 0). |
| C11 | **Name + DOB screens** | Both with inline validation, back arrow restores entries, Continue loading; DOB via `showDatePicker` w/ first/last date guards + manual leap-year test. Register → Welcome → Home (new), login → Home (returning). Done: widget tests for name/dob rules. |
| C12 | **Welcome screen** | Donut tiles staggered slide-in, title fade-up, `Let's explore` → Home. Done: analyze. |
| C13 | **Home screen** | `MemberHeader` (name/photo/tier/points-to-next/bell w/ count), `BannerCarousel` (auto-play), product rows (Seasonal specials, Popular, Order again) w/ discount badges, `NearbyShops`, skeleton loading, per-section empty/error, Hero source for tiles. Done: renders from DB; widget test for empty/error states. |
| C14 | **Offline/online sync** | `CatalogSync` w/ Dio (timeouts, retry, logging interceptors) against mock server `/v1/*` `{data, error, meta}` envelope; background refresh on reconnect (connectivity_plus + real HEAD reachability check) + pull-to-refresh; `OfflineBanner`; verify airplane-mode run (DB + bundled images render). Done: manual airplane test + unit tests for envelope parsing. |
| C15 | **Product detail** | `GetProduct` + provider by id, not-found error state, Hero image transition, code/name/`3,200 MMK` price/New badge/`What's this?` description, animated quantity stepper (min 1), Add to cart → live total + snackbar feedback. Done: widget test for qty/total. |
| C16 | **Rewards screen** | `PointsRingPainter` (sweep 0→progress, count-up to `kRewardTotalPoints = 680000`), `TierLadder` (sequential reveal + progress line), tabs w/ sliding indicator + list transition, `ChallengeCard` staggered + donut-quarter painter + coffee arc (9/12), Earn attention cue at 4/4 (grey otherwise, press feedback), badge (3) pop-in, bottom-nav pill slide. Done: analyze; reduce-motion check; profile-mode frame check. |
| C17 | **Integration test + motion polish** | `integration_test/register_home_product_test.dart` (Register → Home → Product detail), audit all durations/curves come from `app_motion`, reduce-motion everywhere, text-scale 1.3 overflow pass on all screens, function/file length pass. Done: `flutter test integration_test` green on emulator. |
| C18 | **Mock server + deliverables** | `mock_server/` (Node/Express, `/v1/products|banners|shops|member`, `{data, error, meta}`, seed from same JSON), README (run steps, versions, architecture map, Riverpod rationale, offline strategy, animations list, OTP 123456, known gaps, time spent), CI (analyze + test), release `.apk`, zipped iOS `.app` (needs macOS — see risks), recording script/storyboard, final commits. Done: submission checklist complete. |

## 5. Validation plan (overall)

- After every chunk: `flutter analyze` (must be clean), `flutter test` (chunk tests), `dart format` unaffected lines, commit with conventional message (`feat(auth): ...`).
- End of C14: airplane-mode manual test (Home/Product/Rewards + images).
- End of C17: `flutter build apk --release` + `flutter build ios --simulator` (if macOS available) + integration test green + profile-mode jank check (`flutter run --profile`).
- Clean-room check: fresh clone → README steps → builds.

## 6. Risks & mitigations

- **iOS Simulator build requires macOS/Xcode** — this machine is Linux. Mitigation: Android-first; iOS build done on the user's Mac or flagged as known gap; code kept platform-neutral (no Android-only APIs).
- **I cannot see the design screenshots** (no image input). Mitigation: theme defaults from brand cues (pink/cream/chocolate, rounded cards); user compares each UI chunk against the PDF pages and gives small corrections.
- **Time budget (2 days)**: chunk order front-loads scoring (data + architecture before pixel polish); Rewards + motion are C16–C17 so the 20% motion score is never starved.
- **build_runner/freezed codegen time**: run once per model change; keep entities in few files.
- **Drift migration churn**: schema frozen after C4; later additions get versioned migrations.
- **Mock server scope creep**: C18 only after app is complete offline; app must never depend on it.

## 7. Open items for implementation

- Confirm donut-brand palette (defaults assumed) when doing C1 — user review against PDF p.5.
- Decide bundled seed images source (generated simple donut/coffee PNGs via script, or royalty-free images downloaded once).
- `my` (Burmese) ARB is bonus: add if time permits at C18.
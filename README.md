# J'Donuts

A Flutter slice of the J'Donuts customer app: a fake phone/OTP sign-up flow with
real validation, an offline-first catalog (home + product detail), a motion
showcase rewards screen, English/Burmese localization, and light/dark/system
theming — all backed by one local database.

Built with **Flutter 3.47.5 / Dart 3.13.4** (stable). State: **Riverpod**.
Local data: **Drift (SQLite)**. Routing: **go_router**. Models: **freezed** +
`json_serializable`. Localization: **flutter gen-l10n** (ARB).

---

## Quick start

```bash
flutter pub get
flutter run
```

That is the whole setup. There is no `.env`, no API key and no code-generation
step required to run: the generated Drift/freezed/JSON files are committed, and
the app ships with its data.

On first launch the app opens (or creates) a local SQLite database and seeds it
from `assets/seed/catalog.json` plus the bundled artwork in
`assets/seed/images/`. From then on the database is the single source of truth
for the UI, so the app is fully usable in airplane mode — **images included**.

The sign-up flow uses a fake backend. The OTP is always **`123456`**.

### Regenerating code (only if you change schemas/models)

```bash
dart run build_runner build --delete-conflicting-outputs   # freezed, json, drift
flutter gen-l10n                                           # ARB -> AppLocalizations
```

### Optional: run against the mock server

```bash
cd mock_server
node server.js            # http://localhost:8080

# in another shell
flutter run --dart-define=MOCK_SERVER_URL=http://localhost:8080
```

Without that define the app never makes a network call. See
[`mock_server/README.md`](mock_server/README.md).

### Tests

```bash
flutter analyze
flutter test                                     # 110 unit + widget tests
flutter test integration_test/register_home_product_test.dart -d linux
```

The integration test drives the real registration flow end to end (register →
home → product detail) against an in-memory database.

### Build

```bash
flutter build apk --release
```

---

## Flutter & Dart versions

| Tool   | Version        |
| ------ | -------------- |
| Flutter| 3.47.5 (stable)|
| Dart   | 3.13.4 (stable)|
| DevTools | 2.60.0       |

The Dart SDK constraint is `sdk: ^3.13.4` in `pubspec.yaml`.

---

## Architecture

Feature-first folders. Each feature owns its own `domain`, `data` and
`presentation` layers, and `domain` has **no Flutter imports** (pure Dart, so it
is unit-testable in isolation).

```
lib/
  main.dart                     # bootstrap: DB open + seed, secure-storage reads, provider overrides
  app/
    app.dart                    # DonutApp, MaterialApp.router, MotionScope (text-scale clamp)
    router.dart                 # go_router: auth redirect guard, shell routes, /product/:id, /legal/*
    shell/app_shell.dart        # bottom NavigationBar (Home / Rewards / Cart / Settings)
    theme/                      # AppColors, AppPalette (ThemeExtension), AppSpacing, AppTypography, AppTheme
    motion/app_motion.dart      # every duration, curve, and reduce-motion helper
  core/
    result.dart                 # Result<T> + typed failures (Network/Cache/Validation/NotFound/Unexpected)
    validation/                 # ValidationResult
    formatters/                 # locale-aware decimal, price (MMK) and percent formatters
    network/                    # Dio interceptors (retry on 5xx/timeout, debug logging) + reachability probe
    widgets/                    # buttons, shimmer/skeleton, feedback/empty/error views, pressable
  features/
    auth/          domain/ data/ presentation/   # onboarding, phone, OTP, name, DOB, welcome
    catalog/       domain/ data/ presentation/   # models, Drift DB/DAO, seed, sync, repository, providers
    home/          presentation/                # member header, banner carousel, product rows, shops, skeletons
    product/       presentation/                # detail + quantity stepper + live total
    rewards/       presentation/                # points ring, tier ladder, reward tabs, challenge cards/painters
    cart/          presentation/                # placeholder tab
    notifications/ presentation/                # placeholder screen
    settings/      presentation/                # language + theme pickers, log out
    legal/         presentation/                # Terms of Use / Privacy Policy pages
  l10n/                         # ARB (en + my) + generated AppLocalizations
mock_server/                    # optional Node /v1 API
test/                           # mirrors lib, plus support/ fakes and fixtures
integration_test/               # register -> home -> product detail
tool/                           # generate_seed_art.py (seed artwork)
```

### Feature anatomy (example: `catalog`)

- `domain/` — freezed models (`Product`, `Banner`, `Shop`, `Challenge`, `Member`,
  `CatalogData`), enums (`CatalogSection`, `Tier`, `ChallengeKind`),
  `TierProgress`, and `CatalogRepository` (abstract).
- `data/` — `catalog_database.dart` + `catalog_dao.dart` + `catalog_tables.dart`
  (Drift), `catalog_seed.dart` (idempotent first-run seed keyed by
  `app_meta.seed_version`), `catalog_sync.dart` (Dio → Drift), `catalog_providers.dart`
  (DI wiring, online-status stream, sync).
- `presentation/` — none for catalog itself; its widgets live under `home/`,
  `product/` and `rewards/`, which read through the repository.

### Data flow

```
assets/seed/catalog.json ─┐
mock_server /v1/*  ───────┼─► CatalogSync ─► Drift (source of truth) ─► streams ─► UI
                          ┘
```

`CatalogRepository` exposes `watchCatalog()` and `getProduct(id)`; the UI never
touches the DAO directly. Failures are typed (`NetworkFailure`, `CacheFailure`,
`ValidationFailure`, `NotFoundFailure`, `UnexpectedFailure`) and returned as
`Result<T>` rather than thrown.

### Why Riverpod

Providers are the DI container: compile-safe, overridable in tests (the whole app
boots against an in-memory database plus a fake secure-storage gateway), and they
compose naturally with `StreamProvider` for the Drift-backed catalog and the
online-status stream. No service is constructed inside a widget — `main.dart`
builds the database, reads any saved session/locale/theme, then hands them to
`ProviderScope` via overrides.

---

## State management

**Riverpod 2.x** (`flutter_riverpod`). Reasons:

- **Testable DI.** Every dependency is a provider, so widget tests override the
  database, Dio and secure storage without touching production wiring.
- **Reactive streams.** `catalogDataProvider` is a `StreamProvider.autoDispose`
  over a Drift watch stream; `onlineStatusProvider` streams connectivity +
  reachability. The UI just `watch`es and rebuilds.
- **No service locator / global state.** Session, registration draft, locale and
  theme mode are all providers, so the router's redirect guard can read the
  session reactively via `ref.listen`.

---

## Offline strategy

Read from Drift **always**; write from the seed on first launch; write from the
network when a real reachability probe says we are online.

1. **Bundled seed + assets.** `assets/seed/catalog.json` and
   `assets/seed/images/` are declared in `pubspec.yaml` and loaded by
   `SeedRunner` into Drift on first run. Seeding is idempotent via
   `catalog_seed_version` in `app_meta`, so it never clobbers synced data.
2. **Drift/SQLite is the single source of truth.** Home, product detail and
   rewards all `watch` the same tables, so they always agree and never show a
   spinner when the DB is warm (they show skeleton shimmer only on first load).
3. **Real reachability, not just the connectivity event.**
   `onlineStatusProvider` combines `connectivity_plus` with an actual HEAD probe
   (`ReachabilityService`) that times out. An `OfflineBanner` shows while the
   probe fails, and Home/Rewards/Detail gate their background refresh on it.
4. **Safe sync.** When online (and on pull-to-refresh, and when connectivity
   returns via `CatalogRefreshListener`), `CatalogSync` fetches `/v1/*` through
   Dio with timeouts, a retry-on-5xx/timeout interceptor and debug logging, then
   writes the parsed catalog into the same tables. A malformed payload throws
   before any write, so a bad response never replaces good local rows.
5. **Login/session offline.** The session token + user id live in
   `flutter_secure_storage`; a relaunch restores the session with no network.

### Offline strategy in one line

> Read from Drift always; seed on first launch; sync from the network only when a
> real reachability probe passes — and never overwrite good rows with a malformed
> payload.

---

## Fake OTP

The OTP is **`123456`** for every flow (register and login). The verification is
faked with a one-second delay in `FakeAuthRemoteDataSource`; anything other than
`123456` fails validation.

- Wrong code → the OTP boxes shake, clear, and show an error.
- Three wrong tries → entry is locked until **Resend**.
- **Resend** counts down from 5:00 and restarts on use.
- Real rules are enforced client-side even though the backend is fake.

---

## What's implemented

### 1. Fake auth with real validation

| Step  | Rules |
| ----- | ----- |
| Phone | Strip spaces/dashes/one leading `0`; then `9` followed by 7–9 digits. `09254135592` → `+959254135592`. |
| OTP   | 6 digits; `123456` passes. Wrong code shakes, clears and messages; 3 strikes lock until Resend (5:00 countdown, restarts on use). |
| Name  | First name required, 1–50 chars after trim, letters and spaces incl. Myanmar script, no digits. Last name optional, same charset. |
| DOB   | Real calendar date (no 31 April; 29 Feb only in leap years), not in the future, age ≥ 13. |

Every step has inline errors, a Continue button disabled until valid, a loading
morph while the fake call is in flight, and double-tap protection. The back arrow
returns to the previous step **keeping what was already typed** (the
`RegistrationDraft` provider preserves phone/name/DOB across steps).

Register: Phone → OTP → Name → DOB → Welcome → Home. Login: Phone → OTP → Home.
An unknown number shows an inline message plus a link to register. A session
survives relaunch; logging out (Settings) clears it and returns to onboarding.
Google/Apple/Facebook show placeholder snackbars; Terms/Privacy open full pages
(`/legal/terms`, `/legal/privacy`) readable both before and after sign-in.

### 2. Home + product detail, offline-first

- Seed data (products, banners, sections, shops, member) loads into Drift on
  first launch and is idempotent via `app_meta.seed_version`.
- The UI streams from Drift, so airplane mode changes nothing — images included.
- On reconnect and on pull-to-refresh, `CatalogSync` fetches `/v1/*` through Dio
  and writes into the same tables; a reachability check gates the background
  refresh and an offline banner shows while the probe fails.
- One member record backs every screen: Home and Rewards read the same row
  (`Su Su Hlaing`, Silver, 680,000 points, 3 notifications).
- Home: member header with tier badge + "points to next tier", auto-playing
  banner carousel, horizontal rows for Seasonal specials / Popular / Order again
  (with discount badges), nearby shops ("There are 4 J'Donut shops near you"),
  skeleton loaders, per-section empty states, and pull-to-refresh.
- Product detail: code, name, price as `3,200 MMK`, a NEW badge from data, image
  (Hero transition from the tile), description under "What's this?", and a
  quantity stepper (min 1) with a live total that animates on change. Add-to-cart
  shows a snackbar with the quantity.

### 3. Rewards (motion showcase)

- **Points ring** sweeps from empty while the total counts up to 680,000, both
  driven by one 0→1 timeline so the arc ends at the tier fraction and the number
  ends on the full total. Artwork via `CustomPainter` (`PointsRingPainter`) with a
  gradient sweep.
- **Tier ladder** (Silver → Gold → Platinum) as nodes on a track, the current
  tier highlighted with a glow, and the connector filled to tier progress.
- **Tabs** (Eat more earn more / Gift) switch with an `AnimatedAlign` sliding pill
  and an `AnimatedSize` + `FadeTransition` list swap.
- **Challenge cards** enter staggered (`_StaggeredCard`); the donut fills one
  quarter per completed item (`DonutQuarterPainter`, 1/4), the coffee cup sweeps
  its arc (`CoffeeArcPainter`, 9/12). "Earn" is grey until 4/4, then pulses with a
  sine-driven glow as an attention cue; pressing gives haptic + snackbar, no
  navigation.
- Rewards badge (3) pops in on the bottom nav and in the rewards header.

### 4. Localization (English + Burmese)

- Every user-facing string lives in `lib/l10n/app_en.arb` and `app_my.arb`, with
  generated `AppLocalizations`. Nothing user-facing is hard-coded.
- Plural/placeholder strings (nearby-shop count, points-to-next-tier, points
  added to cart, challenge tapped) are parameterized in the ARBs.
- `Intl.defaultLocale` is kept in step with the selected locale so
  `DateFormat`/`NumberFormat` calls localize too.
- Locale-aware formatters in `lib/core/formatters/`: decimal (`680,000`), price
  (`3,200 MMK`) and percent (`15% off`), each taking an explicit `locale`.

### 5. Theming (light / dark / system)

- Palette-driven via a `ThemeExtension` (`AppPalette`) exposed as `context.palette`.
  Widgets read semantic colors (`surface`, `textPrimary`, `primary`, `border`,
  `success`, `warning`, shimmer, shadow…) instead of naming a `Color`, so the same
  tree renders in both modes.
- `AppTheme.light` / `AppTheme.dark` in `lib/app/theme/app_theme.dart`.
- Settings has a theme picker (Light / Dark / System); the choice is persisted in
  `flutter_secure_storage` and restored on launch in `main.dart`.

### 6. Settings

- User card (name + phone), **Language** picker (English / Myanmar), **Theme**
  picker (Light / Dark / System), and **Log out**. Locale and theme choices are
  persisted and survive restarts; logout clears the session and routes back to
  onboarding.

### 7. Edge-to-edge / system bar polish

- Home, Rewards and Onboarding wrap their body in `AnnotatedRegion<SystemUiOverlayStyle>`
  so the status-bar icons stay legible in both light and dark modes, with a
  transparent status bar and `SafeArea` handling.

### Flow-wide motion

Onboarding donut drift and staggered entrance; registration progress ring
25 → 50 → 75 → 100 % then a check morph; shared-axis step transitions; animated
input focus/error borders; OTP shake; button press scale and loading morph;
staggered welcome tiles; skeleton shimmer; hero tile → detail; animated quantity
and tab pill. Every duration and curve is a named constant in
`lib/app/motion/app_motion.dart` (`instant/fast/base/slow/emphasis/ambient/shimmer/attention`,
`standard/decelerate/accelerate/emphasized/overshoot`), and every animated widget
routes through `motionScale` / `motionValue` / `animateOnce` / `animateRepeat`, so
`MediaQuery.disableAnimations` skips straight to the end state instead of dropping
the animation entirely. Text scale is clamped to 1.3 in `MotionScope`.

---

## Design tokens

Colours, spacing and type live in `lib/app/theme/` (`AppColors`, `AppPalette`,
`AppSpacing`, `AppTypography`) and are used through `ThemeData` or the token
classes. There are no hard-coded colours in widgets. The palette is a donut-shop
pink / cream / chocolate set — the brand PDF was not available in this
environment, so these are defaults to review against it.

---

## CI

`.github/workflows/ci.yml` runs on push to `main` and every pull request:

1. `flutter pub get`
2. `dart format --output=none --set-exit-if-changed lib test integration_test`
3. `flutter analyze`
4. `flutter test`
5. `flutter build apk --release`

---

## Known gaps

- **iOS Simulator build not produced.** Developed on Linux, which cannot build
  for iOS. No Android- or iOS-specific APIs are used, so
  `flutter build ios --simulator` on a Mac is expected to work, but it is
  unverified.
- **Cart and Notifications are placeholders.** The Cart tab and the Notifications
  screen render empty-state stubs; product-detail "Add to cart" only shows a
  snackbar. There is no persisted cart/line-item model yet. (The old Orders tab
  was removed; the four tabs are Home / Rewards / Cart / Settings.)
- **Mock server is optional.** The app is complete and fully offline without it;
  the server exists only to exercise the real HTTP sync path.
- **Social login is a placeholder** by design; Terms/Privacy render placeholder
  copy.
- **`app_my.arb` is fully translated** (bonus per the brief), and Settings can
  switch between English and Burmese.

## Time spent

Roughly two working days: ~35 % on catalog data, sync and architecture; ~25 % on
the auth flow and validation; ~20 % on the Rewards motion work and the polish pass
(text scale, reduce motion, overflow fixes, edge-to-edge); ~10 % on localization,
theming and settings; ~10 % on tests, mock server, README and CI.

---

## Credits

Seed artwork generated by `tool/generate_seed_art.py`. Everything else written for
this exercise.
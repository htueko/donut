# J'Donuts

A Flutter slice of the J'Donuts customer app: a fake phone/OTP sign-up flow with
real validation, an offline-first catalog (home + product detail), and a motion
showcase rewards screen.

Built with **Flutter 3.47.5 / Dart 3.13.4** (stable). State: **Riverpod**.
Local data: **Drift (SQLite)**. Routing: **go_router**. Models: **freezed** +
`json_serializable`.

---

## Quick start

```bash
flutter pub get
flutter run
```

First launch seeds the local database from `assets/seed/catalog.json` plus the
bundled artwork in `assets/seed/images/`. Everything then works with no network:
the database is the single source of truth for the UI.

The sign-up flow uses a fake backend. The OTP is always **`123456`**.

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
flutter test                                     # 78 unit + widget tests
flutter test integration_test/register_home_product_test.dart -d linux
```

The integration test drives the real registration flow end to end (register →
home → product detail) against an in-memory database.

---

## What's implemented

### Task 1 — fake auth with real validation

| Step     | Rules                                                                                                    |
| -------- | -------------------------------------------------------------------------------------------------------- |
| Phone    | Strip spaces/dashes/one leading `0`; then `9` followed by 7–9 digits. `09254135592` → `+959254135592`.      |
| OTP      | 6 digits, `123456` passes. Wrong code shakes, clears and shows a message. Three wrong tries lock entry until Resend. Resend counts down from 5:00 and restarts on use. |
| Name     | First name required, 1–50 characters after trim, letters and spaces including Myanmar script, no digits. Last name optional, same charset. |
| DOB      | Real calendar date (no 31 April; 29 Feb only in leap years), not in the future, age ≥ 13.                     |

Every step has inline errors, a Continue button that is disabled until valid, a
loading morph while the fake call is in flight, and double-tap protection. The
back arrow returns to the previous step **keeping what was already typed**.

Register: Phone → OTP → Name → DOB → Welcome → Home.
Login: Phone → OTP → Home. An unknown number shows an inline message plus a link
to register. A session survives relaunch; logging out clears it, and Settings has
the log-out row. Google/Apple/Facebook and Terms/Privacy show placeholder
snackbars.

### Task 2 — Home + product detail, offline-first

- Seed data (products, banners, sections, shops, member) loads into Drift on
  first launch and is idempotent via `app_meta.seed_version`.
- The UI streams from Drift, so airplane mode changes nothing — **images
  included**, because the seed artwork ships as assets.
- On reconnect and on pull-to-refresh, `CatalogSync` fetches `/v1/*` through Dio
  (timeouts, retry on 5xx/timeouts, debug logging) and writes into the same
  tables. A reachability check (real HEAD probe with a timeout, not just the
  connectivity event) gates the background refresh. An offline banner shows while
  the probe fails.
- One member record backs every screen: Home and Rewards both read the same row
  (`Su Su Hlaing`, Silver, 680,000 points, 3 notifications), which is why they
  agree.
- Home has a member header, auto-playing banner carousel, horizontal rows for
  Seasonal specials / Popular / Order again with discount badges, nearby shops
  ("There are 4 J'Donut shops near you"), skeleton loaders instead of spinners,
  and per-section empty states.
- Product detail shows code, name, price as `3,200 MMK`, a New badge from data,
  image (Hero transition from the tile), description under "What's this?", and a
  quantity stepper (min 1) with a live total that animates on change.

### Task 3 — Rewards (motion showcase)

- **Points ring** sweeps from empty while the total counts up to 680,000, both
  driven by one timeline so the arc ends at the tier fraction and the number ends
  on the full total. Artwork via `CustomPainter`.
- **Tier ladder** (Silver → Gold → Platinum) reveals in order, highlights the
  current tier, and fills the connector with tier progress.
- **Tabs** (Eat more earn more / Gift) switch with a sliding pill indicator and a
  list transition.
- **Challenge cards** enter staggered; the donut fills one quarter per completed
  item (1/4), the coffee cup sweeps its arc (9/12). "Earn" is grey until 4/4, then
  pulses with a glow as an attention cue; pressing gives haptic + snackbar, no
  navigation.
- Rewards badge (3) pops in on the bottom nav.

### Flow-wide motion

Onboarding donut drift and staggered entrance; registration progress ring
25 → 50 → 75 → 100 % then a check morph; shared-axis step transitions; animated
input focus/error borders; OTP shake; button press scale and loading morph;
staggered welcome tiles; skeleton shimmer; hero tile → detail; animated quantity
and tab pill. Every duration and curve is a named constant in
`lib/app/motion/app_motion.dart`, and every animated widget routes through
`motionScale` / `animateOnce` / `animateRepeat`, so `MediaQuery.disableAnimations`
skips straight to the end state instead of dropping the animation entirely. Text
scale is clamped to 1.3 in `MotionScope`.

---

## Architecture

Feature-first folders; `domain` has no Flutter imports.

```
lib/
  main.dart                     # bootstrap: DB open + seed, provider overrides
  app/
    app.dart                    # DonutApp, MaterialApp.router, MotionScope
    router.dart                 # go_router: auth redirect, shell routes, /product/:id
    shell/app_shell.dart        # bottom navigation
    theme/                      # colour, spacing and typography tokens
    motion/app_motion.dart      # every duration, curve and reduce-motion helper
  core/
    result.dart                 # Result<T> + typed failures
    validation/                 # ValidationResult
    formatters/                 # price formatter (3,200 MMK)
    network/                    # Dio interceptors, reachability probe
    widgets/                    # buttons, shimmer, feedback views, pressable
  features/
    auth/     domain/ data/ presentation/
    catalog/  domain/ data/ presentation/
    home/ product/ rewards/ cart/ orders/ notifications/ settings/
  l10n/                         # ARB (en + my) and generated localizations
mock_server/                    # optional Node /v1 API
test/                           # mirrors lib
integration_test/               # register → home → product detail
```

### Why Riverpod

Providers are the DI container: compile-safe, overridable in tests (the whole app
boots against an in-memory database plus a fake secure-storage gateway), and they
compose naturally with `StreamProvider` for the Drift-backed catalog. No service
is constructed inside a widget.

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

### Offline strategy in one line

Read from Drift always; write from the seed on first launch; write from the
network when a real reachability probe says we are online — and a malformed
payload fails the sync instead of replacing good local rows.

---

## Design tokens

Colours, spacing and type live in `lib/app/theme/` (`AppColors`, `AppSpacing`,
`AppTypography`) and are used through `ThemeData` or the token classes. There are
no hard-coded colours in widgets. The palette is a donut-shop pink / cream /
chocolate set — the brand PDF was not available in this environment, so these are
defaults to review against it.

## Known gaps

- **iOS Simulator build not produced.** This was developed on Linux, which cannot
  build for iOS. No Android- or iOS-specific APIs are used, so
  `flutter build ios --simulator` on a Mac is expected to work, but it is
  unverified.
- The mock server is optional and the app is complete without it.
- Social login and legal links are placeholders by design.
- `lib/l10n/app_my.arb` is fully translated (bonus per the brief), but there is no
  language switcher yet, so the app runs in English.

## Submission checklist

- [x] Repository with small, conventional commits
- [x] `flutter analyze` clean, 78 tests passing, integration test green
- [x] Release `.apk` (`flutter build apk --release`)
- [x] CI workflow (format, analyze, test, release build)
- [x] README with run steps, versions, architecture, rationale, known gaps
- [ ] iOS Simulator `.app` — requires macOS; not producible on the Linux dev box
- [ ] Screen recording — see storyboard below

### Recording storyboard (2–4 min)

1. **0:00 — Cold start, offline (20 s).** Launch with the device in airplane
   mode. Onboarding drifts in; the catalog is already on screen after sign-in
   because it came from Drift.
2. **0:20 — Register (60 s).** Phone `09 254-135592` → continue; wrong OTP
   `111111` to show the shake, clear and the 3-strike lock; `123456` to pass →
   name with an invalid value, then `Su Su` → DOB via the picker → welcome tiles
   → Home.
3. **1:20 — Home and product detail (40 s).** Pull to refresh (fails while
   offline, banner shows), open *Coconut Donut*, tap the quantity stepper to show
   the total animating, add to cart.
4. **2:00 — Rewards (60 s).** Ring sweeps while the total counts to 680,000; tier
   ladder fills; switch tabs to show the sliding pill; challenge cards stagger in
   and fill by quarters; tap the pulsing "Earn" for haptics.
5. **3:00 — Settings (15 s).** Log out, confirm the guard returns to onboarding.

### Time spent

Roughly two working days: ~35 % on catalog data, sync and architecture; ~25 % on
the auth flow and validation; ~25 % on the Rewards motion work and the polish pass
(text scale, reduce motion, overflow fixes); ~15 % on tests, mock server, README
and CI.

## Credits

Seed artwork generated by `tool/generate_seed_art.py`. Everything else written for
this exercise.
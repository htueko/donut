# J'Donuts mock API

Optional local backend so the app can be exercised against a real HTTP server
instead of only its bundled seed data. The app never requires it: without
`--dart-define=MOCK_SERVER_URL=...` the catalog is served from the local Drift
database.

## Run

```bash
cd mock_server
node server.js            # http://localhost:8080
```

Environment variables:

| Variable       | Default                        | Purpose                              |
| -------------- | ------------------------------ | ------------------------------------ |
| `PORT`         | `8080`                         | Port to listen on                    |
| `SEED_PATH`    | `../assets/seed/catalog.json`  | Seed document to serve               |
| `LATENCY_MS`   | `120`                          | Artificial delay, for skeleton state |

## Endpoints

All responses use the shared envelope:

```json
{ "data": {}, "error": null, "meta": { "source": "mock" } }
```

| Method | Path              | Returns           |
| ------ | ----------------- | ----------------- |
| GET    | `/v1/products`    | Product list      |
| GET    | `/v1/banners`     | Banner list       |
| GET    | `/v1/shops`       | Shop list         |
| GET    | `/v1/challenges`  | Challenge list    |
| GET    | `/v1/member`      | Single member row |
| GET    | `/health`         | Liveness probe    |

Errors use `{ "data": null, "error": { "code": "...", "message": "..." } }`.

## Point the app at it

```bash
flutter run --dart-define=MOCK_SERVER_URL=http://localhost:8080
```

The app writes refreshed data into the same Drift database it already reads
from, so Home, Product detail and Rewards all pick it up through the existing
streams.
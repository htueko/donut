import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const seedPath = process.env.SEED_PATH ?? join(here, '..', 'assets', 'seed', 'catalog.json');
const port = Number(process.env.PORT ?? 8080);
const latencyMs = Number(process.env.LATENCY_MS ?? 120);

const resources = {
  '/v1/products': (catalog) => catalog.products,
  '/v1/banners': (catalog) => catalog.banners,
  '/v1/shops': (catalog) => catalog.shops,
  '/v1/challenges': (catalog) => catalog.challenges,
  '/v1/member': (catalog) => catalog.member,
};

let catalog = null;

async function loadCatalog() {
  const raw = await readFile(seedPath, 'utf8');
  catalog = JSON.parse(raw);
  return catalog;
}

function send(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'content-length': Buffer.byteLength(payload),
    'cache-control': 'no-store',
  });
  res.end(payload);
}

function ok(res, data) {
  send(res, 200, { data, error: null, meta: { source: 'mock' } });
}

function fail(res, status, code, message) {
  send(res, status, { data: null, error: { code, message }, meta: { source: 'mock' } });
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url ?? '/', `http://localhost:${port}`);
  const path = url.pathname.replace(/\/+$/, '') || '/';

  if (req.method !== 'GET' && req.method !== 'HEAD') {
    fail(res, 405, 'method_not_allowed', 'Only GET is supported');
    return;
  }

  if (path === '/health') {
    ok(res, { status: 'up' });
    return;
  }

  const resource = resources[path];
  if (!resource) {
    fail(res, 404, 'not_found', `No route for ${path}`);
    return;
  }

  // Artificial latency so the app's loading skeletons are visible while testing.
  await new Promise((resolve) => setTimeout(resolve, latencyMs));

  if (!catalog) {
    try {
      await loadCatalog();
    } catch (error) {
      fail(res, 500, 'seed_unreadable', String(error));
      return;
    }
  }

  const data = resource(catalog);
  if (data === undefined || data === null) {
    fail(res, 404, 'not_found', 'Resource is empty');
    return;
  }
  ok(res, data);
});

server.listen(port, () => {
  process.stdout.write(`J'Donuts mock server on http://localhost:${port}\n`);
  process.stdout.write(`Seeding from ${seedPath}\n`);
});
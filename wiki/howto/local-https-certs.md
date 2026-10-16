---
title: Local HTTPS certificates (local.tiket.com, dev.tiket.com)
kind: howto
repos: [TIX-PASSPORT, TIX-REACT-REMOTE, TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-COMMON, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-FINTECH-NEXT-FE/docs/https-for-local-development.md
  - TIX-FINTECH-NEXT-FE/package.json
  - TIX-FINTECH-NEXT-FE/.env.local.example
  - TIX-NEXT-PAYMENT-FE/package.json
  - TIX-NEXT-PAYMENT-FE/.env.local.example
  - TIX-NEXT-PAYMENT-FE/next.config.ts
  - TIX-PASSPORT/package.json
  - TIX-REACT-REMOTE/package.json
  - TIX-REACT-REMOTE/.env.example
  - TIX-REACT-COMMON/packages/react-common-env/src/getEnvironment.ts
  - TIX-HOMEPAGE-NEXT-FE/package.json
  - TIX-HOMEPAGE-NEXT-FE/.env.local.example
  - TIX-GROWTH-NEXT-FE/package.json
  - TIX-GROWTH-NEXT-FE/.env.local.example
verified_at:
  TIX-PASSPORT: 7a33010aca
  TIX-REACT-REMOTE: 281778b
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-COMMON: 14597c4e
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/howto, repo/passport, repo/react-remote, repo/payment-fe, repo/fintech-fe, repo/react-common, repo/homepage-fe, repo/growth-fe]
---

# Local HTTPS certificates
> Local dev runs on `https://local.tiket.com:<port>` so that `*.tiket.com` session cookies are sent and MSW's service worker works. Each repo expects an mkcert pair, `local.tiket.com.pem` and `local.tiket.com-key.pem`, in its root. The files are gitignored and never committed.

## Why
- Session cookies (`session_access_token` and others) are set on `.tiket.com`, so the page must be on a `*.tiket.com` host.
- Service workers (MSW mock mode) run only on `localhost` or on HTTPS, so a custom domain needs HTTPS.
- [[react-common-env]] treats `local.tiket.com` and `dev.tiket.com` as the `local` environment ([[tiket-environments]]).

## One-time setup
1. Map the host: add `127.0.0.1 local.tiket.com` to `/etc/hosts` (and `dev.tiket.com` if you use it).
2. Create a local CA and a certificate: `brew install mkcert`, `mkcert -install`, then `mkcert local.tiket.com` (optionally `mkcert dev.tiket.com`). This prints `local.tiket.com.pem` and `local.tiket.com-key.pem`.
3. Copy both files into the root of every repo that needs them. TIX-FINTECH-NEXT-FE, TIX-NEXT-PAYMENT-FE, TIX-PASSPORT and TIX-REACT-REMOTE gitignore `*.tiket.com.pem` and `*.tiket.com-key.pem`. TIX-HOMEPAGE-NEXT-FE and TIX-GROWTH-NEXT-FE ignore every `*.pem`.

## How each repo uses them
| Repo | Where the file names are set | Command | URL |
|---|---|---|---|
| TIX-FINTECH-NEXT-FE | `.env.local`: `SSL_KEY_FILE=local.tiket.com-key.pem`, `SSL_CERT_FILE=local.tiket.com.pem` | `pnpm dev` = `next dev --experimental-https --experimental-https-key … --webpack`. `pnpm start` adds `local-ssl-proxy` 3001 → 3000 | `https://local.tiket.com:3000` (dev); the doc says `:3001` for the proxy |
| TIX-NEXT-PAYMENT-FE | `.env.local` (lines are commented out in `.env.local.example`; uncomment them) | `pnpm run dev` (same `next dev --experimental-https` flags, plus typed-scss watch). `pnpm start` adds the proxy 3001 → 3000. `allowedDevOrigins: ['local.tiket.com']` | `https://local.tiket.com:3000`. AGENTS.md says agents must not run `pnpm run dev` |
| TIX-HOMEPAGE-NEXT-FE | `.env.local`: `SSL_KEY_FILE`/`SSL_CERT_FILE` (already set in `.env.local.example`) | `pnpm dev` = `next dev --experimental-https --experimental-https-key … --webpack`. `allowedDevOrigins: ['local.tiket.com']`. `pnpm start` has no proxy | `https://local.tiket.com:3000`. `docs/https-for-local-development.md` still says `:3001` through `local-ssl-proxy` |
| TIX-GROWTH-NEXT-FE | `.env.local`: `SSL_KEY_FILE`/`SSL_CERT_FILE` (already set in `.env.local.example`) | `pnpm dev` = `next dev --webpack --experimental-https …`. `pnpm start` adds `local-ssl-proxy` 3001 → 3000. Playwright's own web server runs plain HTTP `next dev -p 3000` | `https://local.tiket.com:3000` |
| TIX-PASSPORT | hard-coded in `package.json` `dev:https` | `npm run dev:https` = Storybook `--https --host local.tiket.com --ssl-cert local.tiket.com.pem --ssl-key local.tiket.com-key.pem` | `https://local.tiket.com:6006`. Plain `npm run dev` stays on HTTP |
| TIX-REACT-REMOTE | `.env`: `SSL_KEY_FILE`, `SSL_CERT_FILE` (from `.env.example`) | `pnpm ssl-proxy` = `local-ssl-proxy` 3005 → 3004 | optional. The dev server itself is plain HTTP on 3003 |

You can use another subdomain by generating a cert for it and pointing `SSL_KEY_FILE`/`SSL_CERT_FILE` at it (fintech-fe doc). On this machine TIX-PASSPORT also has a `dev.tiket.com` pair, which no script references.

## Troubleshooting
- **Port stuck after a crash:** `kill -9 $(lsof -ti:3000,3001)` (fintech-fe doc).
- **Browser warns about the certificate:** the mkcert CA isn't installed in that browser or profile. Run `mkcert -install` again. Certificates from another machine's CA are not trusted here.
- **Cookies missing on `localhost`:** use `local.tiket.com`, not `localhost`.
- **CORS errors from backends:** fintech-fe suggests Chrome with `--disable-web-security` ([[fintech-fe-workflows]]).
- Certificates expire. Check with `openssl x509 -in local.tiket.com.pem -noout -enddate`.

## Sources
- TIX-FINTECH-NEXT-FE `docs/https-for-local-development.md`, `package.json` (`dev`, `ssl-proxy`, `start`), `.env.local.example`, `.gitignore`
- TIX-NEXT-PAYMENT-FE `package.json`, `.env.local.example`, `next.config.ts` (`allowedDevOrigins`), `.gitignore`, `AGENTS.md`
- TIX-HOMEPAGE-NEXT-FE `package.json` (`dev`, `start`), `.env.local.example`, `next.config.ts` (`allowedDevOrigins`), `.gitignore`, `docs/https-for-local-development.md`
- TIX-GROWTH-NEXT-FE `package.json` (`dev`, `ssl-proxy`, `start`), `.env.local.example`, `playwright.config.ts`, `.gitignore`
- TIX-PASSPORT `package.json` (`dev:https`), `.gitignore`
- TIX-REACT-REMOTE `package.json` (`ssl-proxy`), `.env.example`, `.gitignore`
- TIX-REACT-COMMON `packages/react-common-env/src/getEnvironment.ts`
- Local working trees on 2026-10-16: mkcert certificates for `local.tiket.com` in TIX-PASSPORT, TIX-NEXT-PAYMENT-FE and TIX-FINTECH-NEXT-FE, and for `dev.tiket.com` in TIX-PASSPORT (`openssl x509 -noout -issuer -ext subjectAltName`)

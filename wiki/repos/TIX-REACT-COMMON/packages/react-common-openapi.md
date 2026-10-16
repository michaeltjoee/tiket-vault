---
title: react-common-openapi
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-openapi"
sources:
  - packages/react-common-openapi/script
  - packages/react-common-openapi/services
  - packages/react-common-openapi/package.json
  - packages/react-common-openapi/openapitools.json
  - packages/react-common-openapi/README.md
  - packages/react-common-openapi/CONTRIBUTING.md
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-openapi
> Generated `typescript-fetch` API clients for a few backend services (promocode, discount-engine, gift-voucher), built from whitelisted Swagger specs with openapi-generator-cli.

## What it does
Each service lives under `services/<service>/<version>/` with a `spec.json` (whitelisted paths plus the upstream swagger URL) and a merged `spec.swagger.json`. `merge-spec` (`script/merge-spec.js`) fetches the upstream swagger and keeps only whitelisted paths and the definitions they `$ref`. `build` runs `generate-spec.sh` (`openapi-generator-cli generate -g typescript-fetch --additional-properties=useSingleRequestParameters=true`) and `move-shared-files.sh` (deduplicates `runtime.ts` into `shared/`, rewrites imports, hard-codes `BASE_PATH`), then compiles with `tsc` into `lib/`. Consumers create a `Configuration` with their own `fetchApi` and instantiate the controllers. There is no hand-written runtime code. See [[openapi-codegen]].

## Public API
No root export (`main: lib/cjs/index.js` is not produced by the scripts). Import by deep path:
- `@tiket/react-common-openapi/lib/services/promocode/v1`: `PromoCodeControllerApi`, `PromoLinkControllerApi`, `PromoCodeDataAddQuotaControllerApi`, `BusinessLogicResponseControllerApi`…
- `@tiket/react-common-openapi/lib/services/discount-engine/v1`, `.../gift-voucher/v1`
- `@tiket/react-common-openapi/lib/shared/runtime`: `Configuration`, `BASE_PATH`

## Usage
```ts
import { PromoCodeControllerApi } from '@tiket/react-common-openapi/lib/services/promocode/v1';
import { Configuration } from '@tiket/react-common-openapi/lib/shared/runtime';

const config = new Configuration({
  basePath: '',
  fetchApi: (info, init) => fetch(info as string, { ...init }), // plug in the app's own fetch
});
const promoCode = new PromoCodeControllerApi(config);
```
(from README; reference consumer there is TIX-DISCOUNT-DASH-NEXT-FE, which is outside this workspace)

## Depends on
Dev only: `@openapitools/openapi-generator-cli` ^2.7 (needs a **Java** runtime; the version is pinned in `openapitools.json`), `commander`, `typescript`.

## Used by
No consumer in the six workspace repos on baseline.

## Gotchas
- `build.sh` **skips codegen with a warning** when Java or the generator jar is missing, unless `CI` is set (then it fails). The GitHub release workflows install JDK 11 for this reason. A local `pnpm build` may therefore skip this package silently.
- `BASE_PATH` in the shared runtime is rewritten to `https://gatotkaca.tiket.com/gateway` (staging). Always pass `basePath` explicitly.
- `generate-spec.sh` loops three directory levels (`services/*/*/*/`), but the tree has two (`services/<svc>/v1`). It only works because an unmatched glob in `sh` is left as a literal. Keep the layout as is, or fix the script.
- Excluded from root Jest projects and from Sonar.

## Sources
- packages/react-common-openapi/script/{build.sh,generate-spec.sh,merge-spec.js,move-shared-files.sh}
- packages/react-common-openapi/services/*/v1/spec.json
- packages/react-common-openapi/package.json, openapitools.json, README.md, CONTRIBUTING.md

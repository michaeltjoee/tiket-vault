---
title: Structured diagnostic logging (SDC)
kind: concept
repos: [TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-HOMEPAGE-NEXT-FE, TIX-GROWTH-NEXT-FE]
sources:
  - TIX-NEXT-PAYMENT-FE/lib/logger/index.ts
  - TIX-NEXT-PAYMENT-FE/lib/helpers/coreFetcher.ts
  - TIX-FINTECH-NEXT-FE/lib/logger/index.ts
  - TIX-FINTECH-NEXT-FE/docs/data-fetching.md
  - TIX-HOMEPAGE-NEXT-FE/lib/utils/constructLoggerData/index.tsx
  - TIX-HOMEPAGE-NEXT-FE/lib/services/HomeServices.ts
  - TIX-GROWTH-NEXT-FE/lib/logger/index.ts
verified_at:
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-HOMEPAGE-NEXT-FE: 408983f6
  TIX-GROWTH-NEXT-FE: d4162e3
updated: 2026-10-16
status: current
tags: [kind/concept, repo/payment-fe, repo/fintech-fe, repo/homepage-fe, repo/growth-fe]
---

# Structured diagnostic logging (SDC)
> The Next apps attach a "Structured Diagnostic Context" to every service call's log, so Kibana can search requests by account, email, correlation id or order id. The helper is `standardizedLogData`, and it is passed to the `@tiket/next` fetch client as `sendStandardizedLogData`.

## Pattern
```ts
fetchClient(url, { ..., sendStandardizedLogData: () => standardizedLogData({ sdc: { orderId } }) });
```
- `lib/logger/index.ts` exports `standardizedLogData({ cookies?, sessionData?, url?, sdc?, ...rest })` in payment-fe, fintech-fe and growth-fe. homepage-fe has no `lib/logger`: its services build the SDC with `constructSdc({ url, accountId, code })` from `lib/utils/constructLoggerData`, which also sets `isConsumerFe: true`. It returns the message, the SDC fields and a `document` block (URL, referrer).
- On the client it reads middleware data from `window.__NEXT_DATA__.props.pageProps.middlewareData` to get the correlation id, so callers don't pass it down.
- On the server it takes `cookies`, `sessionData` and `url` (for example `ctx.resolvedUrl`).
- Usage: about 30 files in payment-fe, 27 in fintech-fe, 7 in homepage-fe and 9 in growth-fe pass `sendStandardizedLogData`. payment-fe's `coreFetcher`, the [[passport-custom-fetch]] for Passport widgets, sends it on every call. fintech-fe's `docs/data-fetching.md` makes it the rule for every service fetch and links the Confluence SDC page.

Logs end up in Kibana. payment-fe's metrics are in Grafana (`service_name=next-payment-fe`). See [[payment-fe-workflows]] and [[fintech-fe-architecture]].

## Gotchas
- The client path depends on `__NEXT_DATA__`, which only Pages Router pages have. In App Router client code the middleware data is missing unless passed in.
- growth-fe's story detail page passes only `{ locale }` as `middlewareData`, so its logs carry no account id ([[growth-fe-stories]]).
- `@tiket/next` owns the transport (`postLogPOST` on `/api/post-log`), and its source is not in the workspace ([[tiket-next-core]]).
- Use `filterOutRequestBodyInLogs` (fintech-fe filters `password` by default) for sensitive bodies.

## Where it shows up
Pages that link here:
- TIX-FINTECH-NEXT-FE: [[fintech-fe-architecture]]
- TIX-GROWTH-NEXT-FE: [[growth-fe-app-shell]], [[growth-fe-architecture]]
- TIX-HOMEPAGE-NEXT-FE: [[homepage-fe-architecture]]
- concepts: [[passport-custom-fetch]], [[tiket-next-core]]

## Sources
- TIX-NEXT-PAYMENT-FE `lib/logger/index.ts`, `lib/helpers/coreFetcher.ts`, `app/api/post-log/route.api.ts`, `README.md`
- TIX-FINTECH-NEXT-FE `lib/logger/index.ts`, `lib/fetch/fetch.ts`, `docs/data-fetching.md`
- TIX-HOMEPAGE-NEXT-FE `lib/utils/constructLoggerData/index.tsx`, `lib/services/HomeServices.ts`
- TIX-GROWTH-NEXT-FE `lib/logger/index.ts`, `pages/stories/[type]/[slug]/index.page.tsx`
- Counts: `git grep -l sendStandardizedLogData origin/main` (specs excluded)

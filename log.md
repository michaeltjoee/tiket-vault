# Log

Append-only. Format: `## [YYYY-MM-DD] op | summary`. Newest last.

## [2026-10-16] init | vault skeleton + schema (CLAUDE.md), baselines: passport 7a33010aca, react-common 14597c4e (master), react-remote 281778b, payment-fe 9e92b20bb, fintech-fe 5833b842, gtm-extras 98478af

## [2026-10-16] build | full first build: 235 pages (TIX-PASSPORT 134, TIX-REACT-COMMON 21, TIX-REACT-REMOTE 17, TIX-NEXT-PAYMENT-FE 10, TIX-FINTECH-NEXT-FE 11, TIX-GTM-EXTRAS 8, plus 34 cross-repo)
- concepts: 22, entities: 5, howto: 6, decisions: 1
- remaining link gaps: payment-fe-smart-pay (no unit page for the Pages Router /smart_pay feature), openapi-codegen (single-repo, no consumers)
- link pass: passport-passport → passport-umbrella, changesets-release-flow → changesets-fixed-versioning; insurance-popup-api → tix-insurance-core#Popup display API; passport-design-system → passport-overview; parcel-bundling unlinked; gtm-extras-overview linked from all GTM pages; passport-workflows scaffold step corrected (create:component already wires the umbrella)
- ingest: raw/notes/2026-10-16-squash-merge-prerelease-skill.md (snapshot of the squash-merge-prerelease skill) → prerelease-squash-merge
- first run hit the session limit; resumed same day

## [2026-10-16] ingest | add TIX-HOMEPAGE-NEXT-FE (homepage-fe) @ 408983f6: 14 pages (overview, architecture, workflows, 10 features, components)
- schema + ~/.claude/CLAUDE.md + wiki-sync scan.sh now include the repo (unit roots: pages/, app/)

## [2026-10-16] update | payment-fe + fintech-fe: cover Pages Router `pages/` trees (missed by first build)
- new [[payment-fe-smart-pay]]; rewrote router sections of [[payment-fe-architecture]], [[payment-fe-overview]], [[payment-fe-payment]], [[fintech-fe-architecture]]
- AGENTS.md in TIX-NEXT-PAYMENT-FE is wrong on main: says Next 14 App Router only, actual Next 16.3.6 hybrid with /payment and /smart_pay on Pages Router
- schema: documented cross-repo `verified_at` map + `REPO/path` sources convention

## [2026-10-16] update | payment-fe: smart_pay coachmark cookie domain gotcha
- [[payment-fe-smart-pay]]: `coachmark` cookie set on both `.tiket.com` and host-only; js-cookie returns the first match, so Krom (prerelease) shows the coachmark on a stale BLU cookie
## [2026-10-16] ingest | add TIX-GROWTH-NEXT-FE (growth-fe) @ d4162e3: 11 pages (overview, architecture, workflows, 8 features)
- schema: repo table row; wiki-sync `scan.sh` unit roots (`pages app`)
- notable on main: open redirect in `isRedirectWhitelistDomain` (metasearch), committed `sonar.login` token, stories landing/tag bugs, Passport pinned at 8.0.0
## [2026-10-16] update | split index.md into generated per-repo indexes loaded by a SessionStart hook
- New `scripts/build-index.py` (`--check`), `scripts/commit.sh`, `scripts/session-index.sh`. Index files are generated: root `index.md`, `wiki/shared-index.md`, `wiki/repos/<REPO>/<slug>-index.md`, and the `passport-packages` table rows.
- Passport session index drops the 130 package lines (naming rule + catalog link). Session load: 53 KB → 3.7–12.6 KB depending on repo.
- `umbrella: true` added to 98 Passport package pages (matches `packages/passport/package.json` at 7a33010aca); catalog `passport-button-slider` purpose fixed (was a wrong description).
- `> ` summary lines added to payment-fe-workflows, gtm-extras-workflows, react-remote-architecture, react-remote-workflows, fintech-fe-workflows.
- TIX-HOMEPAGE-NEXT-FE (408983f6) and TIX-GROWTH-NEXT-FE (d4162e3) added to `repos:` of 23 shared pages, verified against origin/main.
- Schema (CLAUDE.md) updated: generated layer, required `> ` line, `umbrella:` field, `kind/index`, commit via `scripts/commit.sh`.
## [2026-10-16] update | payment-fe-payment — reopen gate (payment persistence): status mapping, BE reset via /v4/landing, stale-landing sessionStorage marker, check-status cooldown
## [2026-10-16] update | payment-fe-smart-pay — two unlink paths per method (tile vs detail page), DANA hook; gotchas: detail-page OneKlik unlink hits /tix-payment-core/undefined, legacy order_id card return never clears loading
## [2026-10-19] update | homepage-fe-architecture — request flow corrected (no route prefetches page data for humans; voucher-box awaits serially); new cross-page gotchas: guest userId "undefined", services never throw, soft 404s/no Cache-Control, preview auth/noindex, test entries in customCanonicalLink

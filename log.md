# Log

Append-only. Format: `## [YYYY-MM-DD] op | summary`. Newest last.

## [2026-10-16] init | vault skeleton + schema (CLAUDE.md), baselines: passport 7a33010aca, react-common 14597c4e (master), react-remote 281778b, payment-fe 9e92b20bb, fintech-fe 5833b842, gtm-extras 98478af

## [2026-10-16] build | full first build: 235 pages (TIX-PASSPORT 134, TIX-REACT-COMMON 21, TIX-REACT-REMOTE 17, TIX-NEXT-PAYMENT-FE 10, TIX-FINTECH-NEXT-FE 11, TIX-GTM-EXTRAS 8, plus 34 cross-repo)
- concepts: 22, entities: 5, howto: 6, decisions: 1
- remaining link gaps: payment-fe-smart-pay (no unit page for the Pages Router /smart_pay feature), openapi-codegen (single-repo, no consumers)
- link pass: passport-passport → passport-umbrella, changesets-release-flow → changesets-fixed-versioning; insurance-popup-api → tix-insurance-core#Popup display API; passport-design-system → passport-overview; parcel-bundling unlinked; gtm-extras-overview linked from all GTM pages; passport-workflows scaffold step corrected (create:component already wires the umbrella)
- ingest: raw/notes/2026-10-16-squash-merge-prerelease-skill.md (snapshot of the squash-merge-prerelease skill) → prerelease-squash-merge
- first run hit the session limit; resumed same day

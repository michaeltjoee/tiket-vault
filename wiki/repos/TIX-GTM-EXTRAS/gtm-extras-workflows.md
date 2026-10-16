---
title: TIX-GTM-EXTRAS workflows
repo: TIX-GTM-EXTRAS
kind: workflows
sources:
  - README.md
  - gulpfile.js
  - package.json
  - build
verified_at: 98478af
updated: 2026-10-16
status: current
tags: [repo/gtm-extras, kind/workflows]
---

# TIX-GTM-EXTRAS workflows

Part of [[gtm-extras-overview]].

## Build
`npm run build` runs the single gulp task `bundle`:
1. `gulp.src(["scripts/helpers.js", "scripts/tiktok-init.js", "scripts/fb-pixel-tag.js", "scripts/**/*.js"])`. The three named files go first, then the rest alphabetically (gulp de-duplicates the repeats).
2. `jsvalidate` (syntax check only), `concat("index.js")`, `uglify` (console kept), `iife()` (one wrapper around everything, `"use strict"`), and a prepended `/*Last update: <date>*/` comment.
3. Output goes to `build/index.js`. Commit it, because the pipeline uploads this committed file.

Resulting execution order: helpers → tiktok-init → fb-pixel-tag → fb-search-hotel → fb-search-tag → fb-viewcontent-flight-search → fb-viewcontent-hotel → fb-viewcontent → handle-polaris-session-source → optimize-create-variables → seo-ahrefs → temp-tag-gtm-hotel-data-completion → tiktok-initiatecheckout → tiktok-search → tiktok-viewcontent-flight → tiktok-viewcontent-hotel → tiktok-viewcontent.

## Local check
Open `build/index.html` (it only includes `index.js`). Most scripts exit early without the `window.gtm` data a real tiket page provides, so real testing happens on the TEST environment.

## Release and deploy (README)
1. Merge the feature branch into `main`.
2. Create a branch named `release` from `main`.
3. Run `npm version`, create a tag (e.g. `v1.1.0`) and open a PR to `main`.
4. Follow the QA deployment SOP.
5. Announce in `#ask-tracking` before deploying, since the bundle affects all analytics.

Jenkins jobs (`TIX-CORE-GTM-EXTRAS`): GK/TEST `gk-k8s-jenkins.ggwp.red/job/TEST/...`, PREPROD `preprod-k8s-jenkins.ggwp.red/job/PROD/...`, PROD `prod-k8s-jenkins.ggwp.red/job/PROD/...`. The Jenkinsfile is not in this repo.

## Gotchas
- Tags `v1.1.0` and `v1.2.0` exist, but `package.json` on `main` still says `1.0.0`. The version bump from the release branch does not always reach `main`.
- `build/index.js` at `98478af` has the header `Last update: Mon Jul 13 2026`, although #34 (19 Aug 2026) edited it. The header records when someone last ran the build, not when the file was committed. Check the bundle content, not the header, to confirm a change is in.
- There is no CI build or lint. A stale or hand-edited `build/index.js` will deploy as-is.
- All scripts share one IIFE. An uncaught exception in one script stops every script after it in the order above (see [[gtm-extras-helpers#Gotchas]]).

## Sources
- README.md
- gulpfile.js
- package.json
- build/index.js
- build/index.html

# tiket workspace wiki: schema

This vault follows Karpathy's LLM Wiki pattern. It is a knowledge base about the repos in `~/tiket-workspaces/` listed below, and an LLM agent maintains it. The human curates the sources and asks the questions. The agent writes and maintains every page under `wiki/` and `log.md`. A script generates the index files.

Vault root: `/Users/michael.tjoe/Library/Mobile Documents/iCloud~md~obsidian/Documents/tiket-passport/passport`. This path has spaces, so always quote it in a shell.

## Layers

| Path | Owner | Rule |
|---|---|---|
| `raw/` | human | Sources that are not in the repos: `jira/`, `confluence/`, `slack/`, `notes/`, `assets/`. **Never edit or delete anything here.** You may add a new file during an ingest (a dated snapshot with its source URL). |
| `wiki/` | agent | Compiled knowledge. Every claim in it traces to code (repo path + SHA), a repo doc, or a `raw/` file. |
| `index.md`, `wiki/shared-index.md`, `wiki/repos/<REPO>/<slug>-index.md` | script | **Generated** by `scripts/build-index.py` from each page's frontmatter and `> ` line (frontmatter `generated: true`). Never edit them. The root index lists the repos. A repo index lists that repo's pages, the shared pages tagged for it, and the other repos. The shared index lists every concept, entity, decision and how-to. The script also writes the table rows of [[passport-packages]]. |
| `scripts/` | agent | `build-index.py [--check]`, `commit.sh` (regenerate + commit), `session-index.sh` (SessionStart hook that prints the repo index for the session's repo). |
| `log.md` | agent | Append-only. One entry per ingest, update or lint. Newest entry goes last. |
| `CLAUDE.md` | human + agent | This file. Change it only when the human agrees to a new convention. `AGENTS.md` is a symlink to it. |

Code is **not** copied into `raw/`. The repos are the source of truth for code. Cite them instead.

## Repos and baseline branches

The wiki describes each repo's **baseline branch**. It never describes the local checkout, which may be on a feature branch.

| Repo | Slug | Baseline | Page unit | Unit folder |
|---|---|---|---|---|
| TIX-PASSPORT | `passport` | `origin/main` | one page per `packages/*` | `packages/` |
| TIX-REACT-COMMON | `react-common` | `origin/master` | one page per `packages/*` | `packages/` |
| TIX-REACT-REMOTE | `react-remote` | `origin/main` | one page per `src/components/*` | `components/` |
| TIX-NEXT-PAYMENT-FE | `payment-fe` | `origin/main` | one page per route feature under `app/`; one page for all of `components/` | `features/` |
| TIX-FINTECH-NEXT-FE | `fintech-fe` | `origin/main` | one page per route feature under `app/`; one page for all of `components/` | `features/` |
| TIX-GTM-EXTRAS | `gtm-extras` | `origin/main` | one page per vendor (fb, tiktok, polaris, ahrefs, optimize…) over `scripts/` | `vendors/` |
| TIX-HOMEPAGE-NEXT-FE | `homepage-fe` | `origin/main` | one page per route feature under `pages/` (and `app/api`); one page for all of `components/` | `features/` |
| TIX-GROWTH-NEXT-FE | `growth-fe` | `origin/main` | one page per route feature under `pages/` (API routes in `app/api` + `pages/api` share one page); one page for all of `components/` | `features/` |

Read code without touching the working tree:

```sh
git -C ~/tiket-workspaces/<REPO> fetch origin --quiet
git -C ~/tiket-workspaces/<REPO> rev-parse --short origin/<baseline>     # → verified_at
git -C ~/tiket-workspaces/<REPO> ls-tree -r --name-only origin/<baseline> -- <dir>
git -C ~/tiket-workspaces/<REPO> show origin/<baseline>:<path>
git -C ~/tiket-workspaces/<REPO> grep -n <pattern> origin/<baseline> -- <pathspec>
```

Never run `checkout`, `switch`, `reset`, `stash` or `pull` in the repos. Something that exists only on a branch goes on a page with `status: branch-only` and the branch name in `branch:`.

## Folder layout

```
wiki/
  repos/<REPO>/
    <slug>-index.md           generated: this repo's pages, its shared pages, other repos
    <slug>-overview.md        what the repo is, who consumes it, tech stack, commands
    <slug>-architecture.md    structure, build/bundling, data flow, key internal seams
    <slug>-workflows.md       dev, test, release, CI, branching for this repo
    <unit folder>/<slug>-<unit>.md
  concepts/    ideas that cross repos (module federation, design tokens, changesets fixed versioning…)
  entities/    services, APIs, teams, external vendors, Jira epics
  decisions/   ADR-style "we chose X because Y" (date, context, decision, consequences)
  howto/       runbooks: step-by-step procedures someone can follow
  shared-index.md   generated: every concepts/entities/decisions/howto page
```

## Naming and links

- **Filenames are unique across the whole vault.** They use lowercase kebab-case and are prefixed with the repo slug: `passport-button.md`, `react-common-fetch.md` (the repo's own name prefix is dropped once), `payment-fe-downpay.md`, `gtm-extras-tiktok.md`. Pages outside `repos/` have no slug prefix: `module-federation.md`.
- Link with bare `[[filename]]` without `.md`, or `[[filename|label]]`. Obsidian resolves a bare link because filenames are unique.
- Mention a package or another page only when you link it. A link to a page that doesn't exist yet is allowed: it marks a gap, and lint reports it.
- Tags: `#repo/<slug>`, `#kind/<package|component|feature|vendor|overview|architecture|workflows|concept|entity|decision|howto|index>` (`index` is for generated files only).

## Page frontmatter (required on every wiki page)

```yaml
---
title: Button
repo: TIX-PASSPORT            # omit on concepts/entities/decisions/howto that span repos; use repos: [..] instead
kind: package                 # see tags list
npm: "@tiket/passport-button" # for library units
umbrella: true                # Passport packages only: re-exported by @tiket/passport (feeds the catalog U column)
sources:                      # repo-relative paths (dirs ok) this page was built from
  - packages/button/src
  - packages/button/package.json
verified_at: 7a33010aca       # short SHA of origin/<baseline> when sources were last read
updated: 2026-10-16
status: current               # current | stale | branch-only | deprecated
tags: [repo/passport, kind/package]
---
```

Every page needs a `> ` summary line right under its `# Title`: one or two sentences. It becomes the page's line in the generated indexes, so keep it accurate when the page changes.

Pages that span repos (concepts, entities, howto, decisions) put `repos: [..]` in place of `repo:`, and a map for `verified_at`. Their `sources` entries get a `<REPO>/` prefix:
```yaml
sources:
  - TIX-REACT-REMOTE/webpack.config.js
  - TIX-PASSPORT/docs/publishing.md
verified_at:
  TIX-REACT-REMOTE: 281778b
  TIX-PASSPORT: 7a33010aca
```

## Page templates

**Library unit (package / remote component):**
```
# <Title>
> One-sentence purpose.

## What it does        2–5 sentences, written for someone about to use it
## Public API          exported components/hooks/functions/types, key props (table if many)
## Usage               one minimal, real example taken from source, stories or tests
## Depends on          [[links]] to internal packages; notable external deps
## Used by             [[links]] to consumers in other repos (from git grep on baselines)
## Gotchas             non-obvious behavior, SSR/CSR caveats, deprecated props. Omit if none
## Sources             bullet list of repo paths
```

**App feature:** `What it does` / `Routes & entry points` / `Data & services` (APIs, contexts, queries) / `Key components` / `Tracking` / `Tests` / `Gotchas` / `Sources`.

**Overview / architecture / workflows / concept / howto / decision:** use whatever headings fit, but keep the frontmatter and finish with a `Sources` section.

Style: write in plain, factual English, as short as possible while staying complete. Don't pad, and don't use marketing tone. Don't restate what the code says plainly. Explain what a reader would otherwise have to dig out themselves.

## Operations

### Query (reading the wiki during a task)
1. Start from the repo index (the SessionStart hook prints it; otherwise read `wiki/repos/<REPO>/<slug>-index.md`). For a task that crosses repos, also read `wiki/shared-index.md` or the other repo's index. Open any `[[name]]` with `find wiki -name '<name>.md'`.
2. **Staleness check:** for each page you rely on, run `git -C <repo> log --oneline <verified_at>..origin/<baseline> -- <sources…>`. If it shows any commits, treat the page as a hint and confirm against the code.
3. If the answer is worth keeping (a synthesis, comparison or non-obvious fact), file it as a wiki page or a section on an existing page.

### Update (after normal work in a repo)
Write to the wiki when the task taught you something **that isn't obvious from the code**: a gotcha, a decision and its reason, a dependency between repos, a fix for a flaky test, a quirk of the release or tooling, a constraint from a human. Don't write anything that reading the code reveals immediately.
1. Edit the matching page, or create one from the template. Bump `updated`. Bump `verified_at` only if you re-read its sources. Keep the `> ` line accurate. A shared page lists in `repos:` every repo it covers, because that decides which repo indexes show it.
2. Append to `log.md`.
3. Commit with `scripts/commit.sh` (see Git). It regenerates the indexes.
4. Tell the human in one line: `wiki: updated [[page]] (reason)`.

### Ingest (a new source: Jira ticket, Confluence page, Slack thread, note)
1. Save the source to `raw/<type>/YYYY-MM-DD-<slug>.md`, starting with its URL and the fetch date. If the human already put it there, leave it unchanged.
2. Read it, then create or update every page it affects: usually 1 entity or decision page, plus the repo, feature and concept pages it touches. Cite it as `raw/<type>/<file>`.
3. Append to `log.md` and commit with `scripts/commit.sh`.

### Lint (when the human asks)
For staleness and coverage of one repo, use the `wiki-sync` skill. Its `~/.claude/skills/wiki-sync/scan.sh <repo-dir>` lists stale, missing and uncovered pages. The checks below that it doesn't cover (links, orphans, contradictions) belong to a full lint.
Report first. Fix only what the human approves, or fix everything if they said "fix".
- **Stale:** pages whose `sources` changed since `verified_at` (check with `git log`). Refresh them and bump `verified_at`.
- **Missing:** units on the baseline that have no page (packages, components or features that were added), and pages whose units were removed (mark them `deprecated`).
- **Links:** broken `[[links]]` (gaps), orphans (pages with no inbound link besides the generated indexes and [[passport-packages]]), and concepts mentioned on three or more pages that have no page of their own.
- **Contradictions** between pages.
- **Frontmatter:** fields missing or invalid, and pages without a `> ` line (`scripts/build-index.py` prints a `WARN` for each).
- **Indexes:** `python3 scripts/build-index.py --check` exits 1 if a generated file is out of date.

## log.md format

```
## [2026-10-16] update | passport-button — focus ring gotcha with focus-trap
## [2026-10-16] ingest | raw/jira/2026-10-16-plat-59766.md → payment-fe-insurance, insurance-popup
## [2026-10-16] lint | 12 stale, 3 missing, 5 broken links; fixed all
```
Each entry is a single `## [date] op | summary` line, optionally followed by bullet lines. `grep '^## \[' log.md | tail` shows recent activity.

## Git

The vault is a local git repo with no remote. After each update, ingest or lint, commit with:
`"<vault root>/scripts/commit.sh" "wiki: <op> <short summary>" ["<more paragraphs>" ...]`.
It runs `scripts/build-index.py`, then `git add -A && git commit`. Each argument is one `-m` paragraph. Don't commit with plain `git commit`, or the indexes fall out of date. Git hooks are not used, because the global `core.hooksPath` points to `~/.signals/hooks` (git-ai), which skips the vault's `.git/hooks`.
Never add a remote or push. The vault holds internal company knowledge.

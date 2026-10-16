---
title: Squash-merge a PR into prerelease
kind: howto
repos: [TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE, TIX-REACT-REMOTE]
sources:
  - raw/notes/2026-10-16-squash-merge-prerelease-skill.md
  - TIX-NEXT-PAYMENT-FE/.github/workflows/prerelease.yml
  - TIX-NEXT-PAYMENT-FE/README.md
  - TIX-FINTECH-NEXT-FE/.github/workflows/prerelease.yml
verified_at:
  TIX-NEXT-PAYMENT-FE: 9e92b20bb
  TIX-FINTECH-NEXT-FE: 5833b842
  TIX-REACT-REMOTE: 281778b
updated: 2026-10-16
status: current
tags: [kind/howto, repo/payment-fe, repo/fintech-fe, repo/react-remote]
---

# Squash-merge a PR into prerelease
> Put a feature branch on the long-lived `prerelease` branch as **one** commit, done locally with git rather than the GitHub merge button. Then refresh the "Included PRs" list in the open `prerelease` → `main` PR. The user's Claude skill `squash-merge-prerelease` automates this.

## When this applies
Repos with a long-lived `origin/prerelease` ahead of `main`: TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE and TIX-REACT-REMOTE. TIX-PASSPORT has no `prerelease` branch (it uses snapshot labels), and TIX-REACT-COMMON resets its `prerelease` to `master` after every release ([[prerelease-flow]]).

In payment-fe and fintech-fe the `prerelease` → `main` PR carries the label `Automate Pre-Release`. Each push to `prerelease` updates that PR, which triggers `prerelease.yml` to tag `vX.Y.Z-alpha.N` for staging. This trigger chain is inferred from the workflow triggers (`pull_request: synchronize`) and the payment-fe README, not from a repo doc.

## Steps
1. **Preflight.** `git status --porcelain` must be empty. Run `git fetch origin --prune` and note the current branch. Find the source: `gh pr view <N> --json number,title,headRefName,url` gives `origin/<headRefName>`. Never use `prerelease` or `main` as the source. If the local branch is ahead of its remote, decide whether unpushed commits should be included.
2. **Get `prerelease`.** If `origin/prerelease` exists, `git switch prerelease` (or `git switch -c prerelease --track origin/prerelease`) and `git merge --ff-only origin/prerelease`. If the fast-forward fails, stop: local `prerelease` has diverged. Only if no `prerelease` exists anywhere, create it with `git switch -c prerelease origin/main`.
3. **Squash.** `git merge --squash <source>`.
   - Conflicts: resolve and `git add`. `git diff --check` must be clean. A common cause is a branch that was squashed in before. Prefer the source branch's version.
   - If nothing is staged (`git diff --cached --quiet`), the changes are already on `prerelease`. Switch back and stop.
4. **Commit exactly once.** The subject is the PR title plus ` (#<number>)`, e.g. `feat(PLAT-123): add trip view (#1428)`, and the body is `PR: <url>`. Never use `--no-verify`: fix hook failures. Check with `git rev-list --count origin/prerelease..prerelease`, which should print `1`.
5. **Push** after a final look at `git show --stat HEAD`: `git push origin prerelease` (`-u` if newly created). **Never force-push `prerelease`.** If the push is rejected, `git fetch && git rebase origin/prerelease`, re-check and push again.
6. **Refresh "Included PRs".** Find the PR with `gh pr list --base main --head prerelease --state open --json number`. If none is open, skip this step and don't create one. Rebuild the list from `git log --reverse --no-merges --format='%h%x09%s' origin/main..origin/prerelease`: one line per PR, `- #<n> <subject without (#n)>`, and `- <sha> <subject>` for commits without a PR number. Replace only the `## Included PRs` section at the top of the body (and any leading legacy `PR: <url>` lines) with `gh pr edit <PR> --body-file …`. The step is idempotent.
7. **Clean up:** `git switch <original branch>`.

## Don't
- Merge `prerelease` back into the feature branch or into `main`.
- Rewrite `prerelease` history.
- Close or merge the feature PR. It stays open against its own base.
- Edit any part of the `prerelease` PR description other than "Included PRs".
- Squash `feat/page-module-next-poc` anywhere ([[page-module-next-poc]]).

## Notes
- Existing `prerelease` history doesn't follow the `(#n)` convention yet. None of the commits ahead of `main` in the three repos on 2026-10-16 end in `(#n)`, so the list falls back to `sha subject` lines for them.
- react-remote's `prerelease` can also receive automatic "chore: update passport prerelease <version>" commits from Passport's `Auto Install Pre-Release in React Remote` job (the last ones date from June 2026), plus `npm version prerelease` commits such as `2.0.29-2` ([[passport-workflows]]).

## Sources
- `raw/notes/2026-10-16-squash-merge-prerelease-skill.md` (snapshot of the skill)
- TIX-NEXT-PAYMENT-FE `.github/workflows/prerelease.yml`, `README.md` (Deployment); TIX-FINTECH-NEXT-FE `.github/workflows/prerelease.yml`
- `git log origin/main..origin/prerelease` in TIX-NEXT-PAYMENT-FE, TIX-FINTECH-NEXT-FE and TIX-REACT-REMOTE (2026-10-16)

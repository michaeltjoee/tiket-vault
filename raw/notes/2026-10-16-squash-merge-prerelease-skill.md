Source: ~/.claude/skills/squash-merge-prerelease/SKILL.md (Claude Code user skill on michael.tjoe's machine)
Fetched: 2026-10-16

---

---
name: squash-merge-prerelease
description: Locally squash-merge a PR / feature branch into the `prerelease` branch as exactly one commit, creating `prerelease` from `main` if it does not exist, then refresh the "Included PRs" list in the open `prerelease` → `main` PR description. Use when the user says "squash merge to prerelease", "merge my PR to prerelease", "put this branch on prerelease", or invokes /squash-merge-prerelease.
---

# Squash-merge into `prerelease`

Goal: land a PR's changes on `prerelease` as **one** commit, done locally with git
(not via the GitHub merge button), push, then list it in the `prerelease` → `main` PR description.

Input (optional): a PR number, a branch name, or nothing (= current branch).

## 1. Preflight

```bash
git status --porcelain          # must be empty — otherwise stop and ask (stash/commit?)
git fetch origin --prune
ORIGINAL=$(git branch --show-current)
```

Resolve the source branch `SRC`:

| Input        | How                                                                                                           |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| PR number    | `gh pr view <N> --json number,title,headRefName,baseRefName,url` → `SRC=origin/<headRefName>`                  |
| Branch name  | `SRC=origin/<branch>` if it exists on remote, else local `<branch>`                                           |
| Nothing      | `SRC=$ORIGINAL`; also try `gh pr view --json number,title,url` to find its PR (may not exist — that's fine)   |

Refuse if `SRC` is `prerelease` or `main`.

If the local branch is ahead of its remote, warn that unpushed commits **will** be included
(local) or **won't** be (when using `origin/<branch>`) and confirm which the user wants.

## 2. Ensure `prerelease` exists and is current

```bash
if git show-ref --verify --quiet refs/remotes/origin/prerelease; then
  git switch prerelease 2>/dev/null || git switch -c prerelease --track origin/prerelease
  git merge --ff-only origin/prerelease     # if this fails, local prerelease diverged → stop and ask
elif git show-ref --verify --quiet refs/heads/prerelease; then
  git switch prerelease                     # local-only; will be pushed with -u in step 5
else
  git switch -c prerelease origin/main      # create from main
  CREATED=1
fi
```

Tell the user explicitly when `prerelease` was created.

## 3. Squash

```bash
git merge --squash "$SRC"
```

- **Conflicts** → load `resolving-merge-conflicts`, resolve, `git add` the files. Do not
  commit with conflict markers (`git diff --check` must be clean).
  Common cause: the branch was squashed into `prerelease` before — prefer the source
  branch's version unless the user says otherwise.
- **Nothing staged** (`git diff --cached --quiet` succeeds) → changes are already on
  `prerelease`; report that, `git switch "$ORIGINAL"`, and stop.

## 4. Commit (exactly one)

Message must follow the repo's commit convention (conventional commits / commitlint if configured):

- Subject: PR title + ` (#<number>)` when a PR is known, e.g.
  `feat(ABC-123): add trip view (#1428)`. Otherwise derive a conventional subject
  from the branch name / commits.
- Body: only the PR that is being merged, as `PR: <url>`. Do not list the squashed
  commits. No PR known → leave the body out (subject only).

```bash
git commit -F <message-file>      # use a heredoc / scratchpad file for multi-line
git log --oneline -1              # verify a single new commit
git rev-list --count origin/prerelease..prerelease   # expect 1 (skip if CREATED)
```

Never use `--no-verify`. If a commit hook (e.g. Husky) fails, fix the cause and commit again.

## 5. Push (confirm first)

Show the user: source, commit subject, `git show --stat HEAD | head -40`.
Ask for confirmation, then:

```bash
git push origin prerelease            # or: git push -u origin prerelease  (when CREATED / local-only)
```

Never force-push `prerelease`. If the push is rejected (someone else pushed), do
`git fetch origin && git rebase origin/prerelease`, re-check for conflicts, confirm, push again.

## 6. Update the `prerelease` → `main` PR description

Only once the squash commit is on `origin/prerelease` (pushed in step 5, or pushed by the
user — check `git fetch origin && git rev-list --count origin/prerelease..prerelease` is 0).
No confirmation needed beyond step 5; this step only rewrites the "Included PRs" section.

```bash
PR=$(gh pr list --base main --head prerelease --state open --json number --jq '.[0].number')
```

No open PR → tell the user and skip this step (do not create one).

Rebuild the `## Included PRs` list from every commit on `prerelease` not on `main`, oldest
first, one line per PR (`- #<n> <subject without (#n)>`; commits without a PR number are
listed as `- <sha> <subject>`). The section goes at the top of the body; an existing section
and any legacy leading `PR: <url>` lines are replaced; the rest of the body is kept as is.
Safe to re-run (same input → same body).

```bash
TMP=<scratchpad dir>
git log --reverse --no-merges --format='%h%x09%s' origin/main..origin/prerelease > "$TMP/commits.tsv"
gh pr view "$PR" --json body --jq .body > "$TMP/body.md"
python3 - "$TMP" <<'EOF'
import re, sys
d = sys.argv[1]
items, seen = [], set()
for line in open(f'{d}/commits.tsv'):
    sha, subj = line.rstrip('\n').split('\t', 1)
    m = re.search(r'\s*\(#(\d+)\)$', subj)
    if m and m[1] in seen:
        continue
    if m:
        seen.add(m[1])
    items.append(f'- #{m[1]} {subj[:m.start()]}' if m else f'- {sha} {subj}')
section = '## Included PRs\n\n' + '\n'.join(items) + '\n'
body = open(f'{d}/body.md').read()
body = re.sub(r'## Included PRs\n+(?:- .*\n)*\n*', '', body)   # existing section
body = re.sub(r'\A(?:PR: \S+\n)+\n*', '', body)                  # legacy "PR: <url>" header
open(f'{d}/body.md', 'w').write(section + '\n' + body)
EOF
gh pr edit "$PR" --body-file "$TMP/body.md"
gh pr view "$PR" --json body --jq .body | head -15     # verify
```

## 7. Cleanup

```bash
git switch "$ORIGINAL"
```

Report: commit SHA, subject, whether `prerelease` was created, the push result, and the
`prerelease` PR whose description was updated (or that none is open).

## Do not

- Merge `prerelease` back into the feature branch or into `main`
- Rewrite existing `prerelease` history (no reset/force-push to the remote)
- Close or merge the GitHub PR — it stays open against its own base branch
- Edit any part of the `prerelease` PR description other than the "Included PRs" section

---
title: react-common-queue
repo: TIX-REACT-COMMON
kind: package
npm: "@tiket/react-common-queue"
sources:
  - packages/react-common-queue/src/index.ts
  - packages/react-common-queue/package.json
verified_at: 14597c4e
updated: 2026-10-16
status: current
tags: [repo/react-common, kind/package]
---

# react-common-queue
> Named "task done" signals: `add(key, promise)` registers a task, `waitFor(key)` resolves once it has finished.

## What it does
When a registered promise resolves, the module records the key and broadcasts `window.postMessage({ name: 'COMPLETED_TASK_UPDATE_EVENT_KEY', data: key }, '*')`. `waitFor` resolves at once if the key is already recorded in this module instance; otherwise it listens for that message. [[react-common-analytic]] uses it to publish `QUEUE_KEY_REACT_COMMON_ANALYTIC` and `QUEUE_KEY_REACT_COMMON_ANALYTIC_DEVICE_ATTRS_INITIALIZED`.

## Public API
- `add(key: string, promise: Promise<unknown>): void`
- `waitFor(key: string, options?: { timeout?: number }): Promise<void>`
- `COMPLETED_TASK_UPDATE_EVENT_KEY`, type `WaitForOptions`

## Usage
```ts
// TIX-NEXT-PAYMENT-FE components/SubmitPayment/index.tsx
import { QUEUE_KEY_REACT_COMMON_ANALYTIC } from '@tiket/react-common-analytic';
import { waitFor } from '@tiket/react-common-queue';
await waitFor(QUEUE_KEY_REACT_COMMON_ANALYTIC, { timeout: 5000 });
```

## Depends on
Nothing.

## Used by
- Internal: [[react-common-analytic]], [[react-common-ab-test]] (`getUserData` waits on analytic).
- TIX-NEXT-PAYMENT-FE: `components/SubmitPayment/index.tsx` ([[payment-fe-components]]).

## Gotchas
- Client only: it uses `window` directly and throws on the server.
- The completed list is per module instance. If two copies of the package are loaded and the task finished before `waitFor` is called in the other copy, the broadcast was already missed and `waitFor` hangs (or resolves on `timeout`). Keep one installed version.
- `timeout` **resolves** (it does not reject), so callers can't tell timeout from success. A rejected task never completes.
- Listeners are never removed.

## Sources
- packages/react-common-queue/src/index.ts, package.json

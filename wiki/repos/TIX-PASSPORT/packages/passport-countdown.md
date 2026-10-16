---
title: Countdown
repo: TIX-PASSPORT
kind: package
npm: "@tiket/passport-countdown"
umbrella: true
sources:
  - packages/countdown/src
  - packages/countdown/package.json
verified_at: 7a33010aca
updated: 2026-10-16
status: current
tags: [repo/passport, kind/package]
---

# Countdown
> `HH:MM:SS` boxed countdown timer, with optional tenths of a second, plus a `useCountdown` hook.

## What it does
`Countdown` fixes a target time on mount: `endOfTime` (unix **seconds**) if given, else now + `second`. If neither is given, it uses a time in the past and shows `00:00:00` without starting a timer. `useCountdown` ticks every 50 ms and calls `onCountdownEnd` once at zero. Hours aren't capped at 24, so long timers show e.g. `49:10:05`. Changing `second` or `endOfTime` remounts the inner component through `key` to reset the target.

## Public API
| Export | Notes |
|---|---|
| `Countdown` | `second?`, `endOfTime?` (unix s, wins over `second`), `onCountdownEnd?`, `bgColor?`, `textColor?`, `separatorColor?`, `showMilliseconds?`, `variant: small \| medium \| large` (desktop only, default large), `withoutBox?` |
| `useCountdown(targetTimeMs, onCountdownEnd)` | returns remaining ms |
| type `CountdownProps` | |

## Usage
```tsx
<Countdown endOfTime={order.expiredAt} onCountdownEnd={refetch} variant="small" />
const remainingMs = useCountdown(expiryMs, onEnd);
```

## Depends on
[[passport-typography]], [[passport-utils]].

## Used by
- Through the umbrella `@tiket/passport`: TIX-NEXT-PAYMENT-FE `components/Countdown/index.tsx`, `components/Timer/index.tsx`, `app/payment/components/PromoSuggestionCard/...` ([[payment-fe-components]], [[payment-fe-payment]]) and TIX-FINTECH-NEXT-FE `projects/refund/*/RescheduleCountdownTimer*`.
- Internal: 11 packages (gift-voucher, global-popup, gradient-banner, insurance, kuber-price-dynamic-banner, mission-*, page-module(-shared), pricing-promo, sidebar).

## Gotchas
- Memoize `onCountdownEnd`. It's in the interval effect's dependency list, so a new function every render restarts the interval.
- The time cells use `suppressHydrationWarning`, because SSR and client values always differ.
- `bgColor`, `textColor` and `separatorColor` are raw CSS colours, not design tokens.

## Sources
- `packages/countdown/src/Countdown.tsx`, `src/useCountdown.ts`
- `packages/countdown/package.json`

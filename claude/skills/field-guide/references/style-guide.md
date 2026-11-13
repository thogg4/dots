# Style guide

The visual and interaction system for every field guide, independent of brand. The same system serves onboarding, training and change-rollout guides. Swap the token values for the brand from the interview. Keep the structure, spacing, radii and interactions.

## Contents
- Tokens
- Type and base
- Section rhythm
- Components
- Interaction patterns (JS)

## Tokens

Define tokens by role on `:root`. The values below are neutral placeholders; replace them with the brand's.

```css
:root{
  --brand:#312E81;      /* deep brand color: headings, dark sections, primary buttons */
  --brand-xd:#1E1B4B;   /* darkest: top bar, hero base, code blocks, tooltips, toasts */
  --tint:#FFF7ED;       /* soft light section background */
  --a1:#F97316; --a1-lt:#FED7AA;   /* accent 1 + light */
  --a2:#EC4899; --a2-lt:#FBCFE8;   /* accent 2 + light (focus ring, dotted terms) */
  --a3:#22D3EE; --a3-lt:#CFFAFE;   /* accent 3 + light ("done" states, notes) */
  --ink:var(--brand-xd); --ink-2:rgba(30,27,75,.80); --ink-3:rgba(30,27,75,.68);
  --line:rgba(49,46,129,.12); --line-2:rgba(49,46,129,.22);
  --font:"<Display Font>",system-ui,-apple-system,"Segoe UI",sans-serif;
  --mono:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
  --shadow:0 1px 2px rgba(30,27,75,.06),0 10px 30px rgba(30,27,75,.09);
  --r:18px;
}
```

Signature gradients: `linear-gradient(135deg,var(--a1),var(--a2))` for icon discs, level badge, XP fill, checked boxes and kicker bars. Pairs `a1→a3` and `a2→a3` vary the icon discs. Hero headline text: `linear-gradient(90deg,var(--a2-lt),var(--a1-lt) 55%,var(--a3))` with `background-clip:text`.

With no brand assets, keep these placeholders (check the accents with the dataviz validator) and say so in the report.

## Type and base

- Body 17px, weight ~350, line-height 1.62, `--ink` on white. Embedded display font with `font-weight:300 800` range.
- h1 800 `clamp(44px,6.4vw,84px)` letter-spacing -.025em; h2 800 `clamp(32px,3.8vw,50px)`; h3 700 22px; headings in `--brand`, white in dark sections.
- `.lead` 20px weight 330 `--ink-2`, max 840px. `.kicker`: uppercase, 12.5px, 700, letter-spacing .13em, preceded by a 26×3px gradient bar.
- Inline `code`: mono .84em on a 7% brand-tinted background, 6px radius. In dark sections: 12% white on white.
- Focus: `:focus-visible{outline:3px solid var(--a2);outline-offset:3px}`. `html{scroll-behavior:smooth;scroll-padding-top:78px}`.
- Reduced motion: `@media (prefers-reduced-motion:reduce){html{scroll-behavior:auto}*{animation:none!important;transition:none!important}}`.
- `.wrap` max 1200px, 28px side padding (18px under 660px).

## Section rhythm

- `.chapter` padding 104px 0 (76px on mobile), `overflow:hidden`, `position:relative`. Variants: white, `.tint` (soft light), `.dark` (`--brand`), `.xd` (`--brand-xd`). Alternate them; give the journey chapter `.xd` and the runbook terminal `.dark`.
- Chapter head: grid `auto 1fr`; left a 66px round gradient icon disc with a 30px stroke-only SVG icon (stroke 1.75, `--brand`), right the kicker "Chapter 0N", the h2 and the lead.
- Hero: dark (`radial-gradient` accent glow top-right over `linear-gradient(160deg,var(--brand-xd),var(--brand) 72%)`), 118px top padding, white h1 with the gradient word, sub at `clamp(19px,2vw,23px)`, pill CTAs (white solid + ghost outline), 6-column glassy stat tiles (`rgba(255,255,255,.07)` with a 14% white border), a meta line, and an animated mouse scroll cue.
- Corner brand-mark accents: an absolutely positioned 360px box in a section corner, holding an oversized official image (~620px) and masked with `radial-gradient(125% 125% at 100% 0%,#000 46%,transparent 74%)` so it fades out. Use them on the hero, the quiz and the footer. Content sits above at `z-index:1`.
- Icons: one inline `<svg>` sprite of `<symbol>`s (24×24, stroke-only, round caps and joins), used with `<use href="#i-name">`. Gradients for rings and flow paths go in the sprite's `<defs>`.

## Components

- **Top bar:** sticky, 64px, `rgba(brand-xd,.97)`. Logo + uppercase small label, a horizontally scrolling chip nav with edge-fade mask and hidden scrollbar, and the XP button (round gradient level disc, rank name, XP, 92×6 meter). A 3px gradient reading bar sits at the bottom edge. Chip states: hover 10% white, `.active` white with brand text, `.done` number in `--a3`.
- **Cards:** white, 1px `--line` border (accent-1 at 28% inside tint sections), radius 18, padding 24, `--shadow`. Grid helpers `.g2/.g3/.g4` collapse to 2 columns at 980px and 1 at 660px. Always `minmax(0,1fr)`.
- **Buttons:** pill, 700 weight, 14×22 padding, translateY(-1px) on hover. Variants: white, ghost (inset white outline), brand, line. `.sm` size.
- **Pills/status:** 12.5px 650 weight on tinted backgrounds (done = a3-lt, in progress = a1-lt, todo = a2 at 16%).
- **Pull quote:** 22–30px 600 weight, 4px accent-1 left border, small source line.
- **Proof tiles / stat tiles:** big 30–34px number + 13–14px label on tint.
- **Numbered rules:** CSS counter list, 2 columns, gradient number discs.
- **Owners panel:** two columns with a round "swap" icon between them (rotates 90° on mobile). One side is light accent, the other deep brand. Bullets are small gradient dots.
- **Code block / JSON:** `--brand-xd` background, light text, 14px radius, token colors (keyword a2-lt, string a1-lt, number a3, comment 45–50% white). Highlight key fields with an accent-1 22% background.
- **Progress ring:** 54px SVG circle with a gradient stroke, animated `stroke-dashoffset`.
- **Timeline:** left rule with dot markers (milestone = accent 1, warning = a2-lt, "now" = pulsing a2). Items fade up once when they enter view.
- **Journey:** a glassy shell on `.xd`. An SVG of stations (min-width 860px, scrolls horizontally on mobile) with a dashed gradient flow path animated by `stroke-dashoffset`. The active station gets a halo and the others dim to .32. Controls: round numbered step buttons (on = white, seen = a2-lt border), Back, Autoplay, Next. Below, a white two-column step card: left the step label, title, body and a gotcha callout (tint, accent-1 left border); right the events emitted and file rows (mono link + copy).
- **Catalog cards:** 4/3/2/1-column grid. Each card shows a stage label, a big name, a description and a mono identifier, lifts on hover, and gets a "caught" badge once opened. Filter chips use `aria-pressed`. The secret card has a diagonal stripe background. A pipeline row of numbered steps shows how an item flows.
- **Dialogs:** native `<dialog>`, radius 22, blurred brand backdrop, brand header with an × button, scrollable body with a `dl.kv` key/value grid.
- **Gallery:** cards with a fake browser frame (three dots + mono URL), 16:10 cover image and caption. Lightbox dialog with prev/next.
- **Code map:** `<details>` groups (icon, title, subtitle, rotating chevron). File rows show the mono link, a purpose line and a copy button. Flags table: brand header row, mono first column, scrolls horizontally inside a wrapper.
- **Terminal:** a 260px step list (numbered; on = white, seen = a3) next to a terminal (very dark brand, traffic-light dots in the accents, title, copy button). Commands type in with prompt/comment/string colors, then an explanation block. Gotcha cards below.
- **Procedure player:** the terminal layout for UI tasks. The same step list sits next to a browser-frame card holding that step's screenshot (with an optional numbered callout dot over the control to use) and an instruction panel below it: what to do, what you should see, and an "if it goes wrong" line.
- **Old vs. new:** the owners-panel layout per changed task. The old way sits on the muted light side and the new way on the deep brand side, with the swap icon between. Use a small "unchanged" pill for tasks that stay the same.
- **Cheat sheet:** a compact card grid of core tasks with a Print button. An `@media print` stylesheet hides everything except the cheat sheet and prints on white.
- **People:** 3/2/1-column cards with a 66px avatar ringed in accent (initials on a gradient if no photo), name, role, hook line, evidence chips, an "ask them about" list that expands via a `grid-template-rows:0fr→1fr` transition, and a footer with the action button and handle. Lead cards get a gradient border via `padding-box/border-box` backgrounds. Then mini pill chips, channel tiles and dashed bot tags.
- **Checklist:** custom square checkboxes (gradient when checked, CSS checkmark). Checked rows strike through, with a gradient progress bar above. Quest board tickets show an ID copy button, project, title and a ★ "good first" tag.
- **Glossary:** a large pill search input with a focus glow and a result count, a 3/2/1-column `dl` of tint tiles, and `<mark>` highlights. `.g-term` = dotted a2 underline with `cursor:help`.
- **Quiz:** a white card with a top row (Q n of 10, XP), a gradient progress bar, lettered option buttons (right = brand border on a3-lt, wrong = a2 border on a2 tint), an explanation that fades in, and Next. Result shows a 128px gradient medal and the score. Badge pills are grayscale until earned.
- **Toasts:** bottom-right stack, dark, 14px radius, slide-in. The badge variant has a gradient and an a2-lt border.
- **Footer:** deep brand, two columns (logo + tagline + disclaimer + reset | sources + not verified), fine print at 60% white.

## Interaction patterns (JS)

One IIFE with `'use strict'`. Data constants first, then helpers, then renderers.

- Helpers: `$`, `esc()` for HTML-escaping every data string, `gh(path)` building the SHA-pinned URL (handles `#L` anchors and trailing `/` → `tree`), `prUrl(n)`.
- State: `const KEY='<topic>guide:v1'`. `S = {xp, aw:{}, visited:[], badges:[], checks:{}, quiz:{i, answers:[]}}` merged with the loaded state, and `save()` in try/catch.
- `award(key, amt, msg)`: idempotent per key (stored in `S.aw`). Adds XP, toasts, toasts a level-up when the level changes, re-checks badges, re-renders the XP meter. `revoke(key)` for unchecking checklist items. Badge rules count award-key prefixes (`ch:`, `stop:`, `card:`, `check:`, `quiz:`).
- Scrollspy: an `IntersectionObserver` on `[data-chapter]` sets the active chip, scrolls the chip nav so the active chip is centered (`offsetLeft - box.clientWidth/2 + chip.clientWidth/2`), and awards the chapter once. Never let observers restart one-shot animations or reset progress; unobserve after the first reveal.
- Journey: the current index lives in state. Next/Back/number buttons and ArrowLeft/ArrowRight (only while the journey is in view and focus isn't in an input) call `go(i)`. Autoplay advances on an interval and stops on any manual input, and is off under reduced motion.
- Tooltips: one fixed `.tip` element positioned from `getBoundingClientRect` on hover/focus of `.g-term`, with text from the same GLOSSARY map. Hide it on scroll, blur and mouseleave.
- Copy: delegated click on `[data-copy]` uses `navigator.clipboard`, with a textarea fallback for `file://`. Toast the copied text.
- Charts: render SVG sized from the container width and re-render on a debounced `resize`. Focusable bars activate on Enter.
- Confetti: a canvas particle burst on quiz pass, skipped under reduced motion.
- Reset: clear the key, reset `S`, re-render everything.

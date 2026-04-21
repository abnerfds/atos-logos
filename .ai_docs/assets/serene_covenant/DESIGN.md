# Design System Strategy: The Serene Steward

## 1. Overview & Creative North Star
The "Serene Steward" is our Creative North Star. Most church management platforms feel like cold, utilitarian databases. This design system rejects the "admin dashboard" trope in favor of a **High-End Editorial** experience. We aim to evoke the feeling of a sun-drenched sanctuary—open, breathable, and deeply intentional. 

We move beyond the "template" look by using **Atmospheric Layering**. Instead of rigid grids and harsh borders, we use soft tonal shifts and generous negative space to guide the eye. The layout is asymmetrical yet balanced, using high-contrast typography scales to create a sense of authoritative grace. This isn't just a tool; it is a digital extension of a welcoming community.

---

## 2. Colors & Atmospheric Depth
Our palette is a sophisticated blend of ethereal blues and grounded neutrals. We do not use color to decorate; we use it to define space and state.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to define sections. Traditional "boxes" make an interface feel cramped and technical. Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` (#f0f4f8) sidebar sitting against a `surface` (#f7f9fc) main stage.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine vellum.
*   **Base Layer:** `surface` (#f7f9fc) for global backgrounds.
*   **Secondary Context:** `surface-container-low` (#f0f4f8) for navigation or grouping.
*   **Prominent Content:** `surface-container-lowest` (#ffffff) for the primary content cards, creating a "lifted" feel through pure brightness rather than shadows.

### The "Glass & Gradient" Rule
To escape the "standard web app" feel:
*   **Glassmorphism:** Use `surface-container-lowest` at 70% opacity with a `backdrop-blur` of 20px for floating navigation bars or modals. This allows the church’s brand colors or soft background gradients to bleed through.
*   **Signature Textures:** For high-impact moments (Hero headers or "Give" CTAs), use a subtle linear gradient from `primary` (#37628a) to `primary-container` (#a6d0fe). This provides a visual "soul" that flat hex codes lack.

---

## 3. Typography: The Editorial Voice
We use a dual-typeface system to balance warmth with modern efficiency.

*   **The Display Voice (Manrope):** Our headlines (`display-lg` to `headline-sm`) use Manrope. Its wide apertures and modern geometric forms feel professional yet approachable. Use `display-lg` (3.5rem) with tight letter-spacing (-0.02em) for impactful welcome messages.
*   **The Functional Voice (Inter):** All body and UI labels use Inter. It is the gold standard for readability. 
*   **Hierarchy as Brand:** Use `title-lg` (Inter, 1.375rem) in `on-surface-variant` (#596065) for subheaders to create a sophisticated, low-contrast editorial look that reduces cognitive load.

---

## 4. Elevation & Depth: Tonal Layering
We achieve hierarchy through light and shadow, never through lines.

*   **The Layering Principle:** To highlight a member's profile card, place a `surface-container-lowest` (#ffffff) card on a `surface-container` (#e9eef3) background. The 0.5rem (`DEFAULT`) corner radius softens the transition.
*   **Ambient Shadows:** If a component must "float" (like a FAB or a Popover), use an ultra-diffused shadow: `offset: 0 12px, blur: 40px, color: rgba(44, 51, 56, 0.06)`. Note the use of `on-surface` (#2c3338) as the shadow base rather than pure black.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke (e.g., in high-contrast mode), use `outline-variant` (#abb3b9) at **15% opacity**. It should be felt, not seen.

---

## 5. Components
Each component should feel like a custom-crafted object.

*   **Buttons:**
    *   *Primary:* `primary` (#37628a) background with `on-primary` (#f7f9ff) text. Use `md` (0.75rem) roundedness.
    *   *Secondary:* `secondary-container` (#cde6f4) background. No border.
*   **Input Fields:** Use `surface-container-high` (#e3e9ee) as the field background. Upon focus, transition the background to `surface-container-lowest` (#ffffff) and add a 2px `primary` bottom-only indicator.
*   **Cards & Lists:** **Strictly forbid divider lines.** Use `12` (3rem) or `16` (4rem) spacing from the scale to separate list items. Content should breathe. Group related items using a `surface-container-low` wrap.
*   **Chips:** Use `full` (9999px) roundedness. Filter chips should use `secondary-container` (#cde6f4) to feel tactile and "tossable."
*   **The "Community Prayer" Card (Context Specific):** A specialized component using `tertiary-container` (#d8cafc) with a subtle `tertiary` (#635983) left-accent bar to denote a "sacred" or "high-priority" community request.

---

## 6. Do’s and Don’ts

### Do
*   **Use Asymmetric Margins:** Give headers more top-room (e.g., scale `20` or `24`) than bottom-room to create an editorial cadence.
*   **Embrace the "White" in White Space:** Use `surface-container-lowest` (#ffffff) as a functional color to draw the eye to interactive zones.
*   **Prioritize Type Scale:** Let the difference between `display-md` and `body-md` do the work of a divider.

### Don’t
*   **Don't use 100% Black:** Ever. Use `on-surface` (#2c3338) for text to maintain the "soft blue" serenity of the system.
*   **Don't use Default Shadows:** Avoid the "dirty" look of standard grey shadows; always tint them with the surface color.
*   **Don't Crowd the Corners:** With a `DEFAULT` radius of 0.5rem, ensure internal padding is at least `4` (1rem) so content doesn't feel "pinched" by the curve.
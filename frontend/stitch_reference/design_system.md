# Design System Strategy: The Industrial Archivist

## 1. Overview & Creative North Star
This design system is built to transform a utility—prompt management—into a high-stakes, high-energy editorial experience. Our Creative North Star is **"The Industrial Archivist."** 

We are moving away from the "soft-UI" trends of the last decade. Instead of hiding the underlying structure, we celebrate it. This system uses raw, unapologetic Neo-Brutalism to signal professional-grade power. By combining the rigid precision of technical documentation with the high-contrast energy of street-art posters, we create a signature aesthetic that feels both indestructible and cutting-edge. We break the "template" look through intentional asymmetry, massive typography scales, and structural elements that feel physically heavy.

---

## 2. Colors
Our palette is a collision of high-visibility safety colors and raw industrial neutrals.

*   **Primary (Cyber Yellow - #FFD700):** This is our "High-Visibility" signal. Use it for the most critical actions and primary brand moments. 
*   **Secondary (Electric Cyan - #4ECDC4):** Used for "Active State" feedback and technical highlights. It represents the "spark" of the AI.
*   **Tertiary (Vivid Pink - #FF6B6B):** Use this sparingly for "Human" elements, error states, or high-contrast accents that need to break the yellow/cyan dominance.
*   **Neutral (Off-White - #F4F4F4):** Our "Concrete Canvas." This provides the industrial backdrop that allows the high-chroma colors to pop.

### The "No-Line" Rule for Sectioning
While this system uses thick 4px borders for components, **do not use 1px lines to section your layout.** 
Structure must be defined by:
1.  **Background Color Shifts:** Use `surface-container-low` (#f3f3f3) against `surface` (#f9f9f9) to define distinct work areas.
2.  **Structural Offsets:** Instead of a divider, shift a container 24px to the right to create a "nested" hierarchy visually.

### Signature Textures & Gradients
To avoid a flat "clipart" feel, use **Signature Overlays**. For Hero sections or primary CTAs, apply a subtle linear gradient from `primary` (#705d00) to `primary_container` (#ffd700) at a 45-degree angle. This adds a "metallic" depth that feels premium and intentional.

---

## 3. Typography
We utilize a high-contrast typographic pairing to balance editorial authority with technical precision.

*   **The Display & Headline (Space Grotesk - Extra Bold):** This is our architectural voice. Use massive scales (display-lg) for headers to anchor the page. It should feel loud and unmovable.
*   **The Content (Inter):** For title and body levels, Inter provides the necessary legibility to balance the aggressive display type. 
*   **The Engine (JetBrains Mono):** All prompt content, code snippets, and technical metadata *must* be set in JetBrains Mono. This signals to the user that they are in a "builder" environment.

**Editorial Tip:** Use "Asymmetric Tracking." For display headers, tighten the letter-spacing (-2% to -4%) to make the words feel like solid blocks of ink.

---

## 4. Elevation & Depth
In this system, depth is not an illusion created by light—it is a physical stacking of layers.

*   **Hard-Drop Shadows:** We do not use blur. All floating elements must use a **(6, 6) offset with 100% opacity**. This creates a \"cut-out\" effect, as if the UI is made of thick acrylic sheets stacked on top of one another.
*   **The Layering Principle:** Use the Surface-Container tiers. A `surface-container-highest` card should sit on a `surface-container-low` background. This \"tonal stacking\" provides hierarchy without needing traditional shadows.
*   **The Industrial Glass Rule:** For modals or floating tooltips, use a \"Frosted Industrial\" effect: a `surface` color at 80% opacity with a `backdrop-blur` of 12px. This allows the heavy black borders of the background to peek through, maintaining the raw aesthetic while adding a high-end finish.
*   **Prohibition of Soft Shadows:** Any shadow with a blur radius greater than 0px is a violation of the system.

---

## 5. Components

### Buttons (The \"Action Block\")
*   **Primary:** `primary_container` (#FFD700) background, 4px black border, 6px hard black shadow. Text: Space Grotesk Bold, All Caps.
*   **State Change:** On hover, the button should shift its position by (-2, -2) and the shadow should increase to (8, 8), creating a \"lifting\" animation.

### The \"Prompt Card\" (Core Component)
*   **Structure:** No rounded corners (0px). 
*   **Header:** A 4px black bottom border separates the title from the prompt body. 
*   **Body:** `surface-container-lowest` background with JetBrains Mono text.
*   **Asymmetry:** Use a \"tab\" style for categories—a small cyan box (#4ECDC4) that sits overlapping the top-left border of the card.

### Input Fields
*   **Default:** `surface` background, 4px black border. 
*   **Focus:** The border remains 4px black, but the background shifts to a very faint `secondary_fixed_dim` (#5dd9d0) at 10% opacity. 
*   **Labels:** Always use `label-md` in Space Grotesk, positioned outside the input box, never as placeholder text.

### Industrial Chips
*   Used for tags (e.g., \"GPT-4\", \"Creative\").
*   Solid 2px black border (the only exception to the 4px rule for smaller scale). 
*   Backgrounds should cycle between the Secondary and Tertiary accent colors.

---

## 6. Do's and Don'ts

### Do:
*   **Embrace the Grid:** Align everything to a strict 8px baseline, but break the horizontal grid with intentional overlaps.
*   **Go Big:** If a header feels too big, it’s probably the right size. 
*   **Use High Contrast:** Ensure text on `primary` (Yellow) uses `on_primary_container` (Dark Brown/Black) for maximum readability.

### Don't:
*   **No Rounded Corners:** Every radius must be `0px`. Roundness suggests \"softness,\" which contradicts the industrial nature of the system.
*   **No \"Ghost\" Buttons:** Every button must have a fill or a heavy border. In an industrial environment, every control must be visible and tactile.
*   **No Centered Layouts:** Lean toward left-aligned editorial layouts. Centered content feels too much like a standard landing page template; left-aligned feels like a technical manual or a magazine.

### Accessibility Note:
While Neo-Brutalism is high-contrast by nature, always ensure that your Cyber Yellow (#FFD700) maintains at least a 3:1 contrast ratio against the background for large text, and use the `on_primary_container` color for smaller text elements to ensure WCAG compliance.

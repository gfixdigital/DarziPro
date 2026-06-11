---
name: Craftsman Utility
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1b1c1c'
  on-surface-variant: '#41493e'
  inverse-surface: '#303030'
  inverse-on-surface: '#f3f0ef'
  outline: '#717a6d'
  outline-variant: '#c0c9bb'
  surface-tint: '#2a6b2c'
  primary: '#00450d'
  on-primary: '#ffffff'
  primary-container: '#1b5e20'
  on-primary-container: '#90d689'
  inverse-primary: '#91d78a'
  secondary: '#556158'
  on-secondary: '#ffffff'
  secondary-container: '#d9e6da'
  on-secondary-container: '#5b675e'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#cca830'
  on-tertiary-container: '#4f3e00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#acf4a4'
  primary-fixed-dim: '#91d78a'
  on-primary-fixed: '#002203'
  on-primary-fixed-variant: '#0c5216'
  secondary-fixed: '#d9e6da'
  secondary-fixed-dim: '#bdcabe'
  on-secondary-fixed: '#131e17'
  on-secondary-fixed-variant: '#3e4a41'
  tertiary-fixed: '#ffe088'
  tertiary-fixed-dim: '#e9c349'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574500'
  background: '#fcf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e5e2e1'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
---

## Brand & Style
This design system is built on the principles of reliability, clarity, and professional craftsmanship. It targets small-to-medium business owners who require a tool that works as hard as they do. The aesthetic is a blend of **Modern Minimalism** and **High-Contrast Utility**, ensuring that the interface remains legible even in the bright, harsh lighting conditions of a storefront or outdoor market.

The emotional response should be one of "quiet confidence." By stripping away unnecessary ornamentation and focusing on high-quality typography and a disciplined color palette, the UI moves out of the way of the user’s workflow. Subtle gold accents are used sparingly to denote premium status, quality, and the "master" level of service the user provides to their own clients.

## Colors
The palette is rooted in a **Deep Green** primary, chosen for its association with growth, stability, and cultural resonance. This is paired with a **Mint Green** secondary for large-surface backgrounds and container fills to keep the interface feeling fresh and airy.

- **Primary (#1B5E20):** Used for key actions, primary buttons, and active states. It provides the necessary contrast for outdoor readability.
- **Secondary (#E8F5E9):** Used for card backgrounds, toggle tracks, and subtle section separators.
- **Accent Gold (#D4AF37):** Reserved for "Premium" features, VIP customer tags, or completion states. It adds a layer of sophistication without being distracting.
- **Neutral (#212121):** A high-contrast charcoal for all primary text and iconography to ensure maximum legibility.

## Typography
This design system utilizes **Inter** for all levels of the hierarchy. Inter was selected for its exceptional tall x-height and systematic clarity, which aids in reading long lists of measurements or customer data.

The hierarchy is intentionally "top-heavy," with bold headlines to help users quickly orient themselves when switching between tasks. For mobile accessibility, body text never drops below 16px to ensure that instructions and data entries are readable at an arm's length. Labels use a slightly increased letter-spacing and semi-bold weights to differentiate them from data values.

## Layout & Spacing
The layout follows a **Fluid Grid** model optimized for handheld devices. We employ an **8px linear scale** for all spacing and layout decisions.

- **Mobile Strategy:** A 4-column grid with 20px outer margins and 16px gutters. This wide margin prevents content from feeling cramped and provides a "safe zone" for thumb-driven navigation.
- **Touch Targets:** All interactive elements (buttons, inputs, list items) maintain a minimum height of 48px to accommodate all users, regardless of dexterity.
- **Visual Rhythm:** Vertical rhythm is strictly enforced; spacing between related items (label + input) uses 8px (sm), while spacing between sections uses 24px (lg).

## Elevation & Depth
Depth is communicated through **Tonal Layering** rather than heavy shadows. This maintains the clean, minimal aesthetic while providing clear visual cues about what is tappable.

- **Level 0 (Background):** Pure White (#FFFFFF).
- **Level 1 (Cards/Containers):** Mint Green (#E8F5E9) with a 1px stroke of #1B5E20 at 8% opacity. No shadow.
- **Level 2 (Active Elements/Modals):** Pure White with a soft, diffused shadow (0px 4px 12px rgba(0, 0, 0, 0.05)). This is used for floating action buttons or bottom sheets.
- **Separators:** Instead of heavy lines, use 1px dividers in Mint Green to subtly define boundaries without adding visual noise.

## Shapes
The shape language is defined as **Rounded (Level 2)**. This specific radius strikes a balance between the precision of a professional tool and the approachability of a modern mobile app.

Standard UI components like inputs and buttons use a 0.5rem (8px) corner radius. Larger containers, such as dashboard cards or customer profiles, use the `rounded-lg` value (16px) to create a soft, nested appearance. This consistency in rounding helps unify disparate data points into a cohesive visual flow.

## Components
Consistent component styling ensures the app is easy to learn for non-tech-savvy users.

- **Buttons:** Primary buttons are solid Deep Green with White text. They use a bold weight and 16px internal horizontal padding. Secondary buttons use a Deep Green outline with a Mint Green fill.
- **Input Fields:** Fields are structured with a persistent label above the input area. The input has a subtle Mint Green background and a 2px Deep Green bottom border when focused to provide clear visual feedback during data entry.
- **Chips:** Used for "Order Status" (e.g., *Pending, Cutting, Ready*). They use the Mint Green background with Deep Green text for high legibility.
- **Lists:** Measurement lists use high-contrast text and 16px vertical padding. Every third row is subtly tinted with Mint Green to help the eye track across the screen.
- **Cards:** Order cards feature a "Gold" accent bar on the left edge if the order is marked as "Urgent" or "Premium," creating an immediate hierarchy in the list view.
- **Checkboxes & Radios:** Oversized targets (24x24px) in Deep Green to ensure accuracy during fast-paced shop interactions.
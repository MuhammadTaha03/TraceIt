---
name: TraceIt
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#414754'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#727785'
  outline-variant: '#c1c6d6'
  surface-tint: '#005bc0'
  primary: '#005bbf'
  on-primary: '#ffffff'
  primary-container: '#1a73e8'
  on-primary-container: '#ffffff'
  inverse-primary: '#adc7ff'
  secondary: '#005ac1'
  on-secondary: '#ffffff'
  secondary-container: '#4d8efe'
  on-secondary-container: '#00285c'
  tertiary: '#006d2c'
  on-tertiary: '#ffffff'
  tertiary-container: '#008939'
  on-tertiary-container: '#ffffff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc7ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a41'
  on-secondary-fixed-variant: '#004494'
  tertiary-fixed: '#89fa9b'
  tertiary-fixed-dim: '#6ddd81'
  on-tertiary-fixed: '#002108'
  on-tertiary-fixed-variant: '#005320'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
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
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-md:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 20px
  margin-desktop: 48px
  gutter: 16px
  card-padding: 24px
  section-gap: 32px
---

## Brand & Style
The design system for TraceIt is built on the principles of reliability, community, and clarity. It adapts the **Material Design 3 (Material You)** framework to create a premium, high-fidelity experience for a lost-and-found ecosystem. The brand personality is "The Helpful Guide"—professional yet approachable, ensuring users feel supported during the stress of losing an item.

The visual style is a hybrid of **Corporate Modern** and **Glassmorphism**. While it adheres to the structured logic of Material 3 (M3) for layout and hierarchy, it introduces frosted glass effects on navigation layers to create depth and a sense of "premium lightness." The interface prioritizes generous whitespace and high-fidelity transitions to reduce cognitive load.

## Colors
The palette utilizes the iconic Google Blue as the primary driver for action. Following M3 logic, the system uses tonal surfaces for container levels.

- **Primary (#1A73E8):** Reserved for key actions, Floating Action Buttons (FABs), and active states.
- **Surface & Background:** In light mode, a crisp `#FFFFFF` is used for the base, while `#F8F9FA` (Neutral 98) serves as the background for tonal containers. In dark mode, the base is a deep `#121212`.
- **Status Colors:** Lost states utilize a soft red-tinted neutral, while Found states use the Tertiary Green to signal resolution.
- **Glassmorphism:** Navigation bars use a 70% opacity version of the surface color with a 20px backdrop blur and a 1px inner stroke for definition.

## Typography
This design system uses **Inter** exclusively to maintain a utilitarian, tech-forward aesthetic. The hierarchy is defined by high-contrast weights.

- **Headlines:** Use Bold (700) or SemiBold (600) weights with slight negative letter spacing to create a compact, premium feel.
- **Body:** Standard body text uses a 16px base for maximum readability.
- **Labels:** Status indicators (Lost/Found) use uppercase 12px SemiBold text for immediate scannability.
- **Scaling:** Mobile headlines scale down slightly but retain their weight to maintain the "Bold" brand character.

## Layout & Spacing
The layout follows a **Fluid Grid** model with an 8px base unit. 

- **Grid:** A 12-column grid is used for desktop, 8-column for tablet, and a 4-column grid for mobile.
- **Margins:** Generous 20px margins on mobile ensure content feels "contained" and premium, increasing to 48px on desktop to prevent content stretching.
- **Safe Areas:** Navigation elements are padded with a minimum of 16px from screen edges. 
- **Reflow:** On mobile, item cards stack vertically. On tablet and desktop, cards reflow into a multi-column masonry or grid layout.

## Elevation & Depth
Elevation is handled through **Tonal Layers** and **Glassmorphism** rather than heavy shadows.

- **Level 0 (Base):** The primary background.
- **Level 1 (Cards):** Subtle tonal offset with no shadow. 
- **Navigation (Overlays):** The Top App Bar and Bottom Navigation use a frosted glass effect (backdrop-filter: blur(20px)) with a subtle tint of the primary color in light mode.
- **FAB (Interaction):** Floating Action Buttons use a Level 3 elevation (soft, diffused 12% opacity shadow) to indicate they are the primary interaction point above all other surfaces.

## Shapes
In accordance with Material 3, the design system utilizes **Extra-Large rounded corners (28px)** for primary containers like cards and modal sheets. 

- **Standard Elements:** Buttons and input fields use a 16px radius.
- **Cards:** Main item containers use a 28px radius for a soft, approachable silhouette.
- **FAB:** The Floating Action Button follows the M3 signature of a "squircle" shape (rounded-2xl) rather than a perfect circle.

## Components

### Buttons & FAB
- **Primary Action:** Solid #1A73E8 fill with white Inter SemiBold text. 16px corner radius.
- **FAB:** Large, iconic FAB for "Report Lost Item" using the Primary color and a solid-weight plus icon.

### Item Cards
- **Structure:** Large image container (top) with a 24px internal padding for text elements (bottom). 
- **Chips:** "Status" chips are placed in the top-right of the image area with a high-blur glassmorphic background to ensure legibility over photos.
- **Labels:** Item name in Title-LG, time/location in Body-MD.

### Navigation
- **Top Bar:** Centered title, frosted glass background, minimalist 24px solid icons.
- **Bottom Nav:** Active states indicated by a pill-shaped tonal highlight (M3 style).

### Input Fields
- **Style:** Outlined with a 16px corner radius. The border is a subtle neutral, turning Primary Blue on focus. Labels use M3 "floating" logic.

### Chips
- **Usage:** Used for filtering categories (e.g., "Electronics", "Pets"). Pill-shaped, light gray background, 12px Inter weight.
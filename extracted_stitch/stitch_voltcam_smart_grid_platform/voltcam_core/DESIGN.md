---
name: VoltCam Core
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#424750'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#727781'
  outline-variant: '#c2c6d1'
  surface-tint: '#27609d'
  primary: '#003461'
  on-primary: '#ffffff'
  primary-container: '#004b87'
  on-primary-container: '#8abcff'
  inverse-primary: '#a3c9ff'
  secondary: '#a04100'
  on-secondary: '#ffffff'
  secondary-container: '#fe6b00'
  on-secondary-container: '#572000'
  tertiary: '#003c1c'
  on-tertiary: '#ffffff'
  tertiary-container: '#00562b'
  on-tertiary-container: '#4ad27d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d3e4ff'
  primary-fixed-dim: '#a3c9ff'
  on-primary-fixed: '#001c38'
  on-primary-fixed-variant: '#004882'
  secondary-fixed: '#ffdbcc'
  secondary-fixed-dim: '#ffb693'
  on-secondary-fixed: '#351000'
  on-secondary-fixed-variant: '#7a3000'
  tertiary-fixed: '#77fca3'
  tertiary-fixed-dim: '#59df89'
  on-tertiary-fixed: '#00210d'
  on-tertiary-fixed-variant: '#005228'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  hero-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  section-title:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  card-title:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  caption:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
  status-label:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
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
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
---

## Brand & Style
The design system is engineered to evoke a sense of absolute reliability, precision, and forward-thinking utility. Targeted at the Cameroonian market, it balances the ruggedness required for infrastructure monitoring with a premium, high-fidelity aesthetic that feels "Apple-grade."

The style is **Corporate / Modern** with strong **Glassmorphic** accents. It leverages the depth of Material Design 3 and the refined cleanliness of the Human Interface Guidelines. The interface feels light, airy, and expensive, utilizing high-quality whitespace and subtle translucency to signify "intelligent" monitoring rather than just a utility tool.

## Colors
The palette is rooted in a deep, authoritative **Electric Blue** to signify stable infrastructure. **Vibrant Orange** is reserved strictly for high-urgency alerts, community power-outage reporting, and critical actions. **Modern Green** signals healthy grid status and sustainable energy contributions.

The system supports a native dark mode. In dark mode, the "Deep Electric Blue" remains the primary anchor, but background surfaces shift to a deep navy (#121B2A) to maintain high-end contrast without the harshness of pure black. Glassmorphism effects should use a 20% white overlay in light mode and a 10% white overlay in dark mode.

## Typography
**Inter** is the primary typeface for this design system, chosen for its exceptional legibility on mobile screens and its neutral, systematic character.

- **Hierarchical Contrast:** Use `Hero` for main dashboard metrics or onboarding. `Section Title` is for distinct groupings on a page.
- **Micro-copy:** `Status Label` should always be used in uppercase with slightly wider letter-spacing (0.05em) to differentiate it from standard labels.
- **Mobile Scaling:** On devices smaller than 375px wide, `Hero` text should scale down to 28px to prevent awkward line breaks.

## Layout & Spacing
This design system utilizes a strict **8pt Grid** to ensure visual harmony and consistent alignment.

- **Margins:** Mobile layouts should maintain a 20px side margin.
- **Gutters:** Cards and list items should be separated by 16px.
- **Grouping:** Use 8px spacing for related elements (e.g., an icon next to a label) and 24px-32px to separate distinct content blocks.
- **Container Strategy:** Content is largely contained within floating cards that span the full width of the safe area minus margins.

## Elevation & Depth
Depth is created through a mix of **Tonal Layers** and **Ambient Shadows**. 

1.  **Cards (Level 1):** Use a subtle shadow: `y: 4, blur: 12, color: rgba(0,0,0, 0.05)`.
2.  **Floating Elements (Level 2):** For FABs or active modal components: `y: 8, blur: 24, color: rgba(0,0,0, 0.1)`.
3.  **Glassmorphism:** Navigation bars and bottom sheets must use a backdrop-filter (blur: 20px) with a semi-transparent background fill. This allows the primary brand colors from the dashboard to bleed through softly as the user scrolls.

## Shapes
The shape language is "Rounded" but controlled.
- **Primary Cards:** Use 16px (`rounded-xl` logic) to feel approachable and modern.
- **Buttons:** Use 12px or fully pill-shaped for high-action items.
- **Inputs:** Use 12px to match the professional tone of the typography.
- **Indicators:** Live status indicators (like "Power Online") should be perfect circles with a glowing outer ring.

## Components

### Buttons
- **Primary:** Solid #004B87, white text, 12px radius. Soft press animation (scale: 0.97).
- **Secondary:** White background with #E9ECEF border.
- **Ghost:** Transparent background, #004B87 text for less urgent actions.

### Floating Cards
- Elevated surfaces with 16px corner radius.
- Padding should be 20px internally.
- Header cards on the dashboard should use a very subtle gradient (Top: #004B87 to Bottom: #003661) when highlighting critical data.

### Live Glowing Indicators
- A small 8px dot for status. 
- Use a 4px spread "breath" animation using the status color (e.g., Green for active) at 30% opacity to indicate real-time monitoring.

### Input Fields
- Background-filled (#F8F9FA) with a 1px border (#E9ECEF).
- Focused state uses a 2px Primary Blue border.

### Navigation Bar
- **Glassmorphic Bottom Bar:** 20px backdrop blur, 80% opacity white (or 80% surface_dark). 
- **Icons:** 24px Lucide-style outlined icons with a 2px stroke width. Use Primary Blue for the active state.

### Chips/Badges
- Status badges use high-saturation backgrounds at 10% opacity with 100% opacity text of the same color (e.g., Orange text on Light Orange background).
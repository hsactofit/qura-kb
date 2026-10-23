# 02 - Brand Guidelines & UI Design System

This document outlines the official visual identity, color tokens, typography scales, and component guidelines for the **QURA INSURE CRM Panel**, derived directly from the official QURA INSURE Brand Guidelines.

---

## 🎨 Color Palette & Design Tokens

### Primary & Brand Colors

| Token Name | Color Name | Hex Code | Usage / Purpose |
| :--- | :--- | :--- | :--- |
| `--qura-navy` | **Navy Blue (Primary)** | `#0A2342` | Primary branding, headers, dark sidebar backgrounds, primary buttons. |
| `--qura-steel` | **Steel Blue (Secondary)** | `#4A697D` | Secondary elements, subtle borders, secondary typography, muted icons. |
| `--qura-lime` | **Lime Green (Accent)** | `#BDF26E` | Key call-to-actions, active indicators, status highlights, badges, glow accents. |
| `--qura-ice` | **Ice Blue (Light)** | `#F2F8FF` | Light mode surface backgrounds, subtle hover highlights, card tints. |
| `--qura-charcoal` | **Dark Charcoal** | `#232323` | Dark mode surface background, primary text in light mode, high contrast elements. |

### Extended Palette Tints & Shades

```css
:root {
  /* Brand Core */
  --qura-navy-100: #0A2342;
  --qura-navy-75:  #475A71;
  --qura-navy-50:  #8591A1;
  --qura-navy-25:  #C2C8D0;
  
  --qura-steel-100: #4A697D;
  --qura-steel-75:  #778F9E;
  --qura-steel-50:  #A5B4BE;
  --qura-steel-25:  #D2DADF;
  
  --qura-lime-100: #BDF26E;
  --qura-lime-75:  #CEF592;
  --qura-lime-50:  #DEF9B7;
  --qura-lime-25:  #EFFCDB;

  /* Neutrals */
  --qura-white:    #FFFFFF;
  --qura-grey-50:  #F5F5F5;
  --qura-grey-100: #E0E0E0;
  --qura-grey-200: #BDBDBD;
  --qura-grey-300: #9E9E9E;
  --qura-grey-400: #757575;
  --qura-grey-500: #424242;
  --qura-charcoal: #232323;
  --qura-black:    #000000;
}
```

---

## 🔤 Typography System

- **Headings & Section Titles**: `Zalando Sans Expanded` / `Plus Jakarta Sans` / `Outfit` (Fallback)
- **Body Text & Data Tables**: `Inclusive Sans` / `Inter` (Fallback)

### Type Scale

| Level | Font Size / Line Height | Font Weight | Usage |
| :--- | :--- | :--- | :--- |
| **H1 (Display)** | `48px / 56px` | Bold (`700`) | Main Page Headings & KPI Highlights |
| **H2 (Section)** | `36px / 44px` | SemiBold (`600`) | Section Dividers & Modal Titles |
| **H3 (Subsection)**| `28px / 36px` | Medium (`500`) | Card Group Headers |
| **H4 (Card)** | `22px / 30px` | SemiBold (`600`) | Card Titles & Table Headers |
| **H5 (Small)** | `18px / 26px` | Medium (`500`) | Widget Titles & Popover Headers |
| **Body Large** | `18px / 28px` | Light (`300`) / Regular (`400`) | Lead paragraphs & hero subtitles |
| **Body Standard**| `16px / 24px` | Light (`300`) / Regular (`400`) | Form inputs, table cells, general text |
| **Body Small** | `14px / 20px` | Regular (`400`) | Captions, metadata, badge text |

---

## 📐 Multi-Level Collapsible Sidebar Specification

The CRM UI features a modern multi-level navigation sidebar with distinct sections and smooth collapse/expand transitions:

### Sidebar Navigation Tree

- 📊 **Dashboard & Work Queues**
  - ⚡ **My Day Queue** (Overdue callbacks, urgent renewals, new leads)
  - 📈 **Executive Analytics** (Conversion funnels, premium pipeline)
- 👥 **Customer Relationship (360)**
  - 🏢 **Accounts** (Individual, Household, Corporate)
  - 📇 **Contacts & Directory**
  - 🎯 **Leads Intake** (New inquiries, status state machine)
- 📄 **Policy Intelligence**
  - 📜 **Policy Repository** (Active, external, expired)
  - 📤 **Document Upload & OCR Verification**
  - 🔍 **Coverage-Gap & Cross-Sell Matrix**
- 🔄 **Renewals Engine**
  - ⏰ **Renewal Cycles** (T-120 to T+7 horizon queues)
  - 🏷️ **Opportunities & Quotes**
- 📞 **Telephony & Engagement**
  - 📱 **Call Center Workspace** (Click-to-call, live active call status)
  - 📋 **Dispositions & Call History**
- 🛡️ **Compliance & Security**
  - ✋ **Consents & DNC Suppressions**
  - 📜 **Grievances & Escalations**
  - 🔍 **Immutable Audit Trail**
- ⚙️ **Admin & Catalogue Configuration**
  - 👥 **Users & Team RBAC**
  - 🏷️ **Insurance Catalogues & Products**

---

## 🖼 UI Aesthetic Principles (Modern CRM Panel)

1. **Glassmorphism & Subtle Depth**: Translucent surfaces (`bg-slate-900/80 backdrop-blur-md`), crisp border definitions (`border-slate-800`), subtle drop shadows.
2. **Action-Oriented Workflows**: First screen prioritizes action items over static graphics (calls to make, pending policy verifications, expiring policies).
3. **Responsive Micro-Animations**: Smooth hover states, drawer slide-ins, call initiation ring pulse animations, pill badge color transitions.
4. **Login Only**: Sleek, secure login portal with no public user registration button.

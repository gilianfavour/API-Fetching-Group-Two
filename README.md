# Golden Glow Mobile Application

A mobile Golden Glow application featuring a clean, modular user interface designed for seamless product discovery and shopping.
We changed the colors from gold to blue and white becaue visibility was going to be hard
And the typography and the color names are all there in the main.dart file. Endavour to use them than writing from scratch

---

## 🎨 Theme & Design Guidelines (Source of Truth)

To maintain a consistent UI/UX across all screens and prevent layout fragmentation, all developers must strictly adhere to the following style guide. Do not hardcode custom hex codes or fonts outside of these definitions.

### 🔑 Color Palette

| Usage | Hex Code | Visual Sample | Application |
| :--- | :--- | :--- | :--- |
| **Primary / Brand** | `#000435` | 🟦 Dark Blue | Active Bottom Nav, Primary Buttons, Price Tags, Selection Highlights |
| **Secondary Accent**| `#0EA5E9` | 🔷 Light Sky Blue | Hyperlinks, Secondary CTA ("See More" link text) |
| **Dark Neutral** | `#1E293B` | ⬛ Deep Slate | Primary Headings, Product Names, Heavy Body Text |
| **Medium Neutral** | `#64748B` | ⬜ Cool Grey | Form Placeholders, Secondary Descriptions, Pagination Text |
| **Light Background**| `#F8FAFC` | ⬜ Off-White | Scaffold Background, Product Card Backdrops, Search Bar Fill |

### 🔤 Typography & Font Hierarchy

We are utilizing **Google Fonts** via the `google_fonts` package. 

* **Headings & Titles:** `GoogleFonts.poppins()` (Weight: `FontWeight.w640` or `w700`)
* **Body Text & UI Labels:** `GoogleFonts.inter()` (Weight: `FontWeight.w400` or `w500`)

#### Global Text Style Definitions:
* **Screen Titles (AppBar):** Poppins, Size `20`, Bold (`w600`), Color: `Dark Neutral`
* **Product Card Titles:** Poppins, Size `16`, Semi-Bold (`w500`), Color: `Dark Neutral`
* **Price Tags:** Inter, Size `16`, Bold (`w700`), Color: `Primary (#2596be)`
* **Body Description:** Inter, Size `14`, Regular (`w400`), Color: `Medium Neutral`

## ⚙️ Implementation: Global Theme Configuration

### Step 1: Add dependencies
Ensure your `pubspec.yaml` includes the google_fonts package:
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0  # Or latest stable version
---

## ⚙️ Coding Standard: Theme Enforcement

Do not pass raw hex values like `Color(0xFF2596BE)` directly into your widgets. Instead, always refer to the global app theme variables so that updates can be rolled out instantly across the entire app if the design tweaks change.

```dart
// Example of how to style your components:
Text(
  "Product Name",
  style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
      ),
);

ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary, // Resolves to #2596be
  ),
  onPressed: () {},
  child: Text("Add to Cart"),
);


## 📱 Application Flow & Architecture

The application design is mapped out into four primary phases: onboarding, discovery, detail viewing, and checkout.

[Splash Screen]
│
▼
[Onboarding Screens]
│
▼
[Dashboard / Home Page] ──(Click "See More" / Bottom Nav)──> [Product Catalog Page]
│                                                              │
(Click Product Card)                                           (Click Product Card)
│                                                              │
└─────────────────────────► [Product Details] ◄────────────────┘
│
(Add to Cart)
│
▼
[Checkout Page]

### Flow Breakdown:
1. **Entry:** User boots into the **Splash Screen** and slides through the **Onboarding Screens**.
2. **Discovery (Home):** The user lands on the **Dashboard (Home Page)**. 
   * Clicking a **Product Card** takes them directly to the **Product Details Page**.
   * Clicking the **"See More" CTA** takes them to the main **Product Catalog Page**.
3. **Discovery (Catalog):** The **Product Page** displays items in a structured **2-row by 3-column grid** equipped with **pagination**. Clicking any item here also opens its **Product Details Page**.
4. **Purchase:** From the details page, the user can **Add to Cart** and proceed to the **Checkout Page**.

---

## 📦 Screen & Layout Architecture

### 1. Entry Phase
* **Splash Screen (`splash_screen.dart`)**: App branding, logo placeholder, and a loading spinner.
* **Onboarding Screen (`onboarding_screen.dart`)**: Multi-step introductory view with an image banner, feature descriptions, and standard "Skip/Next" controls.

### 2. Main Hubs
* **Dashboard / Home (`home_page.dart`)**: 
  * Unified top `AppBar` (managed in `main.dart`).
  * **Hero Section:** Banner image with a descriptive callout and a "See More" CTA button.
  * **Horizontal Product Row:** A quick-scroll row of featured products with minimal details.
* **Product Catalog Page (`product_page.dart`)**:
  * Persistent search bar at the top.
  * **Grid Display:** Products organized cleanly into **2 rows and 3 columns** per page.
  * **Pagination Controls:** Located at the bottom to easily load subsequent product batches.
* **Global Navigation (`bottom_nav_bar.dart`)**: Persistent bottom links mapping to **Home**, **Products**, and **Profile**.

### 3. Detail Phase
* **Product Details (`product_detail.dart`)**: Deep-dive view of an item including a large product asset, price tags, descriptive copy, and a primary **"Add to Cart"** button.
* **Checkout Page (`checkout_page.dart`)**: A layout handling cart confirmation, shipping details, and payment processing.

---

## 👥 Task Distribution Matrix

To ensure development moves efficiently, responsibilities are divided on a per-page basis:

| Feature / Page | Assigned Developer | Status |
| :--- | :--- | :--- |
| **Splash & Onboarding Screens** | *whitney* | ⏳ Not Started / 🏗️ In Progress |
| **Dashboard / Home Page (Hero + Row)** | *Violah* | ⏳ Not Started / 🏗️ In Progress |
| **Product Catalog Page (2x3 Grid + Pagination)** | *Agie* | ⏳ Not Started / 🏗️ In Progress |
| **Product Details Page (Add to Cart logic)** | *Agie* | ⏳ Not Started / 🏗️ In Progress |
| **Checkout Page (Static/Functional)** | *Whitney* | ⏳ Not Started / 🏗️ In Progress |
| **Global Shell (AppBar & Bottom Navigation)** | *Glorius* | ⏳ Not Started / 🏗️ In Progress |

---

## 🛠️ Setup & Technical Guidelines

* **Framework:** Flutter / Dart
* **Architecture Style:** Clean Code / Feature-first approach.
* **Global State:** *[e.g., Provider / Bloc / Riverpod]* will manage the Cart state and Pagination index updates.

### Getting Started
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Check your assigned page in the **Task Distribution Matrix** above before making a feature branch!

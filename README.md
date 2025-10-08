# 💰 Budget Pro Tracker

**Take complete control of your finances with intelligent, lag-free tracking.**

Budget Pro Tracker is a modern, cross-platform expense management application built using Flutter. This project utilizes the **Provider** state management pattern to ensure optimal performance, prevent unnecessary UI rebuilds, and enforce clean code separation.

## ✨ Features

* **Lag-Free Performance:** Uses Provider for fine-grained state management, rebuilding only the necessary parts of the UI (e.g., updating the list without refreshing the entire screen).
* **Complete Expense Lifecycle:** Easily Add, Edit, and Delete expense records.
* **Data Persistence:** Stores all expense data locally on the device using `shared_preferences`.
* **Advanced Filtering:** Filter expenses by Search Term, Category, and Time Range (Today, Week, Month, All Time). Includes a quick **Reset Filters** button.
* **Three View Modes:** Toggle between detailed **List**, visual **Distribution Chart**, and **Advanced Analytics** screens.
* **Modern UX:** Features a clean, professional, and **keyboard-aware** UI with a custom logo and branding.

***

## 🚀 Architecture and Structure

This project follows a modular, layer-based structure, which separates business logic from the UI for improved readability and maintainability.

| Folder | Contents | Responsibility |
| :--- | :--- | :--- |
| **`lib/services/`** | `expense_notifier.dart` | **Business Logic Core.** Manages all data manipulation, filtering, persistence, and contains the `Analytics` engine. |
| **`lib/models/`** | `expense.dart`, `category.dart` | **Data Layer.** Defines core data structures and utility methods. |
| **`lib/widgets/`** | `*_view.dart`, `*_section.dart` | **Presentation Layer.** Stateless UI components that consume data from `ExpenseNotifier` using `Provider.select`. |
| **`lib/main.dart`** | App setup | **Root Layer.** Initializes the app, sets up the `Provider`, and manages the main view container. |

***

## ⚙️ Setup and Installation

### Prerequisites

* Flutter SDK (Stable Channel)
* Dart 3.0+

### Steps

1.  **Clone the Repository (Conceptual):**
    ```bash
    git clone [your-repo-link]
    cd budget_pro_tracker
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Set Native App Name:**
    To ensure the app name appears correctly on the home screen, verify these files:
    * **Android (`android/app/src/main/AndroidManifest.xml`):** `android:label="Budget Pro Tracker"`
    * **iOS (`ios/Runner/Info.plist`):** Set both `CFBundleName` and `CFBundleDisplayName` to `Budget Pro Tracker`.

4.  **Run the App:**
    ```bash
    flutter run
    ```

***

## 💻 Technical Highlights

### State Management & Performance

The core is the `ExpenseNotifier` (a `ChangeNotifier`). This enables **fine-grained rebuilding**.

* **Filter Change:** Updating `_searchTerm` calls `notifyListeners()`, causing only the `filteredExpenses` getter to re-run and the UI components listening to the list to rebuild. The main `ExpenseTrackerScreen` remains static.
* **Action Handling:** UI actions use `context.read<ExpenseNotifier>()` to call methods, avoiding rebuilding the action button itself.

### Keyboard & UX Fix

The `AddEditExpenseModal` is optimized for form input on mobile devices:

* It uses the device's keyboard height (`MediaQuery.of(context).viewInsets.bottom`) as dynamic padding at the bottom of the `SingleChildScrollView`. This guarantees that the active input field and the action buttons are never obscured by the soft keyboard and remain scrollable.

***

## 🎨 Branding

| Item | Details |
| :--- | :--- |
| **App Title** | **Budget Pro Tracker** |
| **Theme** | **Deep Blue** (`#3B82F6`) to **Deep Purple** (`#8B5CF6`) Gradient. |
| **Logo Concept** | **Minimalist Trend Coin:** Circular icon with an ascending bar chart, symbolizing growth and control. |

# 🚀 Router Generator Documentation

The Router Generator is a high-performance tool designed to automate the creation of type-safe navigation in your Flutter application using `go_router` and `typed_go_router`. It handles everything from route constant definitions to boilerplate `GoRouteData` classes and navigation extension methods.

---

## 📂 File Locations
- **Script**: `generate/router/main.dart`
- **Configuration**: `generate/router/router.json`
- **Logic Components**: `generate/router/src/`

---

## 🛠 Usage Flow
1. Open `generate/router/router.json`.
2. Define your route configurations (Add, Update, or Delete).
3. Run the following command in your terminal:
   ```bash
   dart generate/router/main.dart
   ```
4. The tool automatically detects changes, updates the files, and runs `build_runner` if necessary.

---

## 📝 Configuration Options (JSON)
The tool supports both a single object and a list of objects for batch processing.

### 1. Basic Add/Update
Creates a new route or updates an existing one if the feature/screen already exists.

```json
{
  "feature": "auth",
  "screen": "LoginScreen",
  "args": {
    "isGuest": false,
    "attempts": 3
  }
}
```

### 2. Custom Route Name (Dashed-Case)
By default, the URL path is derived from the screen name. Use `"route"` to customize the constant name and URL.

```json
{
  "feature": "products",
  "screen": "ProductDetailsScreen",
  "route": "ProductDetails" // Results in AppRoutes.productDetails and /product-details
}
```

### 3. Rename Screen
Updates all references from an old screen name to a new one.

```json
{
  "feature": "profile",
  "screen": "UserProfileScreen",
  "old_screen": "OldProfileScreen"
}
```

### 4. Move Feature
Moves a route implementation from one feature directory to another.

```json
{
  "feature": "settings",
  "old_feature": "home",
  "screen": "PrivacyScreen"
}
```

### 5. Delete Route
Completely removes a route, its page file, its constants, and its navigation methods.

```json
{
  "feature": "auth",
  "screen": "OldScreen",
  "delete": true
}
```

---

## 🌟 Key Features

### 📦 Batch Processing
Write a list of actions in `router.json` to perform multiple operations at once. The tool will run a single `build_runner` pass at the end.
```json
[
  { "feature": "auth", "screen": "Login", "route": "login" },
  { "feature": "home", "screen": "Old", "delete": true }
]
```

### 🔗 Auto-Registration
When you generate a route for a new feature, the tool automatically registers that feature in `lib/config/routes/app_router.dart` by adding:
- A scoped **Import** (`as featureName`).
- A clean **Export** (hiding generated variables).
- A **Spread Entry** (`...featureName.$appRoutes`) in the main `routes` list.

### 🛡️ Smart Cleanup
- **Imports**: Automatically removes screen imports when a route is deleted.
- **AppRouter Integration**: When a feature becomes empty (0 routes), the tool automatically removes its export, import, and spread entry from `app_router.dart`.
- **Generated Files**: Automatically deletes `.g.dart` files when a feature router is cleaned up.
- **Part Directives**: Removes `part 'router.g.dart';` from feature routers when they no longer have routes to prevent build errors.

### ⚓ Navigation Extensions (`go` vs `push`)
The tool generates two `BuildContext` extension methods for every route:

- **`go[Screen]`**: Uses `go_router`'s `.go()`. It replaces the current stack based on the route hierarchy. Ideal for jumping to a main state (e.g., `goHome()`).
- **`push[Screen]`**: Uses `go_router`'s `.push()`. It pushes the screen onto the **existing** navigation stack, regardless of hierarchy. Use this when you want a "Back" button to work (e.g., `pushDetails()`).

**Example:**
```dart
context.goLogin(isGuest: true, attempts: 0); // "Jump" to login
context.pushLogin(isGuest: true, attempts: 0); // "Push" login on top
```

### 🏗️ Scaffold Generation
If a screen doesn't exist, the tool creates a `StatefulWidget` template in the correct feature directory with the defined arguments already wired into the constructor.

---

## ⚠️ Important Rules
1. **Case Sensitivity**: You can write names in `snake_case`, `camelCase`, or `ClassCase`. The tool uses the `Names` model to normalize everything.
2. **Class Naming**: Instead of prefixing with features, the tool generates route classes based on the screen or custom route name (e.g., `LoginRoute` or `ProductDetailsRoute`).
3. **Manual Edits**: If a screen already exists and contains custom code, the tool **only updates the final fields and the constructor** to match your JSON arguments. It will not touch your `build` method or state logic.

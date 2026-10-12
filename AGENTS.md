# Agent Guide: Disk Inventory X

This document is for AI coding agents working on **Disk Inventory X**, a GPL-v3 macOS utility that visualizes disk usage with a treemap. It is written in **English** to match the project's main documentation language.

## 1. Project Overview

- **Name:** Disk Inventory X
- **Version:** `1.4b2`
- **Bundle ID:** `com.derlien.DiskInventoryX`
- **Language / Framework:** Objective-C (plus a small amount of C), targeting Cocoa / AppKit
- **License:** GPL v3 (see `COPYING`)
- **Application class:** `OAApplication` (from OmniAppKit); controller entry point is `AppController`
- **Main Nib:** `MainMenu` (loaded from localized `.lproj` directories)
- **Document class:** `FileSystemDoc` — each open folder is a document backed by an `FSItem` tree

## 2. Repository Layout

```
.
├── AppController.{h,m}              # Application delegate (subclasses OAController)
├── FileSystemDoc.{h,m}              # Document model: scans a folder and owns the FSItem tree
├── FSItem.{h,m}                     # File-system item node (tree model)
├── MainWindowController.{h,m}       # Main document window controller
├── TreeMapViewController.{h,m}      # Bridges the FSItem tree to the TreeMapView framework
├── Preferences.{h,m}                # Preferences registry / user defaults
├── PrefsPanelController.{h,m}       # Preferences window controller
├── GeneralPrefPage.{h,m}            # General preferences pane
├── TreeMapPrefPage.{h,m}            # Treemap preferences pane
├── FilesOutlineViewController.{h,m} # Outline view of files/folders
├── FileKindsTableController.{h,m}   # File-kind statistics table
├── SelectionListController.{h,m}    # Selection list controller
├── DrivesPanelController.{h,m}      # Volumes / drives panel
├── InfoPanelController.{h,m}        # Inspector/info panel
├── FileTypeColors.{h,m}             # Color mapping for file types
├── FileSizeFormatter.{h,m}          # Byte-size formatting
├── VolumeNameTransformer.{h,m}      # Value transformer for volume names
├── VolumeUsageTransformer.{h,m}     # Value transformer for volume usage
├── NSURL-Extensions.{h,m}           # NSURL helper category
├── Foundation Extensions/           # NSFileManager helper category
├── CocoaTech-Depreciated/           # Legacy helpers (info views, pasteboard source)
├── Disk Inventory X/Images.xcassets # App icon / image assets
├── Disk Inventory X.xcodeproj       # Main Xcode project
├── workspace.xcworkspace            # Workspace that includes the main project + submodules
├── BuildRelease.sh                  # Release build helper
├── Info.plist                       # App metadata, TCC usage descriptions, defaults
├── Disk Inventory X.entitlements    # Entitlements (currently empty dictionary)
├── Disk Inventory X_Prefix.pch      # Precompiled prefix header
├── OmniGroup/                       # Git submodule: Omni frameworks
├── treemapview-framework/           # Git submodule: TreeMapView.framework
├── *.lproj/                         # Localizations (en, de, es, fr, English)
└── documentation/                   # Release notes, known bugs, feature suggestions, etc.
```

## 3. Build System

- **Primary project:** `Disk Inventory X.xcodeproj`
- **Workspace:** `workspace.xcworkspace` (includes the main app, OmniGroup projects, and TreeMapView)
- **Build script:** `./BuildRelease.sh` runs:
  ```sh
  xcodebuild -project "Disk Inventory X.xcodeproj" -configuration Release
  ```
- **CI:** `.github/workflows/xcode-build.yml` builds two schemes on `macos-14`:
  - `Disk Inventory X`
  - `owxtool`
  ```sh
  xcodebuild -workspace workspace.xcworkspace \
             -scheme "Disk Inventory X" \
             -configuration Debug \
             -destination 'generic/platform=macOS' \
             CODE_SIGNING_ALLOWED=NO \
             CODE_SIGNING_REQUIRED=NO \
             CODE_SIGN_IDENTITY="" \
             build
  ```

### Build Configurations

| Setting | Project-level | Target-level (Disk Inventory X) |
|---------|---------------|---------------------------------|
| `MACOSX_DEPLOYMENT_TARGET` | `10.11` | `26.0` |
| `MARKETING_VERSION` | — | `1.4b2` |
| `CURRENT_PROJECT_VERSION` | — | `1.4b2` |
| `PRODUCT_BUNDLE_IDENTIFIER` | — | `com.derlien.DiskInventoryX` |
| `INFOPLIST_FILE` | — | `Info.plist` |
| `GCC_PREFIX_HEADER` | `Disk Inventory X_Prefix.pch` | inherited |
| `GCC_PRECOMPILE_PREFIX_HEADER` | `YES` | inherited |
| `ENABLE_HARDENED_RUNTIME` | — | `YES` |
| `CODE_SIGN_STYLE` | — | `Automatic` |

> **Note:** The target-level `MACOSX_DEPLOYMENT_TARGET = 26.0` overrides the project-level `10.11`. Because target settings win, the effective deployment target is currently `26.0`. Treat this as a potential maintenance issue if the intent was to support older macOS releases.

## 4. Dependencies

The project uses Git submodules:

```ini
[submodule "OmniGroup"]
    path = OmniGroup
    url = https://github.com/RandyMcMillan/OmniGroup.git
[submodule "treemapview-framework"]
    path = treemapview-framework
    url = https://github.com/RandyMcMillan/treemapview-framework.git
```

After cloning, initialize them with:

```sh
git submodule update --init --recursive
```

### Linked Frameworks

- `Cocoa.framework`
- `AppKit.framework`
- `Foundation.framework`
- `OmniBase.framework`
- `OmniFoundation.framework`
- `OmniAppKit.framework`
- `TreeMapView.framework`

The three Omni frameworks and TreeMapView are embedded into the app bundle via a **Copy Files** build phase (`@executable_path/../Frameworks`).

### Submodule Caveats

Many OmniGroup test/example projects use very old `.pbproj` formats that current Xcode cannot open; `xcodebuild -list` will emit warnings about unsupported Xcode versions. These are non-fatal for the main app build.

## 5. Architecture

Disk Inventory X follows a classic Cocoa document-based architecture:

- **App bootstrap:** `main.m` → `OAApplication` (Info.plist `NSPrincipalClass`) → `AppController` (Info.plist `OFControllerClass`)
- **Document model:** `FileSystemDoc` is the `NSDocument` subclass. It scans a folder and builds an `FSItem` tree.
- **Tree model:** `FSItem` represents a file, folder, or volume. `FSItem-Utilities` and `FSItemIndex` add query/index helpers.
- **UI controllers:**
  - `MainWindowController` owns the document window.
  - `TreeMapViewController` adapts the `FSItem` tree for the `TreeMapView` framework.
  - `FilesOutlineViewController`, `FileKindsTableController`, `SelectionListController`, `DrivesPanelController` fill the side panels.
  - `InfoPanelController` shows details for the selected item.
- **Preferences:** `Preferences` + `PrefsPanelController` + `PrefsPageBase` subclasses (`GeneralPrefPage`, `TreeMapPrefPage`) drive the settings UI. Preference page metadata is declared in `Info.plist` under `OFRegistrations` → `PrefsPanelController`.
- **Utilities:** formatters (`FileSizeFormatter`, `FileSizeTransformer`), color mapping (`FileTypeColors`), value transformers (`VolumeNameTransformer`, `VolumeUsageTransformer`), and extensions on `NSURL` / `NSFileManager`.

## 6. Conventions

- **Language:** Objective-C. A tiny amount of C remains in `Timing.c`.
- **Prefix header:** Every source file uses `Disk Inventory X_Prefix.pch`. It imports `<Cocoa/Cocoa.h>`, `<Carbon/Carbon.h>`, `<OmniBase/OmniBase.h>`, and defines a global logging macro:
  ```objc
  extern BOOL g_EnableLogging;
  #define LOG(x, args...) { if (g_EnableLogging) NSLog(x, ## args); }
  ```
- **Class prefixes:** Most app classes use the `DIX` prefix or descriptive names (`FileSystemDoc`, `MainWindowController`). A few legacy classes use `NT` (`NTInfoView`, etc.). Omni framework classes keep their `OA`/`OF`/`OB` prefixes.
- **File naming:** Class files match the class name exactly (`MyClass.{h,m}`).
- **Localization:** UI lives in `.nib` bundles inside `en.lproj`, `de.lproj`, `es.lproj`, `fr.lproj`, and `English.lproj`. Strings files include `Localizable.strings`, `InfoPlist.strings`, and `Preferences.strings`.
- **Notifications / KVO:** Standard Cocoa patterns are used; many UI updates are driven through `NSArrayController`, `NSTreeController`, and bindings to `FSItem` properties.
- **Memory / file access:** The app enumerates files with `NSFileManager` and `NSURL` resource values. `documentation/memory usage using NSURL.txt` and `documentation/macOS privacy protected folders.txt` discuss historical concerns around APFS/privacy-protected paths.

## 7. Testing

- **Main app:** There are no unit-test targets or test files in the main `Disk Inventory X` project.
- **OmniGroup submodule:** The workspace lists many test schemes (e.g., `ODAVUnitTests`, `OAResizingByteFormatterTest`, `OFCrashOnExceptionTest`), but most rely on ancient `.pbproj` project files that modern Xcode cannot load. They are not part of the CI matrix.
- **CI verification:** The GitHub Action simply builds `Disk Inventory X` (and `owxtool`) in Debug with signing disabled.

When making changes, rely on local builds and manual runtime validation rather than an automated test suite.

## 8. Security & Permissions

- **Entitlements:** `Disk Inventory X.entitlements` is currently an empty `<dict/>`. Hardened Runtime is enabled, but no specific entitlements (e.g., `com.apple.security.files.user-selected.read-only`) are declared there.
- **TCC usage descriptions:** `Info.plist` contains `NS*UsageDescription` keys for the protected locations the app may inspect:
  - `NSDesktopFolderUsageDescription`
  - `NSDocumentsFolderUsageDescription`
  - `NSDownloadsFolderUsageDescription`
  - `NSNetworkVolumesUsageDescription`
  - `NSRemovableVolumesUsageDescription`
  - `NSSystemAdministrationUsageDescription`
  - `NSCalendarsUsageDescription`
  - `NSContactsUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSRemindersUsageDescription`

  Each description explains that the app only inspects file sizes and attributes and does not read user data.

- **Code signing:** The target uses `CODE_SIGN_STYLE = Automatic` and a development team ID (`M684FYCYG6`) for local/release builds. CI disables signing.

## 9. Deployment / Release Process

1. Update version numbers in the target build settings:
   - `MARKETING_VERSION`
   - `CURRENT_PROJECT_VERSION`
2. Update `documentation/release notes.txt`.
3. Run the release build:
   ```sh
   ./BuildRelease.sh
   ```
4. The built `.app` appears in `build/Release/` (or the configured `BUILT_PRODUCTS_DIR`).
5. Notarize / staple / distribute outside this repo as needed.

## 10. Quick Reference for Agents

- **Build the app:**
  ```sh
  xcodebuild -workspace workspace.xcworkspace -scheme "Disk Inventory X" -configuration Debug build
  ```
- **Build release:**
  ```sh
  ./BuildRelease.sh
  ```
- **List schemes:**
  ```sh
  xcodebuild -workspace workspace.xcworkspace -list
  ```
- **Run CI-like build:**
  ```sh
  xcodebuild -workspace workspace.xcworkspace -scheme "Disk Inventory X" -configuration Debug -destination 'generic/platform=macOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
  ```

When editing, prefer matching the existing Objective-C style, keep the prefix header valid, and update localized strings / `.nib` resources in all `*.lproj` directories when the UI changes.

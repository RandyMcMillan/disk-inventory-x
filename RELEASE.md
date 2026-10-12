# Release flow

`Release.sh` is the one-stop release entry point for building, signing, notarizing, and publishing a GitHub Release asset.

## Local signature check

Verify the existing app bundle without rebuilding:

```sh
./Release.sh --check
```

This runs `codesign --verify` and `spctl` against `build/Release/Disk Inventory X.app`.

## Notarized release

For a notarized release, use:

```sh
./Release.sh --notarize --password "app-specific-password"
```

Optional overrides:

```sh
./Release.sh --notarize \
  --apple-id you@example.com \
  --team-id M684FYCYG6 \
  --signing-identity "Developer ID Application: Your Name (TEAMID)" \
  --password "app-specific-password" \
  v2.0.3
```

If no tag is supplied, the script uses the project `MARKETING_VERSION` and prefixes it with `v`.

## What the script does

1. Runs `./BuildRelease.sh` to build the app.
2. Chooses a signing identity:
   - `Developer ID Application` when `--notarize` is set
   - `Apple Development` otherwise
3. Signs the embedded frameworks and then the app bundle.
4. If `--notarize` is set:
   - creates a temporary zip for `xcrun notarytool`
   - submits the archive and waits for approval
   - staples the notarization ticket to the app
   - verifies Gatekeeper acceptance with `spctl`
5. Creates the final release zip.
6. Pushes the tag to `origin` when `--notarize` is used and the tag is not already on the remote.
7. Creates or updates the GitHub Release asset with `gh release`.
8. Prints the direct download URL for the release asset.

## Defaults and inputs

The script can infer sensible defaults:

- Apple ID from `APPLE_ID` or the built-in default
- Team ID from `DEVELOPMENT_TEAM` in the project, then the repository default
- Signing identity from `SIGNING_IDENTITY` or the installed certificate

You can override any of these with flags or environment variables.

## Typical notarized release

```sh
./Release.sh --notarize --password "app-specific-password"
```

If the tag already exists locally but not on `origin`, the script pushes it before creating the GitHub Release.

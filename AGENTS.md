# Repository guidance

## Scope

These instructions apply to the entire repository. Keep changes limited to the requested task and preserve unrelated working-tree changes.

## Project overview

- This is an Xcode project written primarily in Swift and SwiftUI.
- The main application target and scheme are `wsanjusto-ios`.
- Companion schemes are `wsanjustowidgetExtension` and `wsanjustowatchos WatchKit App`. Most watchOS executable code belongs to the `wsanjustowatchos WatchKit Extension` target.
- First-party source lives under `wsanjusto-ios/`, `wsanjustowidget/`, `wsanjustowatchos WatchKit App/`, and `wsanjustowatchos WatchKit Extension/`.
- Treat package sources shown by Xcode (Firebase, gRPC, SwiftProtobuf, and their transitive dependencies) as external code and do not edit them.
- Firebase configuration is stored in `wsanjusto-ios/Environments/GoogleService-Info.plist`. Do not display or modify its contents unless the task explicitly requires it, and never add credentials or secrets to source files or logs.
- The first-party test targets are `wsanjusto-iosTests` and `wsanjusto-iosUITests`. Both are included in the shared `wsanjusto-ios` Test Plan and main application scheme. Do not mistake dependency test suites for project tests.
- UI test support code and Screen Objects live under `wsanjusto-iosUITests/`.
- GitHub Actions runs the unit and UI test targets separately through `.github/workflows/ios-tests.yml`, preserving an independent result bundle for each target.

## Architecture and implementation

- Follow the existing separation into `Views`, `ViewModels`, `Models`, `Data`, and `Common`.
- Preserve the existing SwiftUI and view-model organization. Do not perform architectural refactors unless they are required by the task.
- Preserve code shared with the widget or watch app. When changing shared models, resources, or services, check every affected target.
- Prefer Swift concurrency (`async`/`await`) for new asynchronous code. Do not introduce Combine solely for asynchronous work.
- Use dependency injection for time, networking, and other external inputs when it makes logic testable; follow the existing `DateProviding` pattern.
- Avoid force unwraps. Use Swift naming conventions, four-space indentation, and the formatting style of the surrounding file.
- Preserve the language used by the surrounding user interface. Do not introduce new user-visible strings without following the project's existing localization approach.
- Do not add packages or raise deployment targets unless the task explicitly requires it.

## Xcode project changes

- Use Xcode-aware project operations when adding, moving, or deleting source files so file references and target membership remain correct.
- Do not edit `project.pbxproj` by hand unless no Xcode-aware operation can perform the required change.
- Keep assets in the appropriate asset catalog and use the existing resource conventions.
- Do not modify generated files, build products, DerivedData, or checked-out Swift package sources.

## UI testing

- Launch UI tests with `-UITesting` and `-UITestingSkipSplash` so Firebase is not configured and the app uses deterministic local fixtures.
- Select fixture behavior with `-UITestingScenario success|empty|error`. Keep new scenarios deterministic and independent of live services, credentials, locale-sensitive dates, and the current time.
- Add stable, semantic accessibility identifiers for UI elements exercised by XCUIAutomation. Prefer identifiers describing a role such as `first` or `last` over fixture implementation details such as generated UUIDs or timestamps.
- Keep navigation, scrolling, selectors, and waiting logic in the Screen Objects under `wsanjusto-iosUITests/Screens`. Tests should describe user behavior and assertions rather than repeat query details.
- Do not use fixed sleeps or coordinate-based interactions when an accessibility element and `waitForExistence(timeout:)` can express the same behavior.
- Attach screenshots for UI test failures and terminate the application between tests to prevent shared state.

## Validation

- For a localized Swift change, first refresh diagnostics for the edited files.
- Build `wsanjusto-ios` for changes limited to the iOS app.
- Build `wsanjustowidgetExtension` for widget changes.
- Build `wsanjustowatchos WatchKit App` for watch app or watch extension changes.
- Build every affected scheme when changing shared models, services, resources, or project settings.
- Run relevant unit tests in `wsanjusto-iosTests` with Swift Testing and UI tests in `wsanjusto-iosUITests` with XCTest/XCUIAutomation.
- Use the shared `wsanjusto-ios.xctestplan` through the `wsanjusto-ios` scheme. Prefer running unit and UI targets separately when collecting result bundles, matching the CI configuration.
- Changes involving Firebase or live network data should not require production writes during validation. Use injected dependencies, fixtures, previews, or read-only checks where practical.
- If full validation cannot run because signing, a device, credentials, or network access is unavailable, report exactly what was and was not verified.

## Change hygiene

- Never discard or rewrite unrelated user changes.
- Keep commits and diffs focused; avoid opportunistic refactors.
- Update this file when targets, build procedures, test commands, or repository-wide conventions materially change.

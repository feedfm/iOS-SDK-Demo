# Feed.fm iOS SDK Demo

This repository contains a demo application that illustrates how to use the
[FeedMedia iOS SDK](https://github.com/feedfm/iOS-SDK) to build a simple app
that streams music. It is meant as a reference integration: a small, readable
SwiftUI project you can read top-to-bottom to see how the SDK is configured,
how playback is driven, and how the standard iOS "now playing" experience
(lock-screen controls, artwork, and background audio) is wired up.

## What's in here

| Path | Description |
| --- | --- |
| `iOS-SDK-Demo.xcworkspace` | The workspace to open in Xcode. |
| `Simple/` | The **Simple** demo app — a SwiftUI "Feed Radio" client. |
| `Simple/Sources/` | App source. |
| `Simple/Tests/` | Unit tests for the app's plain-Swift helpers. |

The FeedMedia SDK is pulled in via Swift Package Manager from
`https://github.com/feedfm/iOS-SDK` (pinned in
`iOS-SDK-Demo.xcworkspace/xcshareddata/swiftpm/Package.resolved`). There is
nothing to install by hand — Xcode resolves the package on first open.

## The Simple app

**Simple** is a one-screen SwiftUI music app that:

- Lists the stations available to the 'demo' Feed.fm account.
- Plays, pauses, and skips tracks, and likes / dislikes the current song.
- Shows a mini player bar that expands into a full-screen player.
- Renders per-station artwork (a remote image when the station provides one,
  otherwise a generated brand-gradient + waveform fallback).
- Keeps playing in the background and drives the lock-screen "Now Playing"
  interface — metadata, artwork, and remote play / pause / skip / like / dislike
  controls.

### How it's structured

The SDK does the heavy lifting (streaming, the `AVAudioSession`, lock-screen
metadata, and remote commands); the app is mostly thin UI plus a single
observable store that bridges SDK notifications to SwiftUI state.

| File | Role |
| --- | --- |
| `SimpleApp.swift` | App entry point. Sets the client token, configures the `AVAudioSession` (`.playback`) so the app owns the lock-screen controls, and waits for the player to become available. |
| `PlayerStore.swift` | `@Observable` wrapper around `FMAudioPlayer.shared()`. Subscribes to the SDK's notifications, exposes display state + playback intents to the UI, and renders lock-screen artwork. |
| `RootView.swift` | Composes the station list with the mini bar and the expanding full player. |
| `StationListView.swift`, `StationRow.swift` | Station browsing UI. |
| `MiniBarView.swift`, `FullPlayerView.swift` | Playback UI. |
| `MarqueeText.swift` | SwiftUI wrapper around the SDK's `FMMarqueeLabel`; text scrolls when too wide to fit, stays static otherwise. |
| `MetadataFormat.swift` | Pure helper that joins artist and album into one display line. |
| `DisclaimerView.swift` | Music licensing disclaimer sheet, opened from the "Powered by Feed.fm" attribution in the full player. |
| `RadioStation.swift` | A display model decoupled from the SDK's `FMStation`, built from a plain options dictionary so it's easy to test. |
| `ArtworkView.swift`, `Waveform.swift`, `FRTheme.swift` | Artwork rendering and theming. |
| `TimeFormat.swift` | Elapsed / remaining time formatting. |

### Key SDK touch points

If you're integrating the SDK into your own app, these are the parts to read first:

1. **Credentials** — `FMAudioPlayer.setClientToken(_:secret:)` in `SimpleApp.swift`.
2. **Availability** — `FMAudioPlayer.shared().whenAvailable(_:notAvailable:)` gates
   the UI until the player (and station list) is ready.
3. **Playback** — `setActiveStation(_:withCrossfade:)`, `play()`, `pause()`,
   `skip()`, `like()`, `dislike()` in `PlayerStore.swift`.
4. **State** — the app listens to `FMAudioPlayer*` notifications
   (playback state, current item, elapsed time, skip/like status, active station)
   rather than polling.
5. **Lock screen & background audio** — the SDK manages metadata and remote
   controls; the app declares the `audio` `UIBackgroundMode` (`Sources/Info.plist`)
   and supplies artwork via `setLockScreenImage(_:)`.

## Demo Requirements

- Xcode 16 or later
- iOS 17.0+ deployment target
- Swift 6 language mode
- A Feed.fm client token and secret

## Running

1. Open `iOS-SDK-Demo.xcworkspace` in Xcode.
2. Wait for Swift Package Manager to resolve the `iOS-SDK` package.
3. Select the **Simple** scheme and an iOS 17+ simulator or device.
4. Build and run (⌘R).

The demo ships with the placeholder credentials `"demo"` / `"demo"` (see
`SimpleApp.swift`). To stream your own catalog, replace them with the client
token and secret from your [Feed.fm](https://feed.fm) account.

### Running the tests

From Xcode, press ⌘U with the **Simple** scheme selected, or from the command
line:

```sh
xcodebuild \
  -workspace iOS-SDK-Demo.xcworkspace \
  -scheme Simple \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

## Learn more

- [docs.feed.fm](https://docs.feed.fm)

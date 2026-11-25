# JonContextMenu

[![Swift 6](https://img.shields.io/badge/Swift-6-orange.svg)](https://swift.org)
[![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A long-press arc menu for iOS, in the style of Pinterest's. Press and hold a view, slide your finger
to an item, and let go to select it. Works with UIKit and SwiftUI.

![Demo](https://media.giphy.com/media/31UCkk6Hs1bMVb2bo7/giphy.gif)

- Items fan out away from screen edges, so they stay reachable anywhere on the screen.
- Haptic feedback when the menu opens and when an item is highlighted.
- VoiceOver users get every item as a custom action on the view.
- Respects Reduce Motion, Dynamic Type and dark mode.
- No dependencies.

## Installation

In Xcode, choose **File → Add Package Dependencies…** and enter:

```
https://github.com/jonSurrey/JonContextMenu
```

Or add it to `Package.swift`:

```swift
.package(url: "https://github.com/jonSurrey/JonContextMenu", from: "2.0.0")
```

## Usage

Create up to eight items. Each one runs its handler when the user lets go on it.

```swift
import JonContextMenu

let items = [
    ArcMenuItem(title: "Like", image: UIImage(systemName: "heart.fill")) { like() },
    ArcMenuItem(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { share() },
    ArcMenuItem(title: "Save", image: UIImage(systemName: "bookmark.fill")) { save() }
]
```

### UIKit

```swift
view.addInteraction(ArcMenuInteraction(items: items))
```

In a reusable cell, add the interaction once and update `items` when you configure the cell.

### SwiftUI

```swift
PhotoCard(photo)
    .arcMenu(items)
```

While the menu is open, the pressed view stays visible above the dimmed background. In SwiftUI, pass
the view's shape so it keeps its outline:

```swift
PhotoCard(photo)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .arcMenu(items, previewShape: RoundedRectangle(cornerRadius: 16))
```

UIKit views keep their own shape automatically. In both, shadows outside the view's frame aren't shown.

The menu takes over touches on the view it is attached to, so attach it to content that doesn't have
its own buttons or gestures.

## Customization

Every property of `ArcMenuStyle` has a default that adapts to light and dark mode.

```swift
var style = ArcMenuStyle()
style.backgroundColor = .systemIndigo.withAlphaComponent(0.9)
style.itemColor = .white
style.highlightedItemColor = .systemOrange
style.iconColor = .systemIndigo
style.highlightedIconColor = .white
style.titleColor = .white
style.titleFont = .systemFont(ofSize: 34, weight: .heavy)
style.touchIndicatorColor = .white

view.addInteraction(ArcMenuInteraction(items: items, style: style))
```

To keep an image's own colors, set `iconColor` and `highlightedIconColor` to `nil`.

## Example app

Open `Example/Example.xcodeproj` and run the **Example** scheme. It shows the same menus in UIKit and SwiftUI.

## Migrating from 1.x

| 1.x | 2.0 |
|---|---|
| CocoaPods | Swift Package Manager |
| `JonItem(id:title:icon:data:)` | `ArcMenuItem(title:image:handler:)` |
| `JonContextMenuDelegate` | The item's `handler` |
| `JonContextMenu().setItems(…).build()` gesture | `ArcMenuInteraction(items:style:)` |
| `set…ColorTo(…)` methods | `ArcMenuStyle` properties |
| Objective-C support | Removed |

## License

JonContextMenu is available under the MIT license. See [LICENSE](LICENSE).

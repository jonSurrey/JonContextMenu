import JonContextMenu
import UIKit

enum SampleMenu: CaseIterable {
    case standard
    case colorful
    case originalImageColors
    case eightItems

    var title: String {
        switch self {
        case .standard: "Default style"
        case .colorful: "Custom colors"
        case .originalImageColors: "Original image colors"
        case .eightItems: "Eight items"
        }
    }

    var style: ArcMenuStyle {
        var style = ArcMenuStyle()
        switch self {
        case .standard, .eightItems:
            break
        case .colorful:
            style.backgroundColor = .systemIndigo.withAlphaComponent(0.92)
            style.itemColor = .white
            style.highlightedItemColor = .systemOrange
            style.iconColor = .systemIndigo
            style.titleColor = .white
            style.touchIndicatorColor = .white
        case .originalImageColors:
            style.iconColor = nil
            style.highlightedIconColor = nil
            style.highlightedItemColor = .systemGray3
        }
        return style
    }

    func items(onSelect: @escaping @MainActor (String) -> Void) -> [ArcMenuItem] {
        let actions = switch self {
        case .eightItems: Self.allActions
        case .standard, .colorful, .originalImageColors: Array(Self.allActions.prefix(4))
        }
        return actions.map { action in
            ArcMenuItem(title: action.title, image: image(for: action)) { onSelect(action.title) }
        }
    }

    private func image(for action: SampleAction) -> UIImage? {
        let image = UIImage(systemName: action.symbolName)
        guard self == .originalImageColors else { return image }
        return image?.withTintColor(action.color, renderingMode: .alwaysOriginal)
    }

    private static let allActions = [
        SampleAction(title: "Like", symbolName: "heart.fill", color: .systemPink),
        SampleAction(title: "Share", symbolName: "square.and.arrow.up", color: .systemBlue),
        SampleAction(title: "Save", symbolName: "bookmark.fill", color: .systemOrange),
        SampleAction(title: "Delete", symbolName: "trash.fill", color: .systemRed),
        SampleAction(title: "Favorite", symbolName: "star.fill", color: .systemYellow),
        SampleAction(title: "Send", symbolName: "paperplane.fill", color: .systemTeal),
        SampleAction(title: "Report", symbolName: "flag.fill", color: .systemPurple),
        SampleAction(title: "Copy link", symbolName: "link", color: .systemGreen)
    ]
}

private struct SampleAction {
    let title: String
    let symbolName: String
    let color: UIColor
}

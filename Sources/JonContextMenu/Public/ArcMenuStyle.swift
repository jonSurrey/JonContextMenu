import UIKit

public struct ArcMenuStyle {
    public var backgroundColor: UIColor = .systemBackground.withAlphaComponent(0.9)
    public var itemColor: UIColor = .secondarySystemBackground
    public var highlightedItemColor: UIColor = .systemRed
    /// `nil` shows the image in its original colors.
    public var iconColor: UIColor? = .label
    /// `nil` shows the image in its original colors.
    public var highlightedIconColor: UIColor? = .white
    public var titleColor: UIColor = .label
    /// Scaled with Dynamic Type.
    public var titleFont: UIFont = .systemFont(ofSize: 34, weight: .heavy)
    public var touchIndicatorColor: UIColor = .label

    public init() {}
}

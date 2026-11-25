import UIKit

final class ArcMenuItemView: UIView {
    private static let iconInset: CGFloat = 12
    private static let shadowOpacity: Float = 0.3
    private static let shadowOffset = CGSize(width: 0, height: 2)
    private static let shadowRadius: CGFloat = 3

    private let item: ArcMenuItem
    private let style: ArcMenuStyle
    private let imageView = UIImageView()

    init(item: ArcMenuItem, style: ArcMenuStyle) {
        self.item = item
        self.style = style
        let diameter = ArcMetrics.itemDiameter
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))

        layer.cornerRadius = diameter / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Self.shadowOpacity
        layer.shadowOffset = Self.shadowOffset
        layer.shadowRadius = Self.shadowRadius

        imageView.frame = bounds.insetBy(dx: Self.iconInset, dy: Self.iconInset)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        setHighlighted(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setHighlighted(_ highlighted: Bool) {
        let iconColor = highlighted ? style.highlightedIconColor : style.iconColor
        backgroundColor = highlighted ? style.highlightedItemColor : style.itemColor
        imageView.image = item.image?.withRenderingMode(iconColor == nil ? .alwaysOriginal : .alwaysTemplate)
        imageView.tintColor = iconColor
    }
}

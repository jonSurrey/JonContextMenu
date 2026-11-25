import UIKit

final class ArcMenuOverlayView: UIView {
    private static let fadeDuration: TimeInterval = 0.2
    private static let springDuration: TimeInterval = 0.6
    private static let springDamping: CGFloat = 0.6
    private static let highlightScale: CGFloat = 1.2
    private static let touchIndicatorOpacity: CGFloat = 0.15
    private static let minimumTitleScale: CGFloat = 0.5

    private let layout: ArcLayout
    private let items: [ArcMenuItem]
    private let itemViews: [ArcMenuItemView]
    private let titleLabel = UILabel()

    init(frame: CGRect, layout: ArcLayout, items: [ArcMenuItem], style: ArcMenuStyle, pressedViewSnapshot: UIView?) {
        self.layout = layout
        self.items = items
        itemViews = items.map { ArcMenuItemView(item: $0, style: style) }
        super.init(frame: frame)

        isUserInteractionEnabled = false
        backgroundColor = style.backgroundColor

        if let pressedViewSnapshot {
            addSubview(pressedViewSnapshot)
        }

        let indicatorDiameter = ArcMetrics.touchIndicatorDiameter
        let touchIndicator = UIView(frame: CGRect(x: 0, y: 0, width: indicatorDiameter, height: indicatorDiameter))
        touchIndicator.center = layout.touchPoint
        touchIndicator.layer.cornerRadius = indicatorDiameter / 2
        touchIndicator.backgroundColor = style.touchIndicatorColor.withAlphaComponent(Self.touchIndicatorOpacity)
        addSubview(touchIndicator)

        titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: style.titleFont)
        titleLabel.textColor = style.titleColor
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = Self.minimumTitleScale
        titleLabel.alpha = 0
        addSubview(titleLabel)

        for itemView in itemViews {
            itemView.center = layout.touchPoint
            addSubview(itemView)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func present() {
        alpha = 0
        UIView.animate(withDuration: Self.fadeDuration) { self.alpha = 1 }
        animateMovement {
            for (itemView, center) in zip(self.itemViews, self.layout.itemCenters) {
                itemView.center = center
            }
        }
    }

    func apply(_ change: HighlightChange) {
        if let previous = change.previous {
            itemViews[previous].setHighlighted(false)
        }
        if let current = change.current {
            itemViews[current].setHighlighted(true)
            titleLabel.text = items[current].title
            titleLabel.frame = layout.titleFrame(for: titleLabel.intrinsicContentSize)
        }

        animateMovement {
            if let previous = change.previous {
                self.itemViews[previous].center = self.layout.itemCenters[previous]
                self.itemViews[previous].transform = .identity
            }
            if let current = change.current {
                self.itemViews[current].center = self.layout.highlightedItemCenters[current]
                self.itemViews[current].transform = CGAffineTransform(scaleX: Self.highlightScale, y: Self.highlightScale)
            }
            self.titleLabel.alpha = change.current == nil ? 0 : 1
        }
    }

    func dismiss() {
        UIView.animate(withDuration: Self.fadeDuration) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    private func animateMovement(_ changes: @escaping () -> Void) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            changes()
            return
        }
        UIView.animate(
            withDuration: Self.springDuration,
            delay: 0,
            usingSpringWithDamping: Self.springDamping,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: changes
        )
    }
}

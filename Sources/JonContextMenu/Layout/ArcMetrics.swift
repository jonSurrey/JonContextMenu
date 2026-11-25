import CoreGraphics

enum ArcMetrics {
    static let itemDiameter: CGFloat = 48
    static let touchIndicatorDiameter: CGFloat = 44
    static let gapBetweenIndicatorAndItems: CGFloat = 24
    static let highlightOffset: CGFloat = 16
    static let angleBetweenItems: CGFloat = .pi / 4
    static let titleSpacing: CGFloat = 24
    static let titleMargin: CGFloat = 16

    static let armLength = touchIndicatorDiameter / 2 + gapBetweenIndicatorAndItems + itemDiameter / 2
}

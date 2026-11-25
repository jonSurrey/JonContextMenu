import CoreGraphics

/// Where every part of the menu goes for one press, in the window's coordinate space.
struct ArcLayout: Equatable, Sendable {
    static let maximumItemCount = 8

    let touchPoint: CGPoint
    let itemCenters: [CGPoint]
    let highlightedItemCenters: [CGPoint]
    private let bounds: CGRect

    init(touchPoint: CGPoint, bounds: CGRect, itemCount: Int) {
        let fanAngle = Self.fanAngle(for: touchPoint, in: bounds)
        let middleIndex = CGFloat(itemCount - 1) / 2
        let angles = (0..<itemCount).map { index in
            fanAngle + (CGFloat(index) - middleIndex) * ArcMetrics.angleBetweenItems
        }

        self.touchPoint = touchPoint
        self.bounds = bounds
        itemCenters = angles.map { touchPoint.offset(by: ArcMetrics.armLength, angle: $0) }
        highlightedItemCenters = angles.map {
            touchPoint.offset(by: ArcMetrics.armLength + ArcMetrics.highlightOffset, angle: $0)
        }
    }

    /// The nearest item within reach. Reach includes the highlight offset, so a highlighted
    /// item stays selectable after it moves outward.
    func itemIndex(at point: CGPoint) -> Int? {
        let reach = ArcMetrics.itemDiameter / 2 + ArcMetrics.highlightOffset
        return itemCenters.indices
            .filter { itemCenters[$0].distance(to: point) <= reach }
            .min { itemCenters[$0].distance(to: point) < itemCenters[$1].distance(to: point) }
    }

    /// Above the menu when it fits, otherwise below it; horizontally centered on the touch
    /// and kept inside the bounds.
    func titleFrame(for size: CGSize) -> CGRect {
        let width = min(size.width, bounds.width - 2 * ArcMetrics.titleMargin)
        let centeredX = touchPoint.x - width / 2
        let x = max(bounds.minX + ArcMetrics.titleMargin, min(centeredX, bounds.maxX - ArcMetrics.titleMargin - width))

        let menuTop = highlightedItemCenters.reduce(touchPoint.y) { min($0, $1.y) } - ArcMetrics.itemDiameter / 2
        let menuBottom = highlightedItemCenters.reduce(touchPoint.y) { max($0, $1.y) } + ArcMetrics.itemDiameter / 2
        let yAbove = menuTop - ArcMetrics.titleSpacing - size.height
        let y = yAbove >= bounds.minY ? yAbove : menuBottom + ArcMetrics.titleSpacing

        return CGRect(x: x, y: y, width: width, height: size.height)
    }

    /// Items fan out away from any edge the touch is close to, and upward otherwise.
    private static func fanAngle(for touch: CGPoint, in bounds: CGRect) -> CGFloat {
        let reach = ArcMetrics.armLength + ArcMetrics.highlightOffset + ArcMetrics.itemDiameter / 2
        var direction = CGVector.zero
        if touch.x - bounds.minX < reach { direction.dx += 1 }
        if bounds.maxX - touch.x < reach { direction.dx -= 1 }
        if touch.y - bounds.minY < reach { direction.dy += 1 }
        if bounds.maxY - touch.y < reach { direction.dy -= 1 }

        guard direction != .zero else { return -.pi / 2 }
        return atan2(direction.dy, direction.dx)
    }
}

private extension CGPoint {
    func offset(by distance: CGFloat, angle: CGFloat) -> CGPoint {
        CGPoint(x: x + cos(angle) * distance, y: y + sin(angle) * distance)
    }

    func distance(to other: CGPoint) -> CGFloat {
        hypot(other.x - x, other.y - y)
    }
}

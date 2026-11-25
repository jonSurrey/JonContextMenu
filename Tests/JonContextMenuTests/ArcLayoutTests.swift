import CoreGraphics
import Testing
@testable import JonContextMenu

struct ArcLayoutTests {
    private let bounds = CGRect(x: 0, y: 0, width: 390, height: 844)

    private func layout(at touchPoint: CGPoint, itemCount: Int = 4) -> ArcLayout {
        ArcLayout(touchPoint: touchPoint, bounds: bounds, itemCount: itemCount)
    }

    @Test("Away from every edge, items fan out above the touch")
    func fansUpwardInTheMiddle() {
        let touch = CGPoint(x: bounds.midX, y: bounds.midY)
        #expect(layout(at: touch).itemCenters.allSatisfy { $0.y < touch.y })
    }

    @Test("Near the left edge, items fan out to the right")
    func fansRightNearLeftEdge() {
        let touch = CGPoint(x: 20, y: bounds.midY)
        #expect(layout(at: touch).itemCenters.allSatisfy { $0.x > touch.x })
    }

    @Test("Near the right edge, items fan out to the left")
    func fansLeftNearRightEdge() {
        let touch = CGPoint(x: bounds.maxX - 20, y: bounds.midY)
        #expect(layout(at: touch).itemCenters.allSatisfy { $0.x < touch.x })
    }

    @Test("Near the top edge, items fan out below the touch")
    func fansDownNearTopEdge() {
        let touch = CGPoint(x: bounds.midX, y: 20)
        #expect(layout(at: touch).itemCenters.allSatisfy { $0.y > touch.y })
    }

    @Test("In the top-left corner, the arc points toward the bottom-right")
    func fansDiagonallyInCorner() {
        let touch = CGPoint(x: 20, y: 20)
        let centers = layout(at: touch).itemCenters
        let averageX = centers.map(\.x).reduce(0, +) / CGFloat(centers.count)
        let averageY = centers.map(\.y).reduce(0, +) / CGFloat(centers.count)
        #expect(averageX > touch.x)
        #expect(averageY > touch.y)
    }

    @Test("Every item sits at the same distance from the touch")
    func itemsShareOneRadius() {
        let touch = CGPoint(x: bounds.midX, y: bounds.midY)
        for center in layout(at: touch, itemCount: 8).itemCenters {
            #expect(abs(hypot(center.x - touch.x, center.y - touch.y) - ArcMetrics.armLength) < 0.001)
        }
    }

    @Test("Neighboring items are evenly spaced along the arc")
    func neighborsAreEvenlySpaced() {
        let centers = layout(at: CGPoint(x: bounds.midX, y: bounds.midY)).itemCenters
        let expected = 2 * ArcMetrics.armLength * sin(ArcMetrics.angleBetweenItems / 2)
        for (current, next) in zip(centers, centers.dropFirst()) {
            #expect(abs(hypot(next.x - current.x, next.y - current.y) - expected) < 0.001)
        }
    }

    @Test("A highlighted item moves outward by the highlight offset")
    func highlightMovesOutward() {
        let touch = CGPoint(x: bounds.midX, y: bounds.midY)
        for center in layout(at: touch).highlightedItemCenters {
            let distance = hypot(center.x - touch.x, center.y - touch.y)
            #expect(abs(distance - (ArcMetrics.armLength + ArcMetrics.highlightOffset)) < 0.001)
        }
    }

    @Test("Touching an item's center finds that item")
    func findsItemAtItsCenter() {
        let layout = layout(at: CGPoint(x: bounds.midX, y: bounds.midY))
        for (index, center) in layout.itemCenters.enumerated() {
            #expect(layout.itemIndex(at: center) == index)
        }
    }

    @Test("A highlighted item can still be found at its moved position")
    func findsItemAtHighlightedPosition() {
        let layout = layout(at: CGPoint(x: bounds.midX, y: bounds.midY))
        for (index, center) in layout.highlightedItemCenters.enumerated() {
            #expect(layout.itemIndex(at: center) == index)
        }
    }

    @Test("Where reaches overlap, the nearest item wins")
    func nearestItemWins() {
        let layout = layout(at: CGPoint(x: bounds.midX, y: bounds.midY))
        let first = layout.itemCenters[0]
        let second = layout.itemCenters[1]
        let closerToSecond = CGPoint(x: first.x + (second.x - first.x) * 0.6, y: first.y + (second.y - first.y) * 0.6)
        #expect(layout.itemIndex(at: closerToSecond) == 1)
    }

    @Test("No item is found at the touch point or far away from the menu")
    func findsNothingOutsideItems() {
        let touch = CGPoint(x: bounds.midX, y: bounds.midY)
        let layout = layout(at: touch)
        #expect(layout.itemIndex(at: touch) == nil)
        #expect(layout.itemIndex(at: CGPoint(x: 0, y: 0)) == nil)
    }

    @Test("The title goes above the menu when it fits")
    func titleAboveWhenItFits() {
        let layout = layout(at: CGPoint(x: bounds.midX, y: bounds.midY))
        let title = layout.titleFrame(for: CGSize(width: 120, height: 40))
        let menuTop = layout.highlightedItemCenters.map(\.y).min() ?? 0
        #expect(title.maxY < menuTop)
    }

    @Test("The title goes below the menu when there is no room above")
    func titleBelowWithoutRoomAbove() {
        let touch = CGPoint(x: bounds.midX, y: 120)
        let layout = layout(at: touch)
        let title = layout.titleFrame(for: CGSize(width: 120, height: 40))
        #expect(layout.itemCenters.allSatisfy { $0.y < touch.y })
        #expect(title.minY > touch.y)
    }

    @Test("The title stays inside the bounds near an edge")
    func titleStaysInsideBounds() {
        let layout = layout(at: CGPoint(x: bounds.maxX - 10, y: bounds.midY))
        let title = layout.titleFrame(for: CGSize(width: 200, height: 40))
        #expect(title.maxX <= bounds.maxX - ArcMetrics.titleMargin)
    }

    @Test("In landscape, a tall title with no room above or below stays inside the bounds")
    func tallTitleStaysInsideBoundsInLandscape() {
        let bounds = CGRect(x: 59, y: 0, width: 734, height: 372)
        // Near the left edge the arc fans sideways, so the title fits neither above nor below it.
        let layout = ArcLayout(touchPoint: CGPoint(x: 79, y: 186), bounds: bounds, itemCount: 4)
        let title = layout.titleFrame(for: CGSize(width: 150, height: 72))
        #expect(title.minY >= bounds.minY)
        #expect(title.maxY <= bounds.maxY)
    }

    @Test("A title wider than the screen is narrowed to fit")
    func wideTitleIsNarrowed() {
        let layout = layout(at: CGPoint(x: bounds.midX, y: bounds.midY))
        let title = layout.titleFrame(for: CGSize(width: 2000, height: 40))
        #expect(title.minX == bounds.minX + ArcMetrics.titleMargin)
        #expect(title.maxX == bounds.maxX - ArcMetrics.titleMargin)
    }
}

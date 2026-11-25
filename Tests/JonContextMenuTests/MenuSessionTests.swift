import CoreGraphics
import Testing
@testable import JonContextMenu

struct MenuSessionTests {
    private let layout = ArcLayout(
        touchPoint: CGPoint(x: 195, y: 422),
        bounds: CGRect(x: 0, y: 0, width: 390, height: 844),
        itemCount: 4
    )

    @Test("A new session has nothing highlighted")
    func startsWithoutHighlight() {
        #expect(MenuSession(layout: layout).highlightedIndex == nil)
    }

    @Test("Moving onto an item highlights it")
    func movingOntoItemHighlightsIt() {
        var session = MenuSession(layout: layout)
        let change = session.moveTouch(to: layout.itemCenters[2])
        #expect(change == HighlightChange(previous: nil, current: 2))
        #expect(session.highlightedIndex == 2)
    }

    @Test("Moving within the highlighted item changes nothing")
    func movingWithinItemChangesNothing() {
        var session = MenuSession(layout: layout)
        _ = session.moveTouch(to: layout.itemCenters[2])
        #expect(session.moveTouch(to: layout.highlightedItemCenters[2]) == nil)
        #expect(session.highlightedIndex == 2)
    }

    @Test("Moving straight to another item moves the highlight")
    func movingBetweenItemsMovesHighlight() {
        var session = MenuSession(layout: layout)
        _ = session.moveTouch(to: layout.itemCenters[0])
        let change = session.moveTouch(to: layout.itemCenters[1])
        #expect(change == HighlightChange(previous: 0, current: 1))
        #expect(session.highlightedIndex == 1)
    }

    @Test("Moving off every item clears the highlight")
    func movingOffClearsHighlight() {
        var session = MenuSession(layout: layout)
        _ = session.moveTouch(to: layout.itemCenters[3])
        let change = session.moveTouch(to: layout.touchPoint)
        #expect(change == HighlightChange(previous: 3, current: nil))
        #expect(session.highlightedIndex == nil)
    }

    @Test("Moving around without touching an item changes nothing")
    func movingOutsideItemsChangesNothing() {
        var session = MenuSession(layout: layout)
        #expect(session.moveTouch(to: layout.touchPoint) == nil)
    }
}

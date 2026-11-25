import CoreGraphics

struct HighlightChange: Equatable, Sendable {
    let previous: Int?
    let current: Int?
}

/// One press, from the menu opening to the finger lifting.
struct MenuSession: Sendable {
    let layout: ArcLayout
    private(set) var highlightedIndex: Int?

    init(layout: ArcLayout) {
        self.layout = layout
    }

    mutating func moveTouch(to point: CGPoint) -> HighlightChange? {
        let index = layout.itemIndex(at: point)
        guard index != highlightedIndex else { return nil }

        let change = HighlightChange(previous: highlightedIndex, current: index)
        highlightedIndex = index
        return change
    }
}
